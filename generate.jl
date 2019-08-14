using Pkg
#Pkg.activate(dirname(@__FILE__))
Pkg.activate(@__DIR__)
using Fire
using PhysicsTutorials

@main function generate(filename::String)
    pns = _splitpath(abspath(filename))
    length(pns) < 3 && error("Invalid path to source file: $filename")

    category, tutorial_name = pns[end-2:end-1]
    fname, ext = splitext(pns[end])

    fname==tutorial_name || error("tutorial name $tutorial_name is not consistent with filename $fname, expected format: `tutorials/quantum_computing/<name>/<name>.ipynb`")

    if ext == ".ipynb"
        source = PhysicsTutorials.NotebookSource()
    elseif ext ==".jmd"
        source = PhysicsTutorials.WeaveSource()
    elseif ext ==".jl"
        source = PhysicsTutorials.LiterateSource()
    else
        error("Expected file extension: `*.jl`, `*.jmd` or `*.ipynb`, but got $ext.")
    end
    PhysicsTutorials.convert_tutorial(category,tutorial_name,source)
end


# compatibility patch
const path_dir_splitter = r"^(.*?)([/\\]+)([^/\\]*)$"

_splitdir_nodrive(path::String) = _splitdir_nodrive("", path)
function _splitdir_nodrive(a::String, b::String)
    m = match(path_dir_splitter,b)
    m === nothing && return (a,b)
    a = string(a, isempty(m.captures[1]) ? m.captures[2][1] : m.captures[1])
    a, String(m.captures[3])
end

function _splitpath(p::String)
    drive, p = splitdrive(p)
    out = String[]
    isempty(p) && (pushfirst!(out,p))  # "" means the current directory.
    while !isempty(p)
        dir, base = _splitdir_nodrive(p)
        dir == p && (pushfirst!(out, dir); break)  # Reached root node.
        if !isempty(base)  # Skip trailing '/' in basename
            pushfirst!(out, base)
        end
        p = dir
    end
    if !isempty(drive)  # Tack the drive back on to the first element.
        out[1] = drive*out[1]  # Note that length(out) is always >= 1.
    end
    return out
end


