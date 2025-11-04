library(tidyverse)
library(sf)

# Load your own spatial dataset
my_data <- st_read("data/day4/my-data.geojson")

# separate Hawaii into its own object
