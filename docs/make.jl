using PlantClima
using Documenter

DocMeta.setdocmeta!(PlantClima, :DocTestSetup, :(using PlantClima); recursive=true)

makedocs(;
    doctest = false,
    modules = [PlantClima],
    authors = "anaIFernst <ana.ferreiraernst@wur.nl> and contributors",
    sitename = "PlantClima.jl",
    repo = "https://github.com/anaIFernst/PlantClima.jl/blob/{commit}{path}#{line}",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        edit_link = "master",
        assets = String[],
    ),
    pages = [
        "API" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/anaIFernst/PlantClima.jl",
    devbranch="master",
)
