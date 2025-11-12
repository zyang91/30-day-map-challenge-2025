# Day 11 of 30 Day Map Challenge - Minimal

**Day 11 (Minimal)**: I created a minimalist interactive map visualizing pedestrian crashes in University City, Philadelphia from 2014 to 2024. This visualization embraces the "less is more" philosophy of minimal design by using a dark basemap with simple red circular markers to represent crash locations, creating a stark and impactful visual that immediately draws attention to areas of pedestrian safety concern.

The map uses a dark CartoDB basemap to provide high contrast with the red crash markers, allowing the data to stand out clearly without visual clutter. The minimal design approach focuses on essential elements: crash locations are shown as clustered markers that expand when zoomed in, and the University City boundary is outlined in green to provide geographic context. No unnecessary decorations or complex symbology distract from the core message about pedestrian safety.

![](day11-minimal.png)

**Technical Implementation:**
- **sf (Simple Features)** - R package for handling spatial vector data and geometric operations
- **tidyverse** - R's ecosystem of packages for data manipulation and visualization
- **leaflet** - R package for creating interactive web maps
- **htmltools** - R package for generating HTML elements and controls

**Data Sources:**
- **Crash Data**: Pedestrian crash data for University City, Philadelphia (2014-2024) - filtered to include only crashes with pedestrian suspected serious injuries
- **Boundary Data**: University City administrative boundary in GeoJSON format

**Coordinate Reference System:**
- `EPSG:4326` (WGS 84) for web mapping and leaflet compatibility
