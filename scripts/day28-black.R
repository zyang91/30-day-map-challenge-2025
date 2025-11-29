library(blackmarbler)
library(sf)
library(terra)
library(ggplot2)
library(tidyterra)
library(lubridate)
library(geodata)

bearer <- "Your_token"

#get Canada boundary as sf
roi_sf <- geodata::gadm(country = "CAN", level = 0, path = "data/gadm") |>
  st_as_sf() |>
  st_transform(crs = 4326)

r_20210205 <- bm_raster(roi_sf = roi_sf,
                        product_id = "VNP46A2",
                        date = "2021-02-05",
                        bearer = bearer)

#### Prep data
r_20210205 <- r_20210205 |> terra::mask(roi_sf)

## Distribution is skewed, so log
r_20210205[] <- log(r_20210205[] + 1)

ggplot() +
  geom_spatraster(data = r_20210205) +
  scale_fill_gradient2(low = "black",
                       mid = "yellow",
                       high = "red",
                       midpoint = 4.5,
                       na.value = "transparent") +
  labs(title = "Nighttime Lights (Canada): October 2021",
       subtitle = "Made by Zhanchao Yang") +
  coord_sf() +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size=8,hjust = 0.5),
        legend.position = "none")
