# Wind Support and Modelling

MoveApps

Github repository: *github.com/movestore/wind_support*

## Description
Calculates wind support, cross wind and airspeed for a data set (of preferably flight) that that includes U and V wind components, which can be annotated in Movebank using Env-DATA (we recommend using the wind provided by ECMWF). In addition, model output is generated to confirm influence of wind on flight movement.

## Documentation
This App optimally needs as input a file that has been generated with [Env-DATA](https://www.movebank.org/cms/movebank-content/env-data) in Movebank, annotated with ECMWF ERA5 Single Level Wind (10 m above Ground U Component) and ECMWF ERA5 SL Wind (10 m above Ground V Component). ECMWF also offers Single Level Wind at 100 m above ground, and Pressure Level wind at the animal's altitude as measured by the tag, if stored in Movebank, or at a barometric level that represents the expected flying altitude of your study animals. If U and V wind information is added by another method, ensure that the input file contains the following columns:  
* [timestamp](http://vocab.nerc.ac.uk/collection/MVB/current/MVB000200/): in format yyyy-MM-dd HH:mm:ss.SSS (UTC)
* [location.long](http://vocab.nerc.ac.uk/collection/MVB/current/MVB000145/): geographic latitude (WGS84)
* [location.lat](http://vocab.nerc.ac.uk/collection/MVB/current/MVB000146/): geographic longitude (WGS84)
* [individual.local.identifier](http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/): animal ID
* [individual.taxon.canonical.name](http://vocab.nerc.ac.uk/collection/MVB/current/MVB000024/): animal taxon
* [sensor.type](http://vocab.nerc.ac.uk/collection/MVB/current/MVB000170/): the type of sensor used to estimate location
* `*`U.Component`*` and `*`V.Component`*` ("`*`" represents character strings that can be extended freely on both sides). These attributes contain the U and V components of wind speed, which must be in units of meters per second (m/s). where in the latter two the name can be extended freely on both sides). 

If available, you are highly recommended to include the following:
* [heading](http://vocab.nerc.ac.uk/collection/MVB/current/MVB000129/): in degrees clockwise from north (0-360) 
* [ground.speed](http://vocab.nerc.ac.uk/collection/MVB/current/MVB000124/): ground speed in m/s
If not provided, these will be calculated from consecutive fixes as between-location speed and heading. Note that these calculated values are much less accurate than those provided as instantaneous measurements by the sensor, because they assume travel in a straight line between fixes, which becomes less likely as the sampling rate decreases.

Wind support, cross wind and airspeed are calculated and added to each location as described in [Safi et al. 2013](https://doi.org/10.1186/2051-3933-1-4): Flying with the wind: scale dependency of speed and direction measurements in modelling wind support in avian flight. Movement Ecology 1:4. In addition, GAMM models are fitted to airspeed and ground speed, indicating to which extent they are affected by wind support and cross wind. See details in the above-mentioned publication. We paste Figure 1 of this paper for understanding of the relationships between ground speed and airspeed:

![Screenshot 2023-05-05 at 11-26-58 Flying with the wind scale dependency of speed and direction measurements in modelling wind support in avian flight - Movement Ecology](https://user-images.githubusercontent.com/65662928/236422820-20a6d89e-e3d5-4a1b-8083-408822683315.png)

### Input data
move2 location object

### Output data
move2 location object

### Artefacts
`Wind_support_plots.pdf`: A 4-page PDF including histograms of air speed and ground speed as well as model results indicating influence of wind support and/or cross wind on ground speed and airspeed, respectively (plots and model estimates). Airspeed is the speed of the bird relative to the wind, and ground speed is the horizontal movement velocity, typically provided as instentaneous velocity by the sensor. 

### Settings
**Minimum ground speed for model building. (`minspeed`):** minimum ground speed (unit = m/s) of your tracked species. Only locations with speed more than it will be used for model building. Default: 4 m/s. However, all locations will be annotated and returned for use in a next App.

**Maximum ground speed for model building (`maxspeed`):** maximum ground speed (unit = m/s) of your tracked species. Only locations with speed less than it will be used for model building. Default: 25 m/s. However, all locations will be annotated and returned for use in a next App.

### Null or error handling:
**Setting `minspeed`:** this parameter only affects the model building. If it is too small or too large, the model might not converge or show unrealistic results.

**Setting `maxspeed`:** this parameter only affects the model building. If it is too small or too large, the model might not converge or show unrealistic results.

**Data:** The full data set with additional attributes is returned.
