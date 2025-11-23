library(tidyverse)
library(sf)
library(tigris)
library(ggplot2)
library(ggimage)
library(fontawesome)
library(rsvg)

options(tigris_use_cache = TRUE)

# 1) Airports (OurAirports; updated nightly)
air_url <- "https://ourairports.com/countries/US/airports.csv"
air_raw <- readr::read_csv(air_url, show_col_types = FALSE)

air_pa_ny <- air_raw %>%
  filter(iso_region %in% c("US-PA", "US-NY")) %>%   # PA + NY
  filter(type != "closed") %>%                      # operational only
  filter(!is.na(latitude_deg), !is.na(longitude_deg))%>%
  filter(type=="large_airport"|type=="medium_airport")

air_sf <- st_as_sf(
  air_pa_ny,
  coords = c("longitude_deg", "latitude_deg"),
  crs = 4326,
  remove = FALSE
)

# 2) State outlines for context
states_sf <- tigris::states(cb = TRUE, year = 2023) %>%
  filter(STUSPS %in% c("PA","NY")) %>%
  st_transform(4326)

svg_url <- "https://upload.wikimedia.org/wikipedia/commons/7/7d/Plane_icon.svg"

svg_file <- tempfile(fileext = ".svg")
png_file <- tempfile(fileext = ".png")

download.file(svg_url, svg_file, mode = "wb")
rsvg_png(svg_file, file = png_file, width = 64, height = 64)

air_sf <- air_sf %>% mutate(image = png_file)


# 4) Plot
bb <- st_bbox(states_sf)

ggplot() +
  geom_sf(data = states_sf, fill = "#a3b18a", color = "grey40", linewidth = 0) +
  geom_image(
    data = air_sf,
    aes(x = longitude_deg, y = latitude_deg, image = image),
    size = 0.02,   # icon size (increase if you want bigger planes)
    by = "width"
  ) +
  theme_void() +
  labs(title = "Medium and Large Airports in Middle States",
       caption = "Made by Zhanchao Yang")+
  theme(
    plot.title = element_text(hjust = 0.5, size = 15, face = "bold"),
    plot.background = element_rect(fill = "white", color = NA),
    plot.caption = element_text(hjust = 0.5, size = 10, face = "italic")
  ) 
