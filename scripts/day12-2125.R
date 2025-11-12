library(sf)
library(tidyverse)
library(leaflet)
library(htmltools)

bound<- st_read("https://opendata.arcgis.com/datasets/405ec3da942d4e20869d4e1449a2be48_0.geojson")
bound <- st_transform(bound, crs = 2272)

water<- st_read("https://hub.arcgis.com/api/v3/datasets/2b10034796f34c81a0eb44c676d86729_1/downloads/data?format=geojson&spatialRefId=4326&where=1%3D1")
water <- st_transform(water, crs = 2272)
phila_water <- st_intersection(water, bound)

#buffer water with 100 meters
phila_water_buffer <- st_buffer(phila_water, dist = 100)%>%st_union()

city_fac<- st_read("https://hub.arcgis.com/api/v3/datasets/b3c133c3b15d4c96bcd4d5cc09f19f4e_0/downloads/data?format=geojson&spatialRefId=4326&where=1%3D1")

parks <- city_fac %>%
  filter(str_detect(ASSET_NAME, "Park")) %>%
  st_transform(crs = 2272)

# buffer parks with 500 meters
parks_buffer <- st_buffer(parks, dist = 500)%>%st_union()

ggplot() +
  geom_sf(data = bound, fill = NA, color = "black") +
  geom_sf(data = phila_water_buffer, fill = "#118ab2", color = NA, alpha = 0.5) +
  geom_sf(data = parks_buffer, fill = "#226f54", color = NA, alpha = 0.5) +
  theme_minimal() +
  labs(title = "Future Philadelphia (2125)",
       subtitle = "Visulized by Zhanchao Yang",
       caption = "Data Source: Philadelphia Open Data Portal") +
  theme_void()+
  theme(plot.background = element_rect(fill = "#f8edeb"),
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 8),
        plot.caption = element_text(size = 8))

# ggplot() +
#   geom_sf(data = bound, fill = NA, color = "black") +
#   geom_sf(data = phila_water, fill = "#118ab2", color = NA, alpha = 0.5) +
#   geom_sf(data = parks, fill = "#226f54", color = NA, alpha = 0.5) +
#   theme_minimal() +
#   labs(title = "Philadelphia",
#        subtitle = "Visulized by Zhanchao Yang",
#        caption = "Data Source: Philadelphia Open Data Portal") +
#   theme_void()+
#   theme(plot.background = element_rect(fill = "#f8edeb"),
#         plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
#         plot.subtitle = element_text(hjust = 0.5, size = 8),
#         plot.caption = element_text(size = 8))

map_title <- tags$div(
  "Philadelphia 2125",
  style = "font-size:16px;font-weight:600;color:#000000;opacity:0.9;
           margin:6px 8px;letter-spacing:0.2px;pointer-events:none;"
)

map_caption <- tags$div(
  "Made by Zhanchao Yang",
  style = "font-size:11px;color:#000000;opacity:0.75;
           margin:0 8px 8px 0;pointer-events:none;"
)
bound<- st_transform(bound, crs=4326)
parks_buffer<- st_transform(parks_buffer, crs = 4326)
phila_water_buffer<- st_transform(phila_water_buffer, crs = 4326)
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = bound, fill = NA, color = "black") %>%
  addPolygons(data = phila_water_buffer, fillColor = "#118ab2", color = NA, fillOpacity = 0.5) %>%
  addPolygons(data = parks_buffer, fillColor = "#226f54", color = NA, fillOpacity = 0.5)%>%
  addControl(map_title, position = "topright") %>%
  addControl(map_caption, position = "bottomright")




