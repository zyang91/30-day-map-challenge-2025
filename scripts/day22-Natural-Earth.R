library(terra)
library(geodata)
library(tidyterra)
library(ggplot2)
library(rnaturalearth)
library(sf)
library(viridis)

# 1) Download monthly mean temperature (tavg) at 10 arc-min resolution
#    WorldClim stores temperature as °C * 10
dir.create("data/worldclim", recursive = TRUE, showWarnings = FALSE)

tavg <- worldclim_global(var = "tavg", res = 10, path = "data/worldclim")


# 2) Mean across 12 months -> mean annual temperature
ann_mean <- app(tavg, mean, na.rm = TRUE) / 10  # convert to °C

# 3) Coastlines for reference
coast <- ne_coastline(scale = "medium", returnclass = "sf")

# 4) Plot
plot<- ggplot() +
  geom_spatraster(data = ann_mean) +
  scale_fill_viridis_c(name = "Temperature (°C)") +
  geom_sf(data = coast, color = "black", linewidth = 0.2, fill = NA) +
  coord_sf(expand = FALSE) +
  labs(
    title = "Mean Annual Temperature (1970–2000)",
    subtitle = "Long-term climatology",
    caption = "Data source: WorldClim v2.1"
  ) +
  theme_void()+
  theme(
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    plot.caption = element_text(size = 8),
    plot.background = element_rect(fill = "lightblue1", color = NA)
  )

ggsave("mean_annual_temperature.png", plot, width = 10, height = 6, dpi = 300)
