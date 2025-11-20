# Install once if needed:
# install.packages(c("sf", "tigris", "hrbrthemes", "tidyverse"))

library(sf)
library(tigris)
library(tidyverse)

options(tigris_use_cache = TRUE)


pal <- c(
  "#366cff", "#4476ff", "#517fff", "#5f89ff", "#6c93ff", "#799dff", "#87a7ff", "#94b1ff",
  "#a1baff", "#afc4ff", "#bcceff", "#cad8ff", "#d7e2ff", "#e4ebff", "#f2f5ff", "#ffffff"
)

de_counties <- counties(
  state = "NY",      
  cb    = TRUE,      
  class = "sf"
)

# County names we’ll iterate over for water features
county_names <- de_counties$NAME %>% unique()


de_aw <- county_names %>%
  map(~ area_water(
    state  = "NY",
    county = .x,
    class  = "sf"
  ) %>%
    mutate(county = .x)) %>%
  do.call(rbind, .)


de_rv <- county_names %>%
  map(~ linear_water(
    state  = "NY",
    county = .x,
    class  = "sf"
  ) %>%
    mutate(county = .x)) %>%
  do.call(rbind, .)

# Emphasize features whose FULLNAME ends with River/Rive/Riv
de_rv <- de_rv %>%
  mutate(
    sz = ifelse(grepl("(River|Rive|Riv)$", FULLNAME), 0.25, 0.04)
  )


plot<-ggplot() +
  geom_sf(data = st_union(de_counties), fill = "white", color = "#04005e", size = 0.125) +
  geom_sf(data = de_aw, size = 0, fill = "#04005e", color = NA, show.legend = FALSE) +
  geom_sf(data = de_rv, aes(size = I(sz)), color = "#04005e", fill = NA, show.legend = FALSE) +
  coord_sf(datum = NA) +
  labs(
    title   = "New York Hydrology",
    subtitle = "Made by Zhanchao Yang",
    caption = "Inspired by Bob Rudis"
  ) +
  theme_void() +
  theme(
    plot.title    = element_text(size = 20, color = "white", hjust = 0.5),
    plot.subtitle = element_text(size = 10, color = "white", hjust = 0.5),
    plot.caption  = element_text(size = 8, color = "white", hjust = 0.5),
    plot.background  = element_rect(color = "#04005e", fill = "#04005e"),
    panel.background = element_rect(color = "#04005e", fill = "#04005e")
  )

ggsave(plot, filename = "Daleware-water-2.png", width = 10, height = 10, dpi = 300)
