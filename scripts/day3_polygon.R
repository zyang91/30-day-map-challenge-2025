library(tidyverse)
library(tidycensus)
library(sf)
library(scales)

# Set your Census API key
# census_api_key("YOUR_CENSUS_API_KEY_HERE")

# get census data
census_data <- get_acs(
  geography = "tract",
  variables = c(population = "B01003_001"),
  state = "PA",
  county = "Philadelphia",
  geometry = TRUE,
  year = 2023
)

# print crs
# st_crs(census_data)

# transform to projected crs for accurate area calculation
census_data <- st_transform(census_data, crs = 2272) # NAD83 / Pennsylvania South (ftUS)

# calculate population density
census_data <- census_data %>%
  mutate(
    area_sq_km= st_area(geometry) %>% set_units("km^2"),
    pop_density = estimate / area_sq_km
  )

library(units)
census_data$pop_density <- drop_units(census_data$pop_density)

# using ntile to create quantile-based bins for better visualization
census_data <- census_data %>%
  mutate(
    pop_density_bin = ntile(pop_density, 5)
  )


# Overlay with water
# get water data
water<- st_read("https://hub.arcgis.com/api/v3/datasets/2b10034796f34c81a0eb44c676d86729_1/downloads/data?format=geojson&spatialRefId=4326&where=1%3D1")
water <- st_transform(water, crs = 2272)
water_phila<- st_intersection(water, st_union(census_data))


qs <- quantile(census_data$pop_density,
               probs = seq(0, 1, by = 0.2), na.rm = TRUE)

labs <- paste0(comma(round(qs[-length(qs)])),
               " – ",
               comma(round(qs[-1])))

labs_named <- setNames(labs, as.character(1:5))

ggplot(data = census_data) +
  geom_sf(aes(fill = factor(pop_density_bin)), color = NA) +
  scale_fill_manual(
    values = c("1"="#ffccd5","2"="#ffb3c1","3"="#ff758f","4"="#c9184a","5"="#800f2f"),
    breaks = c("1","2","3","4","5"),
    labels = labs_named,
    drop = FALSE,
    name = "People per km²"
  ) +
  geom_sf(data = water_phila, fill = "#3f88c5", color = NA, alpha = 0.5) +
  labs(
    title = "Population Density by Census Tract in Philadelphia",
    subtitle = "Data Source: 2023 ACS 5-Year Estimates",
    caption = "Visualization by Zhanchao Yang"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12),
    plot.caption = element_text(size = 8, hjust = 0),
    legend.position = "right"
  )
