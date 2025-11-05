library(sf)
library(tigris)
library(terra)
library(elevatr)
library(ggplot2)
library(viridis)
library(dplyr)        
options(rgl.useNULL = TRUE)
library(rayshader)

options(tigris_use_cache = TRUE)

pa <- states(cb = TRUE, year = 2023) |>
  subset(NAME == "Pennsylvania") |>
  st_as_sf() |>
  st_transform(2272)

# ---- DEM ----
dem_r <- get_elev_raster(
  locations = st_transform(pa, 4326),
  z = 10,
  clip = "locations",
  expand = 0.05
)

target_wkt <- sf::st_crs(pa)$wkt
dem <- terra::rast(dem_r) |> terra::project(target_wkt)
dem <- terra::mask(terra::crop(dem, terra::vect(pa)), terra::vect(pa))

# ---- Shading ----
dem_mat <- matrix(values(dem), nrow = nrow(dem), ncol = ncol(dem), byrow = TRUE)
ray  <- ray_shade(dem_mat, sunangle = 315, zscale = 1, maxsearch = 100)
amb  <- ambient_shade(dem_mat, zscale = 1)
base <- sphere_shade(dem_mat, texture = "imhof2")
hill_rgb <- base |> add_shadow(ray, 0.55) |> add_shadow(amb, 0.35)

# ---- Raster -> data.frame ----
ext <- ext(dem)
xs  <- seq(ext[1], ext[2], length.out = ncol(dem))
ys  <- seq(ext[3], ext[4], length.out = nrow(dem))

hill_df <- expand.grid(x = xs, y = rev(ys))
hill_df$R <- as.vector(hill_rgb[,,1])
hill_df$G <- as.vector(hill_rgb[,,2])
hill_df$B <- as.vector(hill_rgb[,,3])

# Keep 0–255 scale and build hex colors directly
# ---- Build safe color column ----
hill_df_plot <- hill_df |>
  dplyr::mutate(
    R = as.numeric(R),
    G = as.numeric(G),
    B = as.numeric(B)
  ) |>
  # remove any rows with NA in any channel BEFORE calling rgb()
  dplyr::filter(is.finite(R) & is.finite(G) & is.finite(B))

# auto-detect whether channels are in 0–1 or 0–255
scale_max <- if (max(hill_df_plot$R, hill_df_plot$G, hill_df_plot$B, na.rm = TRUE) <= 1.1) 1 else 255

hill_df_plot <- hill_df_plot |>
  dplyr::mutate(
    # clamp to the detected scale
    R = pmin(pmax(R, 0), scale_max),
    G = pmin(pmax(G, 0), scale_max),
    B = pmin(pmax(B, 0), scale_max),
    col = rgb(R, G, B, maxColorValue = scale_max)
  )


pa_outline <- st_cast(st_boundary(pa), "MULTILINESTRING")

ggplot() +
  geom_raster(data = hill_df_plot, aes(x = x, y = y, fill = col)) +
  scale_fill_identity(guide = "none") +
  geom_sf(data = pa_outline, color = "black", linewidth = 0.4, fill = NA) +
  coord_sf(crs = st_crs(pa), expand = FALSE) +  # <-- keep everything in EPSG:5070
  labs(
    title = "Pennsylvania • Shaded Relief (USGS 3DEP)",
    subtitle = "Hypsometric tint + ray & ambient shading",
    caption = "Sources: USGS 3DEP via elevatr; Boundary: TIGER/Cartographic"
  ) +
  theme_void(base_family = "Helvetica") +
  theme(
    plot.title    = element_text(hjust = 0.5, size = 16, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 11),
    plot.caption  = element_text(hjust = 0.5, size = 9),
    plot.margin   = margin(6,6,6,6)
  )





