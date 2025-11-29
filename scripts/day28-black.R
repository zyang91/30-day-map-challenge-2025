library(blackmarbler)
library(sf)
library(terra)
library(ggplot2)
library(tidyterra)
library(lubridate)
library(geodata)

bearer <- "eyJ0eXAiOiJKV1QiLCJvcmlnaW4iOiJFYXJ0aGRhdGEgTG9naW4iLCJzaWciOiJlZGxqd3RwdWJrZXlfb3BzIiwiYWxnIjoiUlMyNTYifQ.eyJ0eXBlIjoiVXNlciIsInVpZCI6InpoYW5jaGFvOTEiLCJleHAiOjE3Njk2NDI2NTksImlhdCI6MTc2NDQ1ODY1OSwiaXNzIjoiaHR0cHM6Ly91cnMuZWFydGhkYXRhLm5hc2EuZ292IiwiaWRlbnRpdHlfcHJvdmlkZXIiOiJlZGxfb3BzIiwiYWNyIjoiZWRsIiwiYXNzdXJhbmNlX2xldmVsIjozfQ.Nlxk5YAtE0BWoc3n2y8fk17O9uh9hI0cHFddeZMGXloQy1V80CVE8pqAs4H36KpOwHt0IcYwhSzDgkYuM0ynVbP4NJIXY6wNzVRDDuiebQozrNpAnQrFzoDGmJBumCgzf_4LmUsvKntQ9c1G6nc0AJI9m-IfAm78SuPxTWweaU3fkkhzHKFS498t6Uj5KbDdj3SNf5ySHa1Eq_yIi6kPZadouZ4DKl-Qsn2T7U5hJJ5MWuXNhMAKA55rrg11oB4LBQ1HAp5d1rvBand_Bo83ivlBCbZX6UH1fa6kCIScgGbYoNVlTnfwrZvEZyBrKxu0WnqzleWGxkEYuhblhwzkRA"

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
