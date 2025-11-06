options(rgl.useNULL = FALSE)

require(tidyverse)
require(sf)
require(tmap)
require(ggplot2)
require(mapview)
require(stars)
require(rayshader)
require(MetBrewer)
require(colorspace)
require(rayrender)
require(magick)
require(extrafont)

# Data download at https://data.humdata.org/dataset/kontur-population-germany
germany<- st_read("data/day6/germany.gpkg")
germany_bound<- st_read("data/day6/boundaries.gpkg")

germany <- germany %>%
  st_transform(crs = 3857)

germany_bound <- germany_bound %>%
  filter(name == "Berlin")%>%
  st_transform(crs = 3857)%>%
  st_geometry %>%
  st_union %>%
  st_sf %>%
  st_make_valid()

# germany_bound %>% 
#   ggplot()+
#   geom_sf()

berlin_hex <- st_intersection(germany, germany_bound)%>%
  st_transform(crs = 3857)

ggplot(berlin_hex) +
  geom_sf(aes(fill = population),
          color = "gray66",
          linewidth = 0) +
  geom_sf(
    data = germany_bound,
    fill = NA,
    color = "black",
    linetype = "dashed",
    linewidth = 1
  )


bbox <- st_bbox(germany_bound)

# finding the aspect ratio
bottom_left <- st_point(c(bbox[["xmin"]], bbox[["ymin"]])) %>%
  st_sfc(crs = 3857)
bottom_right <- st_point(c(bbox[["xmax"]], bbox[["ymin"]])) %>%
  st_sfc(crs = 3857)
top_left <- st_point(c(bbox[["xmin"]], bbox[["ymax"]])) %>%
  st_sfc(crs = 3857)
top_right <- st_point(c(bbox[["xmin"]], bbox[["ymax"]])) %>%
  st_sfc(crs = 3857)

width <- st_distance(bottom_left, bottom_right)
height <- st_distance(bottom_left, top_left)

if(width > height) {
  w_ratio = 1
  h_ratio = height / width
  
} else {
  h_ratio = 1.1
  w_ratio = width / height
}

size = 1000 * 3.5

pop_raster <- st_rasterize(
  berlin_hex,
  nx = floor(size * w_ratio) %>% as.numeric(),
  ny = floor(size * h_ratio) %>% as.numeric()
)

pop_matrix <- matrix(pop_raster$population,
                     nrow = floor(size * w_ratio),
                     ncol = floor(size * h_ratio))

color <- MetBrewer::met.brewer(name="Benedictus", direction = -1)

tx <- grDevices::colorRampPalette(color, bias = 4.5)(256)
swatchplot(tx)
swatchplot(color)

rgl::close3d()

pop_matrix %>%
  height_shade(texture = tx) %>%
  plot_3d(heightmap = pop_matrix,
          zscale = 250 / 4.5,
          solid = F,
          shadowdepth = 0)
render_camera(theta = 0,
              phi = 70,
              zoom = 0.55,
              fov = 100
)

# To interactively view the 3D plot
rgl::rglwidget()

outfile <- glue::glue("output/berlin.png")

{
  start_time <- Sys.time()
  cat(crayon::cyan(start_time), "\n")
  if(!file.exists(outfile)) {
    png::writePNG(matrix(1), target = outfile)
  }
  
  render_highquality(
    filename = outfile,
    interactive = F,
    lightdirection = 55, #Degree
    lightaltitude = c(30, 80),
    lightcolor = c("white", "white"),  # Set both lights to white
    lightintensity = c(600, 100),
    width = 1400,
    height = 1580,
    samples = 500
    #samples = 2
  )
  
  end_time <- Sys.time()
  diff <- end_time - start_time
  cat(crayon::cyan(diff), "\n")
}

pop_raster <- image_read("output/berlin.png")

text_color <- darken(color[3], .4)
swatchplot(text_color)

library(showtext)   
library(sysfonts)
# Automatically enable font support
showtext_auto()

# Download and register the Philosopher font from Google Fonts
font_add_google("Philosopher", regular = "400", bold = "700")

pop_raster %>%
  image_annotate("Berlin, Germany",
                 gravity = "northeast",
                 location = "+50+50",
                 color = text_color,
                 size = 120,
                 font = "Philosopher",
                 weight = 700,
                 # degrees = 0,
  ) %>%
  image_annotate("POPULATION DENSITY MAP",
                 gravity = "northeast",
                 location = "+50+175",
                 color = text_color,
                 size = 28.5,
                 font = "Philosopher",  # Corrected font name
                 weight = 500,
                 # degrees = 0,
  ) %>%
  image_annotate("Visualization by: Zhanchao Yang with Rayshader\nData: Kontur Population 2023",
                 gravity = "southwest",
                 location = "+20+20",
                 color = alpha(text_color, .8),
                 font = "Philosopher",  # Corrected font name
                 size = 25,
                 # degrees = 0,
  ) %>%
  image_write("Berlin.png", format = "png", quality = 100)


# Reference
# https://medium.com/@niloy.swe/how-to-create-a-3d-population-density-map-in-r-33dfaf7a71d7