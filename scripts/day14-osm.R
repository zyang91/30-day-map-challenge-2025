library(sf)
library(osmdata)
library(tigris)
library(tidyverse)
# library(ggimage)

# Get all "places" in PA (cities, boroughs, etc.)
philly_places <- places(state = "PA", cb = TRUE, year = 2023)

# Filter to Philadelphia city
philly <- philly_places %>%
  filter(NAME == "Philadelphia")

philly_wgs <- st_transform(philly, 4326)
philly_bbox <- st_bbox(philly_wgs)

q_cafe <- opq(bbox = philly_bbox) %>%
  add_osm_feature(key = "amenity", value = "cafe")

cafe_osm <- osmdata_sf(q_cafe)


cafe_all <- cafe_osm$osm_points


coffee_all <- st_transform(cafe_all, st_crs(philly))
coffee_in_philly <- coffee_all[st_within(coffee_all, philly, sparse = FALSE), ]

coffee_in_philly <- coffee_in_philly %>%
  filter(!is.na(name))%>%
  filter(!is.na(`addr:city`))
  
philly_wgs  <- st_transform(philly, 4326)
coffee_wgs  <- st_transform(coffee_in_philly, 4326)

coffee_wgs <- coffee_wgs |>
  mutate(
    lon = st_coordinates(geometry)[, 1],
    lat = st_coordinates(geometry)[, 2]
  )

## Not successful map
# ggplot() +
#   # Philly boundary
#   geom_sf(data = philly_wgs, fill = NA, color = "#fb8500") +
#   
#   # Café icons
#   geom_image(
#     data = coffee_wgs,
#     aes(x = lon, y = lat),
#     image = "data/day14/starbucks.png",  # path to your icon
#     size  = 0.01,                   # tweak size as needed
#     asp   = 1
#   ) +
#   coord_sf(
#     xlim = st_bbox(philly_wgs)[c("xmin", "xmax")],
#     ylim = st_bbox(philly_wgs)[c("ymin", "ymax")]
#   ) +
#   labs(
#     title    = "Coffee Shops in Philadelphia",
#     subtitle = "Made by Zhanchao Yang",
#     caption  = "Data: OpenStreetMap contributors"
#   ) +
#   theme_void()+
#   theme(
#     plot.background = element_rect(fill = "#03045e"),
#     plot.title    = element_text(hjust = 0.5, size = 16, face = "bold", color = "white"),
#     plot.subtitle = element_text(hjust = 0.5, size = 8, color = "white"),
#     plot.caption  = element_text(size = 8, color = "white")
#   )

fishnet <- st_make_grid(
  philly_wgs,
  cellsize = 0.01,   # try 0.005 for finer detail
  square   = TRUE
) |>
  st_as_sf() |>
  rename(geometry = x)

# clip grid to Philly shape so no big outside rectangle
fishnet <- st_intersection(fishnet, philly_wgs)
fishnet$id <- seq_len(nrow(fishnet))


fishnet$n_cafe <- lengths(st_intersects(fishnet, coffee_wgs))

fishnet_plot <- fishnet  

ggplot() +
  geom_sf(
    data  = fishnet_plot,
    aes(fill = n_cafe),
    color = NA,
    linewidth = 0 
  ) +
  geom_sf(
    data  = philly_wgs,
    fill  = NA,
    color = "white",
    linewidth = 0.9
  ) +
  coord_sf(expand = FALSE) +
  labs(
    title = "Cafe Hotspots in Philadelphia",
    subtitle = "Made by Zhanchao Yang",
    caption = "Data: OpenStreetMap contributors"
  ) +
  scale_fill_viridis_c(option = "plasma", trans = "sqrt") +
  theme_void() +
  theme(
    legend.position  = "none",  # get rid of legend
    plot.background  = element_rect(fill = "#80b918", colour = NA),
    panel.background = element_rect(fill = "#80b918", colour = NA),
    plot.title       = element_text(
      hjust = 0.5, size = 16, face = "bold", colour = "white"
    ),
    plot.subtitle    = element_text(size = 8, colour = "white", hjust = 0.5),
    plot.caption     = element_text(size = 8, colour = "white", hjust = 1)
  )