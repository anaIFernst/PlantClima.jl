using PlantClima, Test, Unitful
import Unitful: °C, K, Pa, kPa
PC = PlantClima

let 

    lat = 40.0
    DOY = 180.0
    h = 12.0
    Tmin_u = [288.15, 289.15, 290.15]K
    Tmin = ustrip.(uconvert.(°C, Tmin_u))
    Tmax_u = [298.15, 299.15, 300.15]K
    Tmax = ustrip.(uconvert.(°C, Tmax_u))
    ea_u = [1.0e3, 1.5e3, 1.7e3]Pa
    ea = ustrip.(uconvert.(kPa, ea_u))
    p = 1.5
    tc = 4.0

    # Call the functions and get the results
    result_Ta_RH = PC.simple_Ta_RH(;lat, DOY, h, Tmin, Tmax, ea, p, tc)
    result_Ta_RH_Q = PC.simple_Ta_RH_Q(lat = lat, DOY = DOY, h = h, Tmin = Tmin_u, Tmax = Tmax_u, ea = ea_u, p = p, tc = tc)

    # Convert the results from simple_Ta_RH_Q to the same units as simple_Ta_RH
    TaK_Q = result_Ta_RH_Q[:Ta]
    TaC_Q = uconvert(°C, TaK_Q)
    RH_Q = result_Ta_RH_Q[:RH]

    # Run tests
    @testset "simple_Ta_RH vs simple_Ta_RH_Q tests" begin
        @test result_Ta_RH[:Ta] ≈ ustrip(TaK_Q)
        @test result_Ta_RH[:TaC] ≈ ustrip(TaC_Q)
        @test result_Ta_RH[:RH] ≈ RH_Q
    end

end