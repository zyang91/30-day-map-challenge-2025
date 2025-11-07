library(mapboxapi)
library(mapgl)

weitzman <- "210 S 34th St, Philadelphia, PA 19104"

weitzman_sf <- mb_geocode(weitzman, output = "sf")

iso_12pm <- mb_isochrone(
  weitzman,
  depart_at = "2025-09-11T12:00"
)

iso_530pm <- mb_isochrone(
  weitzman,
  depart_at = "2025-09-11T17:30"
)

map1<-mapboxgl(bounds = iso_12pm) |>
  add_fill_layer(
    "noon",
    source = iso_12pm,
    fill_color = match_expr(
      column = "time",
      values = c(5, 10, 15),
      stops = c("red", "blue", "green")
    ),
    fill_opacity = 0.75
  ) |>
  add_markers(
    data = weitzman_sf
  )

map2 <- mapboxgl(bounds = iso_12pm) |> 
  add_fill_layer(
    "rush_hour",
    source = iso_530pm,
    fill_color = match_expr(
      column = "time",
      values = c(5, 10, 15),
      stops = c("red", "blue", "green")
    ),
    fill_opacity = 0.75
  ) |> 
  add_markers(
    data = weitzman_sf
  )

compare(map1, map2, swiper_color = "green") |>
  add_legend(
    "Access (12pm vs. 5:30pm)",
    values = c("5 minutes", "10 minutes", "15 minutes"),
    colors = c("red", "blue", "green"),
    patch_shape = iso_530pm[1,],
    type = "categorical",
    style = legend_style(
      background_opacity = 0.8
    )
  )