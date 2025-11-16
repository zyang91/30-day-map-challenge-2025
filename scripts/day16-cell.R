library(tidycensus)
library(dplyr)
library(sf)
library(ggplot2)
library(stringr)


year_acs <- 2022  # you can change to 2021 / 2019 if you prefer

philly_wfh <- get_acs(
  geography = "tract",
  state     = "PA",
  county    = "Philadelphia",
  year      = year_acs,
  survey    = "acs5",
  geometry  = TRUE,
  output    = "wide",
  variables = c(
    total_workers = "B08301_001",
    wfh_workers   = "B08301_021"
  )
)


philly_wfh <- philly_wfh |>
  mutate(
    total_workers = total_workersE,
    wfh_workers   = wfh_workersE,
    wfh_share     = if_else(
      total_workers > 0,
      100 * wfh_workers / total_workers,
      NA_real_
    )
  ) |>
  select(GEOID, NAME, total_workers, wfh_workers, wfh_share, geometry)


philly_wfh <- st_transform(philly_wfh, 26918)



cell_size <- 1500  # ~1.5 km

philly_boundary <- st_union(philly_wfh)
grid_sf <- st_make_grid(
  philly_boundary,
  cellsize = cell_size,
  square   = TRUE
) |>
  st_as_sf() |>
  mutate(cell_id = row_number())

# ================================
# 5. Aggregate WFH share to grid cells
# ================================
# Each tract that intersects a cell is included; we then take the mean WFH share
# per cell (simple average; for a paper you'd probably do worker-weighted).
grid_wfh <- st_join(
  grid_sf,
  philly_wfh |>
    select(GEOID, wfh_share),
  join = st_intersects,
  left = FALSE   # keep only cells that intersect at least one tract
)

grid_wfh <- grid_wfh |>
  group_by(cell_id) |>
  summarize(
    wfh_mean = mean(wfh_share, na.rm = TRUE),
    .groups  = "drop"
  )

# Drop any NA cells (in case)
grid_wfh <- grid_wfh |>
  filter(!is.na(wfh_mean))


grid_centroids <- st_centroid(grid_wfh)


ggplot() +
  # Optional faint grid outline for context
  geom_sf(
    data  = grid_wfh,
    fill  = NA,
    color = "grey90",
    linewidth = 0.2
  ) +
  # Small circles at grid cell centroids, colored by WFH share
  geom_sf(
    data  = grid_centroids,
    aes(color = wfh_mean),
    size  = 1.4,   # tweak for tiny/bigger circles
    alpha = 0.95
  ) +
  scale_color_viridis_c(
    option  = "magma",
    direction = -1, 
    name    = "WFH share (%)",
    na.value = "grey90"
  ) +
  coord_sf(expand = FALSE) +
  labs(
    title    = "Work-From-Home Share in Philadelphia",
    subtitle = str_glue("Philadelphia County, ACS {year_acs} 5-year estimates"),
    caption  = "Data: U.S. Census Bureau, American Community Survey (ACS); map by Zhanchao Yang"
  ) +
  theme_void() +
  theme(
    plot.title    = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 9),
    plot.caption  = element_text(size = 6),
    legend.title  = element_text(size = 8),
    legend.text   = element_text(size = 7),
    legend.position = "right"
  )
