module PhysicsTutorials
# inspiration taken from DiffEqTutorials.jl

using Weave, Pkg

repo_directory = joinpath(@__DIR__,"..")
cssfile = joinpath(@__DIR__, "..", "templates", "skeleton_css.css")
latexfile = joinpath(@__DIR__, "..", "templates", "julia_tex.tpl")
htmlfile = joinpath(@__DIR__, "..", "templates", "julia_html.tpl")


function weave_file(folder,file,build_list=(:html,:pdf,:notebook); kwargs...)
  jmdfile = joinpath(repo_directory,"tutorials",folder,file)
  args = Dict{Symbol,String}(:folder=>folder,:file=>file)
  if :script ∈ build_list
    println("Building Script")
    tangle(jmdfile)
  end
  if :html ∈ build_list
    println("Building HTML")
    weave(jmdfile,doctype = "md2html",args=args; css=cssfile, template=htmlfile, kwargs...)
  end
  if :pdf ∈ build_list
    println("Building PDF")
    dir = joinpath(repo_directory,"pdf",folder)
    weave(jmdfile,doctype="md2pdf",args=args; template=latexfile, kwargs...)
  end
  if :github ∈ build_list
    println("Building Github Markdown")
    dir = joinpath(repo_directory,"markdown",folder)
    weave(jmdfile,doctype = "github",args=args; kwargs...)
  end
  if :notebook ∈ build_list
    println("Building Notebook")
    dir = joinpath(repo_directory,"notebook",folder)
    # Weave.convert_doc(jmdfile,joinpath(dir,file[1:end-4]*".ipynb"))
    Weave.notebook(jmdfile; out_path=dirname(jmdfile))
  end
end

function weave_all()
  for folder in readdir(joinpath(repo_directory,"tutorials"))
    weave_folder(folder)
  end
end

function weave_folder(folder)
  for file in readdir(joinpath(repo_directory,"tutorials",folder))
    println("Building $(joinpath(folder,file)))")
    try
      weave_file(folder,file)
    catch
    end
  end
end

function tutorial_footer(folder=nothing, file=nothing; remove_homedir=true)
    display("text/markdown", """
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

    ctx = Pkg.API.Context()
    pkgs = Pkg.Display.status(Pkg.API.Context(), use_as_api=true);
    projfile = ctx.env.project_file
    remove_homedir && (projfile = replace(projfile, homedir() => "~"))

    display("text/markdown","""
    Package Information:
    """)

    md = ""
    md *= "```\nStatus `$(projfile)`\n"

    for pkg in pkgs
        if !isnothing(pkg.new.ver)
          md *= "[$(string(pkg.uuid))] $(string(pkg.name)) $(string(pkg.new.ver))\n"
        else
          md *= "[$(string(pkg.uuid))] $(string(pkg.name))\n"
        end
    end
    md *= "```"
    display("text/markdown", md)
end


function open_notebooks()
  Base.eval(Main, Meta.parse("import IJulia"))
  path = joinpath(repo_directory,"tutorials")
  IJulia.notebook(;dir=path)
end

end # module
