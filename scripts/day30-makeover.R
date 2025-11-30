library(duckdb)
library(tidyverse)
library(ggplot2)
library(sf)
library(mapproj)
library(showtext) # For custom fonts
library(scico)    # For scientifically accurate color palettes
library(scales)   # For label formatting
library(tidycensus)

font_add_google("Roboto Condensed", "roboto")
font_add_google("Merriweather", "serif_font")
showtext_auto()

con <- dbConnect(duckdb::duckdb(), dbdir = "data/day30/raw_data.duckdb")
dbListTables(con)


query <- "
  SELECT '2022' AS YEAR, STATE, AGE, INJ_SEV FROM person2022
"

result <- dbGetQuery(con, query)

result<- result %>%
  filter(AGE <18 & INJ_SEV==4)

result <- result %>%
  group_by(STATE) %>%
  summarise(count=n())



variables <- c(
  under_18_population = "B09001_001"
)

acs_under_18 <- get_acs(
  geography = "state",
  variables = variables,
  year = 2022,
  survey = "acs5"
)
acs_under_18$GEOID <- as.numeric(acs_under_18$GEOID)

state_fat <- left_join(acs_under_18, result, by= c("GEOID" = "STATE"))

state_fat <- state_fat %>%
  mutate(fatality_rate = count/estimate*100000)

state_dets <- read.csv('data/day30/state-details.csv')
state_dets$stusps <- substr(state_dets$stusps, 2, nchar(state_dets$stusps))
states_sf <- st_read('data/day30/us_states_hexgrid.gpkg') %>% left_join(state_dets, by=c('iso3166_2'='stusps')) %>%
  left_join(state_fat, by=c('st'='GEOID')) %>% st_transform(3857)#project to mercator pcs

threshold <- quantile(states_sf$fatality_rate, 0.6, na.rm=TRUE)
states_sf <- states_sf %>%
  mutate(text_color = ifelse(fatality_rate > threshold, "white", "black"))


ggplot(states_sf) +
  # Main Map Layer
  geom_sf(aes(fill = fatality_rate), color = "white", size = 0.4) +
  
  # Text Layer
  geom_sf_text(aes(label = iso3166_2, color = text_color), 
               family = "roboto", size = 3, fontface = "bold") +
  
  # Colors: Using a binned scale handles the breaks automatically.
  # "scico" package provides perceptually uniform palettes (lajolla is nice for heatmaps)
  scale_fill_scico(
    palette = "lajolla", 
    direction = 1,
    name = "Fatalities\n(per 100k)",
    # Creates 5 nice breaks automatically based on distribution
    trans = "reverse", # Optional: depending on if you want dark to be high
    n.breaks = 5
  ) +
  
  # Handle the text colors manually based on our calculation above
  scale_color_identity() + 
  
  # Theme
  theme_void() + # Removes axes, grids, and backgrounds automatically
  theme(
    text = element_text(family = "roboto", color = "#222222"),
    plot.title = element_text(family = "serif_font", face = "bold", size = 18, hjust = 0),
    plot.subtitle = element_text(size = 11, margin = margin(b = 15)),
    plot.caption = element_text(size = 8, color = "#666666", hjust = 1, margin = margin(t = 20)),
    
    # Legend formatting
    legend.position = "right",
    legend.title = element_text(size = 9, face = "bold"),
    legend.text = element_text(size = 8),
    legend.key.height = unit(1.5, "cm"), # Make legend bar tall/thin
    legend.key.width = unit(0.3, "cm")
  ) +
  
  # Labels
  labs(
    title = "Child Traffic Fatalities by State (2022)",
    subtitle = "Rate of fatalities (Ages 0-17) per 100,000 children.",
    caption = "Source: NHTSA FARS 2022 & ACS 5-Year Estimates\nVisualization: Zhanchao Yang"
  )
