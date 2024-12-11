using Ecophys, SkyDomes, Unitful
import Unitful: K, °C, Pa, kPa


#= 

Simple model for computing air temperature and relative humidity at a specific time of the day (h) and day of the year (DOY).
Algorithm that calculates the variation of air temperature during the day as a function of daily maximum and minimum temperature registered at a weather station.
    We use the following equations to compute air temperature during the day and night:
    - During the day (equation 1): Tair = Tmin + (Tmax - Tmin) * sin(π*(h-sunrise)/(DL+2*p))
    - During the night (equation 2): Tair = Tmin + (Tmax - Tmin) * exp(-(h + 24 - sunset)/tc)
    Where:
        - Tmin and Tmax are the daily minimum and maximum temperature, respectively
        - h is the time of the day in hours
        - sunrise and sunset are the times of sunrise and sunset, respectively
        - DL is the day length
        - p is the time between solar noon and the normal time of Tmax
        - tc is the nocturnal time coefficient
Day is divided in 4 periods:
    A (between midnight and sunrise), -> apply equation to compute temperature during the night perid (equation 2)
        Tair depends on Tmax of previous day and Tmin of present day
    B (between sunrise and normal time of Tmax), -> apply equation to compute temperature during the day period (equation 1)
        Tair dependes on Tmin and Tmax of present day
    C (between normal time of Tmax and sunset) and D (between sunset and midnight)
        Tair of period C and D depends on the Tmax of present day and Tmin of the next day
        But uses different equations to compute Tair
            C -> apply equation 1
            D -> apply equation 2 

=#

# Unitless version
"""
simple_Ta_RH(; lat::Float64, DOY::Float64, h::Float64, 
                   Tmin::Vector{Float64}, Tmax::Vector{Float64}, ea::Vector{Float64}, p::Float64 = 1.5, tc::Float64 = 4.0)

# Arguments:
    - `lat`: latitide, []
    - `DOY`: day of the year, [d]
    - `h`: hour of the day, [h]
    - `Tmin`: vector of daily minimum temperature for the previous day, current day, and next day, [°C]
    - `Tmax`: vector of daily maximum temperature for the previous day, current day, and next day, [°C]
    - `ea`: vector of daily average vapor pressure for the previous day, current day, and next day, [kPa]

Citation:
    Goudriaan, J., & van Laar, H. H. (1994). Modelling potential crop growth processes. Textbook with exercises. Springer Science & Business Media.
"""
function simple_Ta_RH(; lat::Float64, DOY::Float64, h::Float64, Tmin::Vector{Float64}, Tmax::Vector{Float64}, ea::Vector{Float64}, p::Float64 = 1.5, tc::Float64 = 4.0)
    #Conversion to types with units
    Tmin = (273.15 .+ Tmin)*K
    Tmax = (273.15 .+ Tmax)*K
    ea = ea*1.0e3Pa
    #Compute air temperature (Ta, K) at a specific time of the day (h) and day of the year (DOY)
    result = simple_Ta_RH_Q(lat = lat, DOY = DOY, h = h, Tmin = Tmin, Tmax = Tmax, ea = ea, p = p, tc = tc)
    #Conversion to unitless types
    Ta = ustrip(result.Ta)
    TaC = ustrip(result.TaC)
    return (Ta = Ta, TaC = TaC, RH = result.RH)
end


# Unitful version
"""
    simple_Ta_RH(; lat::W, DOY::W, h::W, 
                   Tmin::Vector{T}, Tmax::Vector{T}, ea::Vector{P}, 
                   p::W = 1.5, tc::W = 4.0) where {T <: Quantity, P <: Quantity, W <: Real}

# Arguments:
    - `lat`: latitide, []
    - `DOY`: day of the year, [d]
    - `h`: hour of the day, [h]
    - `Tmin`: vector of daily minimum temperature for the previous day, current day, and next day, [K]
    - `Tmax`: vector of daily maximum temperature for the previous day, current day, and next day, [K]
    - `ea`: vector of daily average vapor pressure for the previous day, current day, and next day, [Pa]

"""
function simple_Ta_RH_Q(; lat::W, DOY::W, h::W, 
                        Tmin::Vector{T}, Tmax::Vector{T}, ea::Vector{P}, 
                        p::W = 1.5, tc::W = 4.0) where {T <: Quantity, P <: Quantity, W <: Real}


    #Indexes for Tmin, Tmax, and ea: 1 = DOY - 1, 2 = DOY, 3 = DOY + 1
    DL = day_length(lat, declination(DOY))
    sunrise = 12-0.5*DL
    sunset = 12+0.5*DL
    #Compute air temperature (Ta, K) at a specific time of the day (h) and day of the year (DOY)
    if h >= 0.0 && h < sunrise #Period A
        T_sunset1 = Tmin[2] + (Tmax[1] - Tmin[2]) * sin(π*(DL/(DL+2*p))) #Tair at sunset(past day)
        NL = 24.0 - DL
        Ta = ( Tmin[2] - T_sunset1*exp(-NL/tc) + (T_sunset1 - Tmin[2])*exp(-(h + 24.0 - sunset)/tc) ) / ( 1-exp(-NL/tc) )
        elseif h >= sunrise && h < 12 + p #Period B
            Ta = Tmin[2] + (Tmax[2]-Tmin[2]) * sin(π*(h-sunrise)/(DL+2*p))
        elseif h >= 12 + p && h < sunset #Period C
            Ta = Tmin[3] + (Tmax[2] - Tmin[3]) * sin(π*(h-sunrise)/(DL+2*p))
        elseif h >= sunset && h <= 24.0 #Period D
            T_sunset2 = Tmin[3] + (Tmax[2] - Tmin[3]) * sin(π*(DL/(DL+2*p))) #Tair at sunrise(present day)
            NL = 24.0 - DL
            Ta = ( Tmin[3] - T_sunset2*exp(-NL/tc) + (T_sunset2 - Tmin[3])*exp(-(h - sunset)/tc) ) / ( 1.0 - exp(-NL/tc) )
        else @warn "h < 0 or h > 24"
    end
    TaK = Ta
    TaC = uconvert(°C, TaK)
    
    #Compute relative humidity
    RH::Float64 = ea[2]/Ecophys.Photosynthesis.es(Ta)
    
    return(Ta = TaK, TaC = TaC, RH = RH)

end


""" Example:
```jldoctest
lat = 40.0
DOY = 180.0
h = 12.0

Tmin_u = [288.15, 289.15, 290.15]K
Tmin = ustrip.(uconvert.(°C, Tmin_u))

Tmax_u = [298.15,299.15,300.15]K
Tmax = ustrip.(uconvert.(°C, Tmax_u))

ea_u = [1.0e3, 1.5e3, 1.7e3]Pa
ea = ustrip.(uconvert.(kPa, ea_u))

p = 1.5
tc = 4.0

simple_Ta_RH_Q(;lat, DOY, h, Tmin = Tmin_u, Tmax = Tmax_u, ea = ea_u, p, tc)
simple_Ta_RH(;lat, DOY, h, Tmin, Tmax, ea, p, tc)
```
"""
