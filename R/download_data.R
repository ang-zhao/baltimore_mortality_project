# Load libraries
library(tidyverse)

# Load raw data
open_baltimore = read.csv("data/raw/Open Baltimore.csv")

# Filter data to only include rows that contain the word "mortality"
mortality_data = open_baltimore %>% 
  filter(grepl("mortality", title, ignore.case = TRUE) |
         grepl("mortality", description, ignore.case = TRUE))

# Download json mortality data
mortality_urls = paste0(mortality_data$url, 
              "/0/query?where=1%3D1&outFields=*&outSR=4326&f=json")

## Helper function to extract ages from the title of each mortality data file
extract_ages = function(title) {
  if (!grepl("\\d+-\\d+", title)) {
    return("infant")
  }
  
  else {
    return(stringr::str_extract(title, regex("\\d+-\\d+")))
  }
}

ages = mapply(extract_ages, mortality_data$title)
mortality_filenames = paste0("data/json/mortality_", ages, ".json")
mapply(curl::curl_download, urls, filenames)

# Download the data for (1) percentage of households with no vehicles available, 
# (2) percentage of households with no internet at home, and (3) fast food 
# outlet density per 1,000 residents.

socioeconomic_data = open_baltimore %>% 
  filter(grepl("Percent of Households with No Vehicles Available", title, ignore.case = TRUE) |
           grepl("Percent of Households with No Internet at Home", title, ignore.case = TRUE) |
           grepl("Fast Food Outlet Density per 1,000 Residents", title, ignore.case = TRUE))

socioeconomic_urls = paste0(socioeconomic_data$url, 
              "/0/query?where=1%3D1&outFields=*&outSR=4326&f=json")

socioeconomic_filenames = c("data/json/fastfood.json", "data/json/no_vehicles.json", "data/json/no_internet.json")
mapply(curl::curl_download, urls, filenames)
