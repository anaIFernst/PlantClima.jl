using PlantClima
using Documenter

DocMeta.setdocmeta!(PlantClima, :DocTestSetup, :(using PlantClima); recursive=true)

makedocs(;
    modules=[PlantClima],
    authors="anaIFernst <ana.ferreiraernst@wur.nl> and contributors",
    sitename="PlantClima.jl",
    format=Documenter.HTML(;
        canonical="https://anaIFernst.github.io/PlantClima.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/anaIFernst/PlantClima.jl",
    devbranch="master",
)
