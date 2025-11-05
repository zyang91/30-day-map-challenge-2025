# Day 5 of 30 Day Map Challenge - Earth

**Day 5 (Earth)**: I created a shaded relief map of Pennsylvania using digital elevation data, showcasing the state's diverse topography from the Appalachian Mountains to the lower-lying regions. This visualization combines hypsometric tinting with advanced ray-tracing and ambient shading techniques through the rayshader package, creating a three-dimensional appearance that emphasizes Pennsylvania's rugged terrain and elevation changes.

The map employs the Imhof color scheme for terrain representation, which provides an intuitive visual hierarchy where elevation differences are immediately apparent. The combination of directional ray shading (from 315° azimuth) and ambient occlusion creates realistic depth perception, making valleys, ridges, and plateaus stand out prominently.

![](day5_earth.png)

**Technical Implementation:**
- **elevatr** - R package for accessing elevation data from the USGS 3D Elevation Program (3DEP)
- **rayshader** - R package for creating advanced 2D and 3D data visualizations with ray-tracing and ambient occlusion
- **terra** - R package for spatial data analysis and raster processing
- **sf (Simple Features)** - R package for handling spatial vector data and geometric operations
- **tigris** - R package for accessing TIGER/Line shapefiles from the U.S. Census Bureau
- **ggplot2** - R's powerful data visualization package, extended with `geom_sf()` and `geom_raster()` for mapping
- **viridis** - R package providing perceptually uniform color scales
- **dplyr** - R package for data manipulation and transformation

**Data Sources:**
- **Elevation Data**: [USGS 3D Elevation Program (3DEP)](https://www.usgs.gov/3d-elevation-program) - High-resolution digital elevation model accessed via elevatr package at zoom level 10
- **State Boundaries**: [U.S. Census Bureau TIGER/Line Cartographic Boundary Files](https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html) - 2023 State Boundaries

**Coordinate Reference System:**
- EPSG:2272 (Pennsylvania State Plane South, NAD83, US Feet) for accurate local representation

