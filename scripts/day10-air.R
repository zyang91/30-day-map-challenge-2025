library(tidyverse)
library(sf)
library(anyflights)
library(igraph)
library(tidygraph)
library(ggraph)
library(ggplot2)
library(maps)

us_states <- map_data("state")

us_states_sf<- st_as_sf(map("state", plot = FALSE, fill = TRUE)) |>
  st_transform("ESRI:102003")

us_airports<-get_airports() |>
  select(1,3:4) |>
  st_as_sf(coords = c("lon", "lat"), crs = 4326) |>
  st_transform("ESRI:102003")

us_aiports<- us_airports |>
  st_intersection(us_states_sf)

coords<- st_coordinates(us_aiports)
us_aiports_df<- us_aiports |>
  mutate(X = coords[,1],
         Y = coords[,2]) |>
  st_drop_geometry() |>
  select(faa, X, Y)

station<-unique(us_aiports$faa)

options(timeout = 600)
us_flights<- get_flights(
  station=station,
  year = 2024,
  month = 10,
)

us_flights_distinct <- us_flights |>
  select(origin, dest) |>
  distinct()

vertices <- filter(
  us_aiports_df,
  faa %in% us_flights_distinct$origin & 
  faa %in% us_flights_distinct$dest
)

us_flights_distinct <- filter(
  us_flights_distinct,
  origin %in% vertices$faa & 
  dest %in% vertices$faa
)

# network graph
g <- igraph::graph_from_data_frame(
  d = us_flights_distinct,
  directed = TRUE,
  vertices = vertices
)

gr <- tidygraph::as_tbl_graph(g)  

map <- ggraph(
  gr,
  x = X,
  y = Y
) +
  geom_sf(
  data = us_states_sf,
  fill = "gray10",
  color = "white",
  linewidth=0.3
)+
  geom_edge_bundle_path(
    color = "cyan",
    width = 0.025,
    alpha = 0.4
  ) +
  coord_sf(crs = st_crs("ESRI:102003")) +
  theme_void()+
  labs(
    title = "US Flight Routes - October 2024",
    subtitle = "Made by Zhanchao Yang",
    caption = "Data Source: anyflights R package"
  )+
  theme(
    plot.background = element_rect(fill = "#344e41"),
    plot.title = element_text(color = "white", size = 20, hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(color = "white", size = 12, hjust = 0.5),
    plot.caption = element_text(color = "white", size = 8, hjust = 1)
  )

map