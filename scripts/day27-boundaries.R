library(sf)
library(dplyr)
library(ggplot2)
library(MazamaSpatialUtils)
library(rnaturalearth)


# load built-in world time zone polygons
data("SimpleTimezones", package = "MazamaSpatialUtils")

tz_us <- SimpleTimezones |>
  dplyr::filter(countryCode == "US")

us_states <- rnaturalearth::ne_states(
  country     = "united states of america",
  returnclass = "sf"
)

crs_us_albers <- 5070

tz_us     <- st_transform(tz_us, crs_us_albers)
us_states <- st_transform(us_states, crs_us_albers)

conus <- us_states |>
  filter(!name %in% c("Alaska", "Hawaii", "Puerto Rico"))

conus_union <- st_union(conus)

tz_conus <- st_intersection(tz_us, conus_union)

# ----- NEW PART: collapse Olson time zones to 4 broad groups -----

tz_conus <- tz_conus |>
  mutate(
    tz_group = dplyr::case_when(
      # Pacific
      timezone %in% c(
        "America/Los_Angeles"
      ) ~ "Pacific",
      
      # Mountain
      timezone %in% c(
        "America/Denver",
        "America/Boise",
        "America/Phoenix"
      ) ~ "Mountain",
      
      # Central
      timezone %in% c(
        "America/Chicago",
        "America/Menominee",
        "America/Indiana/Knox",
        "America/North_Dakota/Center",
        "America/North_Dakota/New_Salem",
        "America/North_Dakota/Beulah"
      ) ~ "Central",
      
      # Eastern
      timezone %in% c(
        "America/New_York",
        "America/Detroit",
        "America/Indiana/Indianapolis",
        "America/Indiana/Vincennes",
        "America/Indiana/Winamac",
        "America/Indiana/Marengo",
        "America/Indiana/Petersburg",
        "America/Indiana/Vevay",
        "America/Kentucky/Louisville",
        "America/Kentucky/Monticello"
      ) ~ "Eastern",
      
      TRUE ~ NA_character_  # drop weird leftovers if any
    )
  ) |>
  filter(!is.na(tz_group)) |>
  mutate(
    tz_group = factor(tz_group,
                      levels = c("Pacific", "Mountain", "Central", "Eastern"))
  )

tz_plot     <- tz_conus
states_plot <- conus

ggplot() +
  geom_sf(
    data = tz_plot,
    aes(fill = tz_group),
    color = "white",
    linewidth = 0.3
  ) +
  geom_sf(
    data = states_plot,
    fill = NA,
    color = "grey20",
    linewidth = 0.2
  ) +
  coord_sf(expand = FALSE) +
  scale_fill_brewer(palette = "Set3", name = "Time zone") +
  labs(
    title    = "U.S. Time Zone Boundaries",
    subtitle = "Pacific, Mountain, Central, Eastern",
    caption  = "Time zone polygons: SimpleTimezones (MazamaSpatialUtils)"
  ) +
  theme_void() +
  theme(
    plot.title       = element_text(size = 15, hjust = 0.5, face = "bold"),
    plot.subtitle    = element_text(size = 7, hjust = 0.5),
    plot.caption     = element_text(size = 8),
    panel.grid       = element_blank(),
    legend.position  = "bottom",
    legend.title     = element_text(size = 8, face = "bold"),
    legend.text      = element_text(size = 6),
    legend.key.width = unit(1.3, "lines")
  )
ggsave("outputs/us_time_zones_broad.png",
       width = 6,
       height = 4,
       dpi = 300)
