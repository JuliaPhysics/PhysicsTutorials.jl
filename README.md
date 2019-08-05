# PhysicsTutorials.jl
This package holds tutorials showing how to utilize Julia and its ecosystem for physics applications. Tutorials are available as PDFs, HTML webpages, and interactive Jupyter notebooks. The folder structure is `tutorials/<category>/<tutorial name>/`. Each tutorial folder is a Julia project, which can be `] activate`d and `] instantiate`d. For more information, please consult the [JuliaPhysics webpage](http://juliaphysics.github.io).

## Table of Contents

* General
  * [Speeding up Quantum Mechanics - Matrix Types](https://juliaphysics.github.io/PhysicsTutorials.jl/tutorials/general/matrix_types/matrix_types.html)
  
* Machine Learning
  * [Machine Learning the Ising Transition](https://juliaphysics.github.io/PhysicsTutorials.jl/tutorials/machine_learning/ml_ising/ml_ising.html)

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
using PhysicsTutorials
cd(joinpath(dirname(pathof(PhysicsTutorials)), ".."))
PhysicsTutorials.weave_tutorial("general","matrix_types")
```

To generate all formats for all tutorials, do:

```julia
PhysicsTutorials.weave_all()
```
