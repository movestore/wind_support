# Wind Support and Modelling

MoveApps

Github repository: *github.com/movestore/wind_support*

## Description
Calculates wind support, cross wind and airspeed for a data set (of preferrably flight) that was annotated in Movebank Env-DATA with wind U and wind V component data (ECMWF). In addition, model output is generated to confirm influence of wind on flight movement.

## Documentation
This App optimally needs as input a file that has been generated with Movebank Env-DATA, being annotated with ECMWF ERA5 SL Wind (10 m above Ground U Component) and ECMWF ERA5 SL Wind (10 m above Ground V Component). If annotation with wind data is done otherwise, the input file needs the following columns: timestamp, location.long, location.lat, individual.local.identifier, individual.taxon.canonical.name, sensor.type, `*`U.Component`*` and `*`V.Component`*` (where in the latter two the name can be extended freely on both sides). Preferrably, also heading and ground.speed should be included (if available from the raw data), else they will be added as between-location speed and heading.

Wind support, cross wind and airspeed are calculated and added to each location as described in Safi et al. 2013 (Flying with the wind: scale dependency of speed and direction measurements in modelling wind support in avian flight. Movement Ecolology 1:4). In addition, GAMM models are fitted to airspeed and ground speed, indicating to which extend they are affected by wind support and cross wind. See details in the above mentioned publication. 

### Input data
moveStack in Movebank format

### Output data
moveStack in Movebank format

### Artefacts
`Wind_support_plots.pdf`: A 4 page results artefact including histogrammes of airspeed and ground speed as well as model results indicating influence of wind support and/or cross wind on ground speed and airspeed, respectively (plots and model estimates).

### Parameters 
`minspeed`: minimum ground speed (unit = m/s) of your tracked species. Only locations with speed less than it will be used for model building. Default: 25 m/s. However, all locations will be annotated and returned for use in a next App.

`maxspeed`: maximum ground speed (unit = m/s) of your tracked species. Only locations with speed less than it will be used for model building. Default: 25 m/s. However, all locations will be annotated and returned for use in a next App.

### Null or error handling:
**Parameter `minspeed`:** this parameter only affects the model building. If it is too small or too large, the model might not converge or show unrealistic results.

**Parameter `maxspeed`:** this parameter only affects the model building. If it is too small or too large, the model might not converge or show unrealistic results.

**Data:** The full data set with additional attributes is returned.