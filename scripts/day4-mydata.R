library(dplyr)
library(sf)
library(cowplot)
library(ggplot2)
library(sysfonts)
library(showtext)

# Load your own spatial dataset
my_data <- st_read("data/day4/my-data.geojson")

# separate Hawaii into its own object
state_boundary<- st_read("data/day4/cb_2024_us_state_5m.shp")

hawaii <- state_boundary %>%
  filter(NAME == "Hawaii")
mainland <- state_boundary %>%
  filter(NAME != "Hawaii" & NAME != "Alaska" & NAME != "Puerto Rico" & NAME != "United States Virgin Islands" & NAME != "Guam")
mainland <- mainland %>%
  filter(NAME != "Commonwealth of the Northern Mariana Islands" & NAME != "American Samoa")

data<- my_data%>%
  st_transform(st_crs(mainland))

data_hawaii<- st_intersection(data, st_union(hawaii))
data_mainland<- st_intersection(data, st_union(mainland))


crs_us <- 5070
crs_hi <- 6633
mainland      <- st_transform(mainland, crs_us)
hawaii        <- st_transform(hawaii, crs_hi)
data_mainland <- st_transform(data_mainland, crs_us)
data_hawaii   <- st_transform(data_hawaii, crs_hi)
data<- st_transform(data, crs_us)




# Plot
font_add_google("Playfair Display", "playfair")   # elegant serif
showtext_auto()

p_main <- ggplot() +
  geom_sf(data = mainland, fill = "#cce3de", color = "white", linewidth = 0.2) +
  geom_sf(data = data_mainland, color = "#7678ed", linewidth = 0.7) +
  labs(
    title = "My Spatial Footprint across US",
    subtitle = "Author: Zhanchao Yang"
  ) +
  coord_sf(crs = st_crs(crs_us)) +
  theme_void() +
  theme(
    plot.title = element_text(family = "playfair", size = 20, face = "bold", hjust = 0.5, margin = margin(b = 10)),
    plot.subtitle = element_text(family = "playfair", size = 10, hjust = 0.5, margin = margin(b = 10))
  )

# 3) Build the Hawaii plot (same CRS so it looks consistent)
p_hi <- ggplot() +
  geom_sf(data = hawaii, fill = "#43aa8b", color = "white", linewidth = 0.2) +
  geom_sf(data = data_hawaii, color = "#7678ed", linewidth = 0.7) +
  labs(
    title = NULL,
    subtitle = NULL
  ) +
  coord_sf(crs = st_crs(crs_us)) +
  theme_void() +
  theme(plot.margin = margin(0,0,0,0))


# size & padding
inset_w <- 0.25
inset_h <- 0.25
margin  <- 0

# bottom-right placement
inset_x <- 1 - inset_w - margin
inset_y <- margin

final_plot <- ggdraw() +
  draw_plot(p_main) +
  draw_plot(p_hi, x = 0.04, y = 0.04, width = 0.24, height = 0.24) 

final_plot
