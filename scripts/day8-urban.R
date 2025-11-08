library(osmdata)
library(tidyverse)
library(sf)

# Define the bounding box for the area of interest (e.g., New York City)
bbox <- getbb("Seattle, USA")


# Query OSM for major highways in the defined bounding box
highways <- bbox %>%
  opq()%>%
  add_osm_feature(key = "highway", 
                  value=c("motorway", "trunk",
                          "primary","secondary", 
                          "tertiary","motorway_link",
                          "trunk_link","primary_link",
                          "secondary_link",
                          "tertiary_link")) %>%
  osmdata_sf()

ggplot() +
  geom_sf(data = highways$osm_lines,
          aes(color=highway),
          size = .4,
          alpha = .65)+
  theme_void()

streets <- bbox %>%
  opq()%>%
  add_osm_feature(key = "highway", 
                  value = c("residential", "living_street",
                            "service","unclassified",
                            "pedestrian", "footway",
                            "track","path")) %>%
  osmdata_sf()

ggplot() +
  geom_sf(data = streets$osm_lines,
          aes(color=highway),
          size = .4,
          alpha = .65)+
  theme_void()
min_lon <- bbox[1,1]
max_lon <- bbox[1,2]
min_lat <- bbox[2,1]
max_lat <- bbox[2,2]
color_roads <- rgb(0.42,0.449,0.488)
# ggplot() +
#   geom_sf(data = streets$osm_lines,
#           col = color_roads,
#           size = .4,
#           alpha = .65) +
#   geom_sf(data = highways$osm_lines,
#           col = color_roads,
#           size = .6,
#           alpha = .8)+
#   coord_sf(xlim = c(min_lon,max_lon),
#            ylim = c(min_lat,max_lat),
#            expand = FALSE)+
#   theme(legend.position = F) + theme_void()

library(tigris)
counties_WA <- counties(state="WA",cb=T,class="sf",)

counties_WA <- st_crop(counties_WA,
                       xmin=min_lon,xmax=max_lon,
                       ymin=min_lat,ymax=max_lat)

# ggplot() + 
#   geom_sf(data=counties_WA,fill="gray",lwd=0)+
#   coord_sf(xlim = c(min(bbox[1,]), max(bbox[1,])), 
#            ylim = c(min(bbox[2,]), max(bbox[2,])),
#            expand = FALSE)+
#   theme(legend.position = F) + theme_void()

get_water <- function(county_GEOID){
  area_water("WA", county_GEOID, class = "sf")
}
water <- do.call(rbind, 
                 lapply(counties_WA$COUNTYFP,get_water))

# ggplot() + 
#   geom_sf(data=counties_NY)+
#   geom_sf(data=water,
#           inherit.aes = F,
#           col="red")+
#   coord_sf(xlim = c(min(bbox[1,]), max(bbox[1,])), 
#            ylim = c(min(bbox[2,]), max(bbox[2,])),
#            expand = FALSE)+
#   theme(legend.position = F) + theme_void()

st_erase <- function(x, y) {
  st_difference(x, st_union(y))
}
counties_WA <- st_erase(st_union(counties_WA),water)

# ggplot() + 
#   geom_sf(data=counties_WA,
#           lwd=0)+
#   coord_sf(xlim = c(min(bbox[1,]), max(bbox[1,])), 
#            ylim = c(min(bbox[2,]), max(bbox[2,])),
#            expand = FALSE)+
#   theme(legend.position = F) + theme_void()

# ggplot() + 
#   geom_sf(data=counties_WA,
#           inherit.aes= FALSE,
#           lwd=0.0,fill=rgb(0.203,0.234,0.277))+
#   coord_sf(xlim = c(min(bbox[1,]), max(bbox[1,])), 
#            ylim = c(min(bbox[2,]), max(bbox[2,])),
#            expand = FALSE)+
#   theme(legend.position = F) + theme_void()+
#   theme(panel.background=
#           element_rect(fill = rgb(0.92,0.679,0.105)))+
#   ggtitle("Dark + Yellow theme")

final_map<-ggplot() + 
  geom_sf(data=counties_WA,
          inherit.aes= FALSE,
          lwd=0.0,fill=rgb(0.203,0.234,0.277))+
  geom_sf(data = streets$osm_lines,
          inherit.aes = FALSE,
          color=color_roads,
          size = .4,
          alpha = .65) +
  geom_sf(data = highways$osm_lines,
          inherit.aes = FALSE,
          color=color_roads,
          size = .6,
          alpha = .65) +
  coord_sf(xlim = c(min(bbox[1,]), max(bbox[1,])), 
           ylim = c(min(bbox[2,]), max(bbox[2,])),
           expand = FALSE) +
  theme(legend.position = F) + theme_void()+
  theme(panel.background=
          element_rect(fill = rgb(0.92,0.679,0.105)))

ggsave(final_map, 
       filename = "final_map.png",
       scale = 1, 
       width = 12, 
       height = 8, 
       units = "in",
       dpi = 500)

library(showtext)   
library(sysfonts)
require(magick)
# Automatically enable font support
showtext_auto()

# Download and register the Philosopher font from Google Fonts
font_add_google("Philosopher", regular = "400", bold = "700")
pop_raster <- image_read("/Users/zhanchaoyang/Desktop/final_map.png")
text_color <- "#0077b6"
pop_raster %>%
  image_annotate("Seattle, WA",
                 gravity = "northwest",
                 location = "+50+50",
                 color = text_color,
                 size = 120,
                 font = "Philosopher",
                 weight = 700,
                 # degrees = 0,
  ) %>%
  image_annotate("Street Network Map",
                 gravity = "northwest",
                 location = "+50+175",
                 color = text_color,
                 size = 28.5,
                 font = "Philosopher",  # Corrected font name
                 weight = 500,
                 # degrees = 0,
  ) %>%
  image_annotate("Visualization by: Zhanchao Yang with OpenStreetMap Data",
                 gravity = "southwest",
                 location = "+20+20",
                 color = alpha(text_color, .8),
                 font = "Philosopher",  # Corrected font name
                 size = 25,
                 # degrees = 0,
  ) %>%
  image_write("Seattle.png", format = "png", quality = 100)
