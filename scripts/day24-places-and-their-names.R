# ---- packages ----
library(tigris)   # Census TIGER/Line shapefiles
library(sf)
library(dplyr)
library(stringr)
library(ggplot2)
library(ggrepel)
library(tibble)
library(grid)
library(systemfonts)

options(tigris_use_cache = TRUE)

# ---- data: US states + all incorporated/CDP places ----
us_states <- states(cb = TRUE, year = 2024) |>   # generalized boundaries
  st_transform(5070)                             # Albers Equal Area

us_places <- places(cb = TRUE, year = 2024) |>   # nationwide places
  st_transform(5070)

mainland_codes <- c(state.abb, "DC") |> setdiff(c("AK","HI"))
us_states <- us_states |>
  filter(STUSPS %in% mainland_codes)

us_places <- us_places |>
  filter(STUSPS %in% mainland_codes)
# ---- define European "source" city names ----
# (edit this list however you want)
euro_lookup <- tribble(
  ~name_us,     ~euro_origin,
  "Paris",      "France",
  "London",     "United Kingdom",
  "Rome",       "Italy",
  "Oxford",     "United Kingdom",
  "Cambridge",  "United Kingdom",
  "Manchester", "United Kingdom",
  "Milan",      "Italy"
)

euro_names <- euro_lookup$name_us

# ---- filter US places that match those names ----
euro_places <- us_places |>
  mutate(name_clean = str_to_title(NAME)) |>
  filter(name_clean %in% euro_names) |>
  left_join(euro_lookup, by = c("name_clean" = "name_us"))

# attach state abbreviations for nicer labels
state_xwalk <- us_states |>
  st_drop_geometry() |>
  select(STATEFP, STUSPS)

euro_places <- euro_places |>
  left_join(state_xwalk, by = "STATEFP")|>
  mutate(label = paste0(name_clean, ", ", STUSPS.x, "\n↳ ", euro_origin))

#centroid places for better visualization
euro_places <- euro_places |>
  st_centroid()


# create a beautiful color palette
euro_places <- euro_places |>
  mutate(
    color = case_when(
      name_clean == "Paris"      ~ "#52b69a",
      name_clean == "London"     ~ "#5c4d7d",
      name_clean == "Rome"       ~ "#a01a58",
      name_clean == "Oxford"     ~ "#40916c",
      name_clean == "Cambridge"  ~ "#a9714b",
      name_clean == "Manchester" ~ "#ff8847",
      name_clean == "Milan"      ~ "#05668d",
      TRUE                        ~ "#000000"
    )
  )
# ---- plot ----


base_fam  <- "Helvetica"     
label_fam <- "Helvetica Neue"


pal <- euro_places |> 
  distinct(NAME, color) |> 
  tibble::deframe() 

plot<- ggplot() +
  geom_sf(data = us_states, fill = "#eaf4f4", color = "white", linewidth = 0.2) +
  geom_sf(
    data = euro_places,
    aes(color = NAME, fill = NAME),
    shape = 21,
    size = 1,
  ) +
  scale_color_manual(values = pal) +
  scale_fill_manual(values = pal) +
  labs(
    title = "US Places Named After European Cities",
    subtitle = "Visualized by Zhanchao Yang",
    caption = "Source: US Census TIGER/Line Places (tigris)"
  ) +
  guides(
    color = guide_legend(
      override.aes = list(size = 2),
      keyheight = unit(0.35, "cm"),
      keywidth  = unit(0.35, "cm")
    ),
    fill = "none"  # avoid duplicated legend
  ) +
  theme_minimal(base_size = 12, base_family = base_fam) +
  theme(
    plot.caption = element_text(size = 7, hjust = 0),
    plot.title   = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 10),
    panel.grid = element_blank(),
    axis.text  = element_blank(),
    axis.title = element_blank(),
    legend.title = element_blank(),
    legend.text  = element_text(size = 7),
    legend.key.size = unit(0.35, "cm"),
    legend.spacing.y = unit(0.1, "cm")
  )
ggsave("us_places_european_names.png",plot, width = 10, height = 6, dpi = 300)
