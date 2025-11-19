library(tidyverse)
library(rnaturalearth)
library(sf)
library(ggplot2)
  

proj <- "+proj=peirce_q +lon_0=25 +shape=square"




world <- ne_countries(scale = "medium",returnclass = "sf") %>% 
  st_transform(crs = proj)
  


ggplot() +
  geom_sf(data = world, fill = "tan", color = "antiquewhite") + 
  labs(title = "The World on the Peirce Quincuncial Projection",
       subtitle = "Visulized by Zhanchao Yang"
) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold",
                                    size = 14,
                                    hjust = 0.5,
                                    margin = margin(0, 0, -5, 0),
                                    family = "AppleGothic"),
        plot.subtitle = element_text(size = 10,
                                     hjust = 0.5,
                                     margin = margin(10, 0, 10, 0),
                                     family = "AppleGothic"),
        panel.background = element_rect(fill = "#caf0f8", colour = NA),
        plot.background = element_rect(fill = "#caf0f8", colour = NA)
)
  
  




