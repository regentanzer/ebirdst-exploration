# This script is from day 1 of the webinar, which was mostly about learning what data is available and how to use the package

# Original code: https://raw.githubusercontent.com/ebird/ebirdst/refs/heads/main/examples/ebirdst-bow-webinars.R

library(dplyr)
library(ebirdst)
library(ggplot2)
library(rnaturalearth)
library(sf)
library(terra)

# Prior to running this script, you need to get an access key and run the following line:
# set_ebirdst_access_key("ACCESS_KEY_HERE") 


# Application 1: Regional Proportion of Population
    # Goal: to find out what % of the global Golden Eagle population in Wyoming seasonally

# load seasonal relative abundance
abd_seasonal <- load_raster("goleag", period = "seasonal")

# Wyoming boundary polygon from Natural Earth
wy_boundary <- ne_states(iso_a2 = "US") |>
  filter(name == "Wyoming") |>
  st_transform(st_crs(abd_seasonal)) |>
  vect()

# sum of abundance across all cells in Wyoming
wy_abd <- extract(abd_seasonal, wy_boundary,
                  fun = sum, na.rm = TRUE,
                  weights = TRUE, ID = FALSE)

# total global abundance
total_abd <- global(abd_seasonal, fun = sum, na.rm = TRUE)
# proportion of global population
prop_global_pop <- as.numeric(wy_abd) / total_abd$sum
names(prop_global_pop) <- names(wy_abd)

# Goal: find the % of the North American population

# north american boundary
na_boundary <- ne_countries(scale = 50) |>
  filter(continent == "North America") |>
  st_union() |>
  st_transform(st_crs(abd_seasonal)) |>
  vect()
# mask to remove data outside North America
abd_seasonal_na <- mask(abd_seasonal, na_boundary)
# total North American abundance
na_abd <- global(abd_seasonal_na, fun = sum, na.rm = TRUE)
# proportion of global population
prop_na_pop <- as.numeric(wy_abd) / na_abd$sum
names(prop_na_pop) <- names(wy_abd)



# Application 2: Migration Chronology
    # Goal: to plot the change in relative abundance throughout the year for the Hooded Warbler in Guatamala

# download and load weekly relative abundance at 3 km
ebirdst_download_status("Hooded Warbler", pattern = "abundance_median_3km")
abd_weekly <- load_raster("Hooded Warbler")
# country boundary for Guatemala
gt_boundary <- ne_countries(country = "Guatemala", scale = 50) |>
  st_transform(st_crs(abd_weekly)) |>
  vect()
# mean weekly abundance within Guatemala
abd_gt <- extract(abd_weekly, gt_boundary,
                  fun = mean, na.rm = TRUE,
                  ID = FALSE)
abd_gt <- data.frame(week = as.Date(names(abd_weekly)),
                     abd = as.numeric(abd_gt))
# plot migration chronology
ggplot(abd_gt) +
  aes(x = week, y = abd) +
  geom_line() +
  scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  labs(x = "Week",
       y = "Mean relative abundance in Guatemala",
       title = "Migration chronology for Hooded Warbler in Guatemala")
