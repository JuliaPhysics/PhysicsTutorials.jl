using Fire
using PhysicsTutorials

path_names(path::String) = path in ("","/") ? () : (path_names(dirname(path))..., basename(path))

@main function generate(filename::String)
    pns = path_names(abspath(filename))
    length(pns) < 3 && error("illegal path $filename")

    category, tutorial_name = pns[end-2:end-1]
    fname, ext = splitext(pns[end])

    fname==tutorial_name || error("tutorial name should be consistent with filename, e.g. `tutorials/quantum_computing/<name>/<name>.ipynb`")

    if ext == ".ipynb"
        source = PhysicsTutorials.NotebookSource()
    elseif ext ==".jmd"
        source = PhysicsTutorials.WeaveSource()
    elseif ext ==".jl"
        source = PhysicsTutorials.LiterateSource()
    else
        error("illegal extension $filename")
    end
    PhysicsTutorials.convert_tutorial(category,tutorial_name,source)
end
