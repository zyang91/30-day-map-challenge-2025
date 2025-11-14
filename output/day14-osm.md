# Day 14 of 30 Day Map Challenge - OpenStreetMap

**Day 14 (OpenStreetMap)**: I created a visualization of cafe hotspots in Philadelphia using OpenStreetMap data, showcasing the spatial distribution and density of coffee shops across the city. This map employs a grid-based approach to aggregate cafe locations into cells, creating a heatmap that reveals the concentration of cafes in different neighborhoods. The plasma color scheme with square root transformation effectively highlights areas with high cafe density while maintaining visibility of areas with fewer establishments.

The visualization uses the osmdata package to query OpenStreetMap's database for all cafes within Philadelphia's boundaries, then creates a fishnet grid to aggregate and display the density of these amenities. The result is a clear visual representation of Philadelphia's coffee culture geography, with the white city boundary providing context against the vibrant heatmap.

![](day14-osm.png)

**Technical Implementation:**
- **sf (Simple Features)** - R package for handling spatial vector data and geometric operations
- **osmdata** - R package for downloading and using OpenStreetMap data
- **tigris** - R package for downloading TIGER/Line shapefiles from the US Census Bureau
- **tidyverse** - R's ecosystem of packages for data manipulation and visualization
- **ggplot2** - R's powerful data visualization package (via tidyverse)

**Data Sources:**
- **Cafe Data**: [OpenStreetMap](https://www.openstreetmap.org/) - Cafe and coffee shop locations (amenity=cafe tag)
- **Philadelphia Boundary**: US Census Bureau TIGER/Line Shapefiles via the tigris package (2023)

**Coordinate Reference System:**
- `EPSG:4326` (WGS84) for OpenStreetMap data and final visualization
