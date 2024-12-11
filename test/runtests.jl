using PlantClima
using Test
using Documenter
import Aqua

# Test examples on documentation (jldoctest blocks)
DocMeta.setdocmeta!(PlantClima,
    :DocTestSetup,
    :(using PlantClima);
    recursive = true)
doctest(PlantCliam)

# Aqua
@testset "Aqua" begin
    Aqua.test_all(PlantClima, ambiguities = false, project_extras = false)
    Aqua.test_ambiguities([PlantClima])
end

@testset "PlantClima.jl" begin

    # Test scripts = DiurnalTemp.jl
    include("test_DiurnalTemp.jl")   

end
