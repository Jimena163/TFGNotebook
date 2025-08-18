using JIVECore
using Documenter

DocMeta.setdocmeta!(JIVECore, :DocTestSetup, :(using JIVECore); recursive=true)

makedocs(;
    modules=[JIVECore],
    authors="Pablo Villacorta Aylagas <pablo.villacorta@uva.es> and contributors",
    sitename="JIVECore.jl",
    format=Documenter.HTML(;
        canonical="https://pvillacorta.github.io/JIVECore.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/pvillacorta/JIVECore.jl",
    devbranch="master",
)
