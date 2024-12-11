# PlantClima

In development. If you find any issue, please report it to the repository. 
Thank you for your collaboration!

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://anaIFernst.github.io/PlantClima.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://anaIFernst.github.io/PlantClima.jl/dev/)
[![Build Status](https://github.com/anaIFernst/PlantClima.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/anaIFernst/PlantClima.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/anaIFernst/PlantClima.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/anaIFernst/PlantClima.jl)

The package PlantClima provides functions that help users to compute
environmental conditions at different time scales as function of latitude, day of year
and time of the day. Up to now, we added a simple model to compute air temperature
and relative humidity.

## Instalation

To install PlantClima.jl, you can use the following command:

```julia
] add PlantClima
```

To install the development version of this package:

```julia
import Pkg
Pkg.add(url = "https://github.com/anaIFernst/PlantClima.jl", rev = "master")
```

## Usage

### Air temperature and relative humidity

... loading