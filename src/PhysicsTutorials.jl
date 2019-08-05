module PhysicsTutorials
# inspiration taken from DiffEqTutorials.jl

using Weave, Pkg

repo_directory = joinpath(@__DIR__,"..")
cssfile = joinpath(@__DIR__, "..", "templates", "skeleton_css.css")
latexfile = joinpath(@__DIR__, "..", "templates", "julia_tex.tpl")
htmlfile = joinpath(@__DIR__, "..", "templates", "julia_html.tpl")


function with_localenv(f, folder)
    activate_env(folder)
    f()
    activate_env(repo_directory)
end


"""
Weave a jmd file.
"""
function weave_file(jmdfile,build_list=(:html,:pdf,:notebook); kwargs...)
    folder = dirname(jmdfile)
    file = basename(jmdfile)
    args = Dict{Symbol,String}(:folder=>folder,:file=>file,:footer=>tutorial_footer(folder, file))
    if :script ∈ build_list
        println("Building Script")
        with_localenv(folder) do
            tangle(jmdfile)
        end
    end
    if :html ∈ build_list
        println("Building HTML")
        with_localenv(folder) do
            weave(jmdfile,doctype = "md2html",args=args; css=cssfile, template=htmlfile, kwargs...)
        end
    end
    if :pdf ∈ build_list
        println("Building PDF")
        with_localenv(folder) do
            weave(jmdfile,doctype="md2pdf",args=args; template=latexfile, kwargs...)
        end
    end
    if :github ∈ build_list
        println("Building Github Markdown")
        with_localenv(folder) do
            weave(jmdfile,doctype = "github",args=args; kwargs...)
        end
    end
    if :notebook ∈ build_list
        println("Building Notebook")
        with_localenv(folder) do
            # Weave.convert_doc(jmdfile,joinpath(folder,file[1:end-4]*".ipynb"))
            Weave.notebook(jmdfile, out_path=dirname(jmdfile))
        end
    end
end

function weave_all()
    for cat in readdir(joinpath(repo_directory,"tutorials"))
        for tut in readdir(joinpath(repo_directory,"tutorials",cat))
            println(cat, "/", tut)
            println("---------------------")
            weave_tutorial(cat,tut)
            println("")
        end
    end
end

"""
    weave_tutorial(cat, tut)

Weave the tutorial with name `tut` in category `cat`. The tutorial's .jmd file(s) must be in `tutorials/cat/tut`.
"""
function weave_tutorial(cat, tut)
    tut_path = joinpath(repo_directory, "tutorials", cat, tut)
    for file in filter(x->endswith(x, ".jmd"), readdir(tut_path))
        println("Building $(tut_path)")
        weave_file(joinpath(tut_path, file))
    end
end

function tutorial_footer(folder=nothing, file=nothing; remove_homedir=true)
    io = IOBuffer()
    print(io, """
    ## Appendix

     This tutorial is part of the [PhysicsTutorials.jl](https://github.com/JuliaPhysics/PhysicsTutorials.jl) repository.
    """)
    # if folder !== nothing && file !== nothing
    #     display("text/markdown", """
    #     To locally run this tutorial, do the following commands:
    #     ```
    #     using PhysicsTutorials
    #     PhysicsTutorials.weave_file("$folder","$file")
    #     ```
    #     """)
    # end

    # ctx = Pkg.API.Context()
    # pkgs = Pkg.Display.status(Pkg.API.Context(), use_as_api=true);
    # projfile = ctx.env.project_file
    # remove_homedir && (projfile = replace(projfile, homedir() => "~"))

    # display("text/markdown","""
    # Package Information:
    # """)

    # md = ""
    # md *= "```\nStatus `$(projfile)`\n"

    # for pkg in pkgs
    #     if !isnothing(pkg.new)
    #       md *= "[$(string(pkg.uuid))] $(string(pkg.name)) $(string(pkg.new.ver))\n"
    #     else
    #       md *= "[$(string(pkg.uuid))] $(string(pkg.name))\n"
    #     end
    # end
    # md *= "```"
    # display("text/markdown", md)
    String(take!(io))
end


function open_notebooks()
    Base.eval(Main, Meta.parse("import IJulia"))
    path = joinpath(repo_directory,"tutorials")
    IJulia.notebook(;dir=path)
end

function activate_env(folder)
    if isabspath(folder)
        Pkg.activate(folder)
    else
        Pkg.activate(joinpath(repo_directory, folder))
    end
    nothing
end

end # module
