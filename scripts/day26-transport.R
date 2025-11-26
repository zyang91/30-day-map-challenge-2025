# packages
library(sf)
library(tigris)     # for Chicago boundary, roads, water
library(tidyverse)

options(tigris_use_cache = TRUE)
tigris_cache_dir("data/tigris_cache")  # optional

# 1) Chicago city boundary (simplified)
chi_city <- places("IL", cb = TRUE, year = 2023) |>
  filter(NAME == "Chicago") |>
  st_transform(26916)   # NAD83 / UTM zone 16N – good for Chicago

# 2) Water (lakes, rivers) in Cook County
chi_water <- area_water("IL", "Cook") |>
  st_transform(st_crs(chi_city)) |>
  st_intersection(chi_city)       # clip to city

# 3) Roads in Cook County, then clip + keep only larger ones
chi_roads <- roads("IL", "Cook") |>
  st_transform(st_crs(chi_city)) |>
  st_intersection(chi_city) |>
  filter(RTTYP %in% c("I", "U", "S"))   # Interstates, US, State routes

transit<- "data/day25/CTA_RailLines.shp"
chi_transit <- st_read(transit) |>
  st_transform(st_crs(chi_city)) |>
  st_intersection(chi_city)


chi_cts <- chi_transit |>
  # clean up names a bit (optional)
  mutate(
    name_clean = str_replace_all(LINES, "\\s+Line", "")
  ) |>
  # detect each CTA color in the name string
  mutate(
    red    = str_detect(name_clean, regex("Red",    ignore_case = TRUE)),
    blue   = str_detect(name_clean, regex("Blue",   ignore_case = TRUE)),
    brown  = str_detect(name_clean, regex("Brown",  ignore_case = TRUE)),
    green  = str_detect(name_clean, regex("Green",  ignore_case = TRUE)),
    orange = str_detect(name_clean, regex("Orange", ignore_case = TRUE)),
    purple = str_detect(name_clean, regex("Purple", ignore_case = TRUE)),
    pink   = str_detect(name_clean, regex("Pink",   ignore_case = TRUE)),
    yellow = str_detect(name_clean, regex("Yellow", ignore_case = TRUE))
  ) |>
  # go from wide (one row with many TRUE/FALSE) to long
  pivot_longer(
    cols = red:yellow,
    names_to  = "cta_line",
    values_to = "has_line"
  ) |>
  # keep only colors actually present in name
  filter(has_line) |>
  # map short labels to pretty legend names
  mutate(
    cta_line = recode(cta_line,
                      red    = "Red Line",
                      blue   = "Blue Line",
                      brown  = "Brown Line",
                      green  = "Green Line",
                      orange = "Orange Line",
                      purple = "Purple Line",
                      pink   = "Pink Line")
  )


ggplot() +
  # city background
  geom_sf(data = chi_city, fill = "#050608", color = NA) +
  
  # water
  geom_sf(
    data  = chi_water,
    fill  = "#0b1f3b",
    color = NA,
    alpha = 0.9
  ) +
  
  # roads
  geom_sf(
    data      = chi_roads,
    color     = "#333333",
    linewidth = 0.2,
    alpha     = 0.8
  ) +
  
  # CTA lines with real colors
  geom_sf(
    data      = chi_cts,
    aes(color = cta_line),
    linewidth = 0.4
  ) +
  
  scale_color_manual(
    name   = "CTA Lines",
    values = c(
      "Red Line"    = "#C60C30",
      "Blue Line"   = "#00A1DE",
      "Brown Line"  = "#62361B",
      "Green Line"  = "#009B3A",
      "Orange Line" = "#F16E00",
      "Purple Line" = "#522398",
      "Pink Line"   = "#E27EA6"
    )
  ) +
  
  coord_sf(expand = FALSE) +
  labs(
    title    = "Chicago 'L' Transit Network",
    subtitle = "By Zhanchao Yang",
    caption  = "Data: CTA, US Census TIGER/Line (tigris)"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    text           = element_text(family = "Georgia"),
    panel.background = element_rect(fill = "#050608", color = NA),
    plot.background  = element_rect(fill = "#050608", color = NA),
    panel.grid       = element_blank(),
    axis.text        = element_blank(),
    axis.title       = element_blank(),
    plot.title       = element_text(face = "bold", colour = "white"),
    plot.subtitle    = element_text(colour = "grey80"),
    plot.caption     = element_text(colour = "grey60"),
    legend.background = element_rect(fill = "#050608", color = NA),
    legend.key        = element_rect(fill = "#050608", color = NA, linewidth =0.08),
    legend.text       = element_text(colour = "grey90", size=6),
    legend.title      = element_text(colour = "grey90",size=6),
    plot.margin      = margin(5, 5, 5, 5)
  )

ggsave("26_chicago_l_transit.png",
       width = 5.5,
       height = 6,
       dpi = 300)
