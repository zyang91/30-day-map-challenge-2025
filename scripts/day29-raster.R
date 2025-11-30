library(tigris)    # city boundary
library(terra)     # raster handling
library(FedData)   # NLCD download helper
library(dplyr)
library(ggplot2)
library(sf)
options(tigris_use_cache = TRUE)

# Places for Pennsylvania, then filter for Philadelphia city
philly <- places(state = "PA", year = 2023, cb = TRUE) |>
  filter(NAME == "Philadelphia") |>
  st_as_sf()          # tigris returns sf already in new versions; this is safe

# Transform to a projected CRS (FedData/NLCD is in Albers; this is fine as template)
philly_proj <- st_transform(philly, 5070)  # EPSG:5070 NAD83 / Conus Albers

# Get NLCD 2019 land cover cropped to Philly
nlcd_philly <- get_nlcd(
  template = philly_proj,          # the area to crop to
  label    = "philly_nlcd19",      # just a folder/filename label
  year     = 2019,
  dataset  = "landcover"           # standard land-cover product
)

# Ensure same CRS
nlcd_philly <- project(nlcd_philly, crs(philly_proj))

# Mask to city polygon (remove pixels outside the boundary)
nlcd_philly_city <- mask(crop(nlcd_philly, vect(philly_proj)), vect(philly_proj))

df <- as.data.frame(nlcd_philly_city, xy = TRUE, na.rm = TRUE)
names(df)[3] <- "nlcd_code"

pal <- c(
  "Open Water"                    = "#476BA0",
  "Developed, Open Space"         = "#DDC9C9",
  "Developed, Low Intensity"      = "#D89382",
  "Developed, Medium Intensity"   = "#ED0000",
  "Developed High Intensity"      = "#AA0000",  # note: no comma in your label
  "Barren Land (Rock/Sand/Clay)"  = "#B2ADA3",
  "Deciduous Forest"              = "#68AB5F",
  "Evergreen Forest"              = "#1C5F2C",
  "Mixed Forest"                  = "#B5C58F",
  "Shrub/Scrub"                   = "#E3E3C2",
  "Grassland/Herbaceous"          = "#EFEBAF",
  "Pasture/Hay"                   = "#FFD37F",
  "Cultivated Crops"              = "#EFBF3A",
  "Woody Wetlands"                = "#C8E6F8",
  "Emergent Herbaceous Wetlands"  = "#64B3D5"
)

df$nlcd_code <- factor(df$nlcd_code)

ggplot(df) +
  geom_raster(aes(x = x, y = y, fill = nlcd_code)) +
  scale_fill_manual(
    values = pal,
    name   = "Land cover",
    breaks = intersect(levels(df$nlcd_code), names(pal))  # only shared levels
  ) +
  labs(
    title = "Land Cover in Philadelphia, PA (NLCD 2019)",
    subtitle = "Visualization by Zhanchao Yang",
  ) +
  coord_equal() +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 15, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 9),
    plot.background = element_rect(fill = "white", color = NA),
    legend.background = element_rect(fill = "white", color = NA),
    legend.key.size = unit(0.3, "cm"),
    legend.text = element_text(size = 6),
    legend.title = element_text(size = 8)
  )

ggsave("output/day29_philly_nlcd19.png", width = 6, height = 5, dpi = 300)
