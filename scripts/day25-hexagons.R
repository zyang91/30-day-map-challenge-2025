library(tidycensus)
library(tidyverse)
library(statebins)
library(biscale)
library(cowplot)
library(ggplotify)

vars <- c(
  med_income = "B19013_001",      # Median household income
  bach_plus  = "S1501_C02_015E"   # % Bachelor's degree or higher
)

acs_state <- get_acs(
  geography = "state",
  variables = vars,
  year = 2023,        # change to latest available to you
  survey = "acs1",    # 1-year ACS works well for states
  output = "wide"
)

state_data <- acs_state %>%
  transmute(
    state = state.abb[match(NAME, state.name)],  # convert full name -> abbrev
    income = med_incomeE,
    bach   = bach_plus
  ) %>%
  filter(!is.na(state))  # drops DC/PR/etc

#Only include Mainland states
state_data <- state_data %>%
  filter(!state %in% c("AK", "HI"))

state_bi <- bi_class(
  state_data,
  x = income,
  y = bach,
  style = "quantile",
  dim = 3
)


pal <- bi_pal(pal = "DkViolet", dim = 3, preview = FALSE)

hex_map <- ggplot(state_bi, aes(state = state, fill = bi_class)) +
  geom_statebins(
    border_col = "white",
    border_size = 0.6,
    lbl_size = 2.6
  ) +
  scale_fill_manual(values = pal, na.value = "grey90") +
  labs(
    title = "US State Income vs Education Attainment",
    subtitle = "Visualized by Zhanchao Yang"
  ) +
  theme_statebins() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 8),
    legend.position = "none"
  )

leg <- bi_legend(
  pal  = "DkViolet",
  dim  = 3,
  xlab = "Higher income ->",
  ylab = "Higher BA ->",
  size = 5
)

leg_rot <- as.ggplot(leg, angle = 45)

ggdraw() +
  draw_plot(hex_map, 0, 0, 1, 1) +
  draw_plot(leg_rot,
            x = 0.74,
            y = 0.15,
            width  = 0.23,
            height = 0.23)

ggsave("bivariate_hex_map.png", width = 10, height = 8)
