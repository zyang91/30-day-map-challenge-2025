# Day 7 of 30 Day Map Challenge - Accessibility

**Day 7 (Accessibility)**: I created an interactive accessibility map comparing travel times from the Weitzman School of Design at the University of Pennsylvania (210 S 34th St, Philadelphia, PA 19104) at different times of day. This visualization demonstrates how accessibility changes between midday (12:00 PM) and evening rush hour (5:30 PM) using isochrone analysis. The map shows areas reachable within 5, 10, and 15 minutes from the location, revealing how traffic patterns significantly impact urban accessibility.

The visualization employs a side-by-side comparison using Mapbox GL JS, allowing users to interactively explore the differences between noon and rush hour travel times. The color-coded isochrones (red for 5 minutes, blue for 10 minutes, green for 15 minutes) make it easy to understand how the accessible area shrinks during peak traffic hours, highlighting the importance of time-of-day considerations in urban planning and accessibility analysis.

![](day7-accessbility.png)

**Technical Implementation:**
- **mapboxapi** - R package for accessing Mapbox APIs, including geocoding and isochrone services
- **mapgl** - R package for creating interactive Mapbox GL JS visualizations in R
- **Mapbox Isochrone API** - API service for calculating travel time polygons based on real-time traffic data

**Data Sources:**
- **Travel Time Data**: [Mapbox Isochrone API](https://docs.mapbox.com/api/navigation/isochrone/) - Real-time and predictive travel time calculations for September 11, 2025 at 12:00 PM and 5:30 PM
- **Base Map**: Mapbox vector tiles and street network data

**Analysis Parameters:**
- **Location**: Weitzman School of Design, University of Pennsylvania (210 S 34th St, Philadelphia, PA 19104)
- **Time Periods**: 12:00 PM (midday) vs. 5:30 PM (evening rush hour)
- **Travel Times**: 5, 10, and 15-minute isochrones
- **Date**: September 11, 2025
