using Documenter
using Literate
using PhysicsTutorials
using PhysicsTutorials: convert_tutorial, LiterateSource, tutorials_directory

const mdsrcdir = joinpath(@__DIR__, "src")
const assetsdir = joinpath(mdsrcdir, "assets")

# list all tutorials
const tutorials = [
    "general/matrix_types",
    "general/quantum_ising",
    "machine_learning/ml_ising",
]

# convert all the tutorials to documenter's md format
for tutorial in tutorials
    @info "Processing $tutorial"
    category, tutorial_src = split(tutorial, '/')
    @debug "" category tutorial_src

    # directory for _this_ tutorial
    tut_folder = joinpath(tutorials_directory, category, tutorial_src)
    @debug "" tut_folder

    Literate.markdown(joinpath(tut_folder, tutorial_src *".jl"), mdsrcdir)

    convert_tutorial(category, tutorial_src, LiterateSource())

    # Move the entire tutorial folder, now holding everything except the
    # documenter markdown file, into the assets directory.
    # This also moves the original .jl Literate script and the Project.toml, but
    # these changes don't get committed in the main branch anyway, so it should be ok.
    #Base.Filesystem.cptree(tut_folder, assetsdir)
end

# make a pages entry for each of the tutorials

makedocs(

)
