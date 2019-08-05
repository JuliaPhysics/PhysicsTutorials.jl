# PhysicsTutorials.jl
This package holds tutorials showing how to utilize Julia and its ecosystem for physics applications. Tutorials are available as PDFs, HTML webpages, and interactive Jupyter notebooks. For more details, please consult the [JuliaPhysics webpage](http://juliaphysics.github.io).

## Table of Contents

* General
  * [Speeding up Quantum Mechanics - Matrix Types](https://juliaphysics.github.io/PhysicsTutorials.jl/tutorials/general/matrix_types.html)

## Interactive Jupyter Notebooks

To run the tutorials interactively in Jupyter notebooks, install the package and IJulia via

```
] add http://github.com/JuliaPhysics/PhysicsTutorials IJulia
```

and start/open the notebook server like

```julia
using PhysicsTutorials, IJulia
PhysicsTutorials.open_notebooks()
```

## Contributing

All PDFs, webpages, and Jupyter notebooks are generated from the Weave.jl files in the `tutorials` folder (`.jmd`).
To trigger the generation process for an individual tutorial, run the following code:

```julia
using Pkg, PhysicsTutorials
cd(joinpath(dirname(pathof(PhysicsTutorials)), ".."))
pkg"activate ."
pkg"instantiate"
PhysicsTutorials.weave_file("general","matrix_types.jmd")
```

To generate all formats for all tutorials, do:

```julia
PhysicsTutorials.weave_all()
```

If you add new tutorials please put

`````markdown
```{julia; echo=false; skip="notebook"}
using PhysicsTutorials
PhysicsTutorials.tutorial_footer(WEAVE_ARGS[:folder],WEAVE_ARGS[:file])
```
`````

at the end of the `*.jmd` file. If your tutorial requires new packages, don't forget to `] add` them to the `Project.toml` file in the root folder of the repository.
