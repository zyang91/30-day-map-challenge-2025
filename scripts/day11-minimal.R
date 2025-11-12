library(sf)
library(tidyverse)
library(leaflet)
library(htmltools)

# load data 
crash <- st_read("data/day11/crash1.geojson")

crash_ped<- crash %>%
  filter(PED_SUSP_SERIOUS_INJ_COUNT>0)%>%
  st_transform(4326)
university<- st_read("data/day11/university_city.geojson") %>%
  st_transform(4326)
# create leaflet map

# Title & caption controls

map_title <- tags$div(
  "Pedestrian Crashes in University City, Philadelphia (2014–2024)",
  style = "font-size:16px;font-weight:600;color:#000000;opacity:0.9;
           margin:6px 8px;letter-spacing:0.2px;pointer-events:none;"
)

map_caption <- tags$div(
  "Made by Zhanchao Yang",
  style = "font-size:11px;color:#000000;opacity:0.75;
           margin:0 8px 8px 0;pointer-events:none;"
)

leaflet(crash_ped, options = leafletOptions(preferCanvas = TRUE)) %>%
  addProviderTiles(providers$CartoDB.DarkMatter,
                   options = providerTileOptions(noWrap = TRUE)) %>%
  addMapPane("circles", zIndex = 430) %>%
  addCircleMarkers(
    radius = 5,
    stroke = TRUE,
    weight = 1,
    color = "#FF4D4D",     # halo
    fillColor = "#FF1A1A", # fill
    fillOpacity = 0.75,
    opacity = 0.9,
    options = pathOptions(pane = "circles"),
    clusterOptions = markerClusterOptions(
      spiderfyOnMaxZoom = TRUE,
      showCoverageOnHover = FALSE,
      zoomToBoundsOnClick = TRUE,
      disableClusteringAtZoom = 16
    )
  ) %>%
  addPolygons(
    data = university,
    color = "green",
    weight = 2,
    fill = FALSE)%>%
  addControl(map_title, position = "topright") %>%
  addControl(map_caption, position = "bottomright")
