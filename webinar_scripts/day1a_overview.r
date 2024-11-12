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


# Part I: Introduction 

# Explore the avialable species
View(ebirdst_runs)

# You can filter these on any of the data elements, here I'm pulling just the Yellow-billed Magpie, one of my favorite birds
glimpse(filter(ebirdst_runs, common_name == "Yellow-billed Magpie"))
    # take note of the species_code, I found that easier to work with, it's yebmag for the Yellow-billed Magpie
    # is_resident shows whether the bird is seasonal or a resident year-round
    # [season]_quality shows the data quality scores
        # 1 = low quality/confidence in data
        # 2 = medium quality/confidence in data
        # 3 = high quality/confidence in data


# Part II: Downloading Data

# to work with this data, we need to download it, and it's a lot of data, especially if you're getting multiple species

# in the console, you can run ?ebirdst_download_status, which shows you how to use it
# ebirdst manages the data for you so don't worry about the path

# determine what the default data download loaction is (and change if necessary)
ebirdst_data_dir()

# you can do a dry run to list the available data files for a species 
ebirdst_download_status("Yellow-billed Magpie", dry_run = TRUE)
ebirdst_download_status("Golden Eagle", dry_run = TRUE)

# download 3 km estimates for Tui, a resident
ebirdst_download_status("Yellow-billed Magpie", pattern = "3km")

# download 3 km estimates for Golden Eagle, a migrant
ebirdst_download_status("Golden Eagle", pattern = "3km")



# Part III: Loading Data

# load weekly relative abundance estimates
abd_weekly <- load_raster("Golden Eagle")

# midpoint of weeks corresponding to each layer
weeks <- names(abd_weekly)

# subset to only weeks within may
abd_weekly_may <- abd_weekly[[weeks >= "2022-05-01" & weeks <= "2022-05-31"]]

# average across the weeks in may
abd_may <- mean(abd_weekly_may, na.rm = TRUE)

# load seasonal relative abundance estimates
abd_seasonal <- load_raster("Golden Eagle", period = "seasonal")

# subset to just the breeding season
abd_breeding <- abd_seasonal[["breeding"]]

# load full-year maximum relative abundance
abd_max <- load_raster("Golden Eagle", period = "full-year", metric = "max")

# load seasonal relative abundance estimates for a resident
load_raster("Yellow-billed Magpie", period = "seasonal")








