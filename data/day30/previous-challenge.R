library(duckdb)
library(tidyverse)
library(ggplot2)
library(sf)
library(mapproj)
mapTheme <- theme(plot.title =element_text(size=12),
                  plot.subtitle = element_text(size=8),
                  plot.caption = element_text(size = 6),
                  axis.line=element_blank(),
                  axis.text.x=element_blank(),
                  axis.text.y=element_blank(),
                  axis.ticks=element_blank(),
                  axis.title.x=element_blank(),
                  axis.title.y=element_blank(),
                  panel.background=element_blank(),
                  panel.border=element_blank(),
                  panel.grid.major=element_line(colour = 'transparent'),
                  panel.grid.minor=element_blank(),
                  legend.direction = "vertical",
                  legend.position = "right",

                  legend.key.height = unit(1, "cm"), legend.key.width = unit(0.2, "cm"))
q5 <- function(variable) {as.factor(ntile(variable, 5))}
flatreds5 <- c('#f9ebea','#e6b0aa','#c2665b', '#a33428','#7b241c')
qBr <- function(df, variable, rnd) {
  if (missing(rnd)) {
    as.character(quantile(round(df[[variable]],3),
                          c(.01,.2,.4,.6,.8), na.rm=T))
  } else if (rnd == FALSE | rnd == F) {
    as.character(formatC(quantile(df[[variable]],
                                  c(.01,.2,.4,.6,.8), na.rm=T),
                         digits = 3))
  }
}
current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path ))
con <- dbConnect(duckdb::duckdb(), dbdir = "raw_data.duckdb")
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

library(tidycensus)

variables <- c(
  under_18_population = "B09001_001"
)

acs_under_18 <- get_acs(
  geography = "state",
  variables = variables,
  year = 2022,
  survey = "acs5"
)
str(acs_under_18)
acs_under_18$GEOID <- as.numeric(acs_under_18$GEOID)

state_fat <- left_join(acs_under_18, result, by= c("GEOID" = "STATE"))

state_fat <- state_fat %>%
  mutate(fatality_rate = count/estimate*1000)

state_dets <- read.csv('./state-details.csv')
state_dets$stusps <- substr(state_dets$stusps, 2, nchar(state_dets$stusps))
states_sf <- st_read('./us_states_hexgrid.gpkg') %>% left_join(state_dets, by=c('iso3166_2'='stusps')) %>%
  left_join(state_fat, by=c('st'='GEOID')) %>% st_transform(3857)#project to mercator pcs
text_inv <- c('black', 'white','white','white','white')

ggplot(states_sf) +
  geom_sf(aes(fill= q5(fatality_rate)), color='white') +
  scale_fill_manual(values = flatreds5,
                    labels = qBr(states_sf, 'fatality_rate'),
                    name = 'Children Traffic Fatality rate') +
  geom_sf_text(aes(label = iso3166_2, color = q5(fatality_rate)), size=2)+
  scale_color_manual(values=text_inv)+
  mapTheme+
  guides(color = "none")+

  theme(legend.position = 'right')+

  labs(title=' Children Traffic Fatalities Rate Across US States in 2022',
       subtitle = 'Aged 18 and under',
       caption = 'Source: NHTSA FARS 2022\nCreated by Zhanchao Yang',

  )
