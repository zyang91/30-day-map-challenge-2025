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

# shifted to leaflet as my mapboxapi doesn't work
library(leaflet)
library(sf)
library(dplyr)

leaflet() |>
  addTiles() |>
  addPolygons(
    data = st_transform(iso_12pm, 4326),
    fillColor = ~case_when(
      time == 5 ~ "red",
      time == 10 ~ "blue",
      time == 15 ~ "green"
    ),
    fillOpacity = 0.5,
    color = "black",
    weight = 1,
    group = "12 PM Isochrone"
  ) |>
  addPolygons(
    data = st_transform(iso_530pm, 4326),
    fillColor = ~case_when(
      time == 5 ~ "red",
      time == 10 ~ "blue",
      time == 15 ~ "green"
    ),
    fillOpacity = 0.5,
    color = "black",
    weight = 1,
    group = "5:30 PM Isochrone"
  ) |>
  addMarkers(
    data = st_transform(weitzman_sf, 4326),
    popup = weitzman
  ) |>
  addLayersControl(
    overlayGroups = c("12 PM Isochrone", "5:30 PM Isochrone"),
    options = layersControlOptions(collapsed = FALSE)
  )%>%
  addLegend(
    position = "bottomright",
    colors = c("red", "blue", "green"),
    labels = c("5 minutes", "10 minutes", "15 minutes"),
    title = "Access Time"
  )
