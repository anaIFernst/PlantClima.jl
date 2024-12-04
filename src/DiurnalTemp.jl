using VirtualPlantLab
using Ecophys, SkyDomes


"""
    simple_Ta_RH(; lat::Float64, DOY::Int64, h::Float64, 
                   Tmin::Vector{Float64}, Tmax::Vector{Float64}, ea::Vector{Float64}, p::Float64 = 1.5, tc::Float64 = 4.0)
# Arguments:
    - `lat`: latitide, []
    - `DOY`: day of the year, [d]
    - `h`: hour of the day, [h]
    - `Tmin`: vector of daily minimum temperature for the previous day, current day, and next day, [°C]
    - `Tmax`: vector of daily maximum temperature for the previous day, current day, and next day, [°C]
    - `ea`: vector of daily average vapor pressure for the previous day, current day, and next day, [kPa]
    - 

"""

 #=Simple model for computing air temperature and relative humidity at a specific time of the day (h) and day of the year (DOY).
    Algorithm that calculates the variation of air temperature during the day as a function of daily maximum and minimum temperature registered at a weather station (Goudriaan & van Laar, 1994).
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
                    D -> apply equation 2=#
function simple_Ta_RH(; lat::Float64, DOY::Int64, h::Float64, Tmin::Vector{Float64}, Tmax::Vector{Float64}, ea::Vector{Float64}, p::Float64 = 1.5, tc::Float64 = 4.0)
    #Indexes for Tmin, Tmax, and ea: 1 = DOY - 1, 2 = DOY, 3 = DOY + 1
    DL = day_length(lat, declination(DOY))
    sunrise = 12-0.5*DL
    sunset = 12+0.5*DL
    #p = 1.5 #Time between solar noon and normal time of Tmax, set as default to 1.5h
    #tc = 4 #Nocturnal time coeffiecient, set as default to 4h
    #Compute air temperature
    if h >= 0.0 && h < sunrise #Period A
        T_sunset1 = Tmin[2] + (Tmax[1] - Tmin[2]) * sin(π*(DL/(DL+2*p))) #Tair at sunset(past day)
        NL = 24.0 - DL
        Ta::Float64 = ( Tmin[2] - T_sunset1*exp(-NL/tc) + (T_sunset1 - Tmin[2])*exp(-(h + 24.0 - sunset)/tc) ) / ( 1-exp(-NL/tc) )
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
    #Compute relative humidity
    RH::Float64 = ea[2]/Ecophys.Photosynthesis.es(Ta)
    return (Ta = Ta, RH = RH)
end