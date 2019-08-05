module PhysicsTutorials
# inspiration taken from DiffEqTutorials.jl

using Weave, Literate, Pkg

repo_directory = joinpath(@__DIR__,"..")
cssfile = joinpath(@__DIR__, "..", "templates", "skeleton_css.css")
latexfile = joinpath(@__DIR__, "..", "templates", "julia_tex.tpl")
htmlfile = joinpath(@__DIR__, "..", "templates", "julia_html.tpl")


function open_notebooks()
    Base.eval(Main, Meta.parse("import IJulia"))
    path = joinpath(repo_directory,"tutorials")
    IJulia.notebook(;dir=path)
end

function with_localenv(f, folder)
    activate_env(folder)
    f()
    activate_env(repo_directory)
end

function activate_env(folder)
    if isabspath(folder)
        Pkg.activate(folder)
    else
        Pkg.activate(joinpath(repo_directory, folder))
    end
    nothing
end


function format_header!(weavefile)
    lines = split(read(weavefile, String), "\n")
    if startswith(lines[2], "#") && startswith(lines[3], "###")
        title = strip(lines[2][2:end])
        author = strip(lines[3][4:end])
        header = strip.(split("""---
        title: $title
        author: $author
        ---""", "\n"))
        write(weavefile, join(vcat(lines[1], header, lines[4:end]), "\n"))
    end
    nothing
end

abstract type Source end
struct NotebookSource <: Source end
struct LiterateSource <: Source end
struct WeaveSource <: Source end

convert_tutorial(cat, tut; kwargs...) = convert_tutorial(cat, tut, NotebookSource(); kwargs...)

function convert_tutorial(cat, tut, source::NotebookSource; overwrite=false, quick=false, markdown=false)
    tut_folder = joinpath(repo_directory, "tutorials", cat, tut)
    nbfile = joinpath(tut_folder, string(tut, ".ipynb"))
    weavefile = joinpath(tut_folder, string(tut, ".jmd"))

    # weave
    @info "Preparing"
    convert_doc(nbfile, weavefile)

    # markdown
    if markdown && (!isfile(joinpath(tut_folder, string(tut, ".md"))) || overwrite)
        @info "Converting to markdown"
        if quick
            read(`jupyter nbconvert --to markdown $nbfile`)
        else
            with_localenv(tut_folder) do
                weave(weavefile, doctype="github")
            end
        end
    end

    format_header!(weavefile)
    # html
    if !isfile(joinpath(tut_folder, string(tut, ".html"))) || overwrite
        @info "Converting to html"
        if quick
            read(`jupyter nbconvert --to HTML $nbfile`)
        else
            with_localenv(tut_folder) do
                weave(weavefile, doctype="md2html"; css=cssfile, template=htmlfile)
            end
        end
    end
    # pdf
    if !isfile(joinpath(tut_folder, string(tut, ".pdf"))) || overwrite
        @info "Converting to pdf"
        if quick
            read(`jupyter nbconvert --to PDF $nbfile`)
        else
            with_localenv(tut_folder) do
                weave(weavefile, doctype="md2pdf"; template=latexfile)
            end
        end
    end
    isfile(weavefile) && rm(weavefile)
    @info "Done"
    nothing
end

end # module
