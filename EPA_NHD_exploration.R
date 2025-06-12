# EPA NHD Data

library(tidyverse)
library(terra)
library(foreign)

library(sf)
library(tigris)
options(tigris_use_cache = TRUE)

path_sa_db <- here::here("EPA NHD",
                      "NHDPlusSA",
                      "NHDPlus03W",
                      "NHDSnapshot")
path_sa_shps <- here::here(path_sa_db,
                           "Hydrography")

db_codes <- read.dbf(here::here(path_sa_db,
                                "NHDFCode.dbf"))

# MS state boundary ----

states <- states(cb = FALSE)  
ms_sf <- states |>  
    filter(NAME == "Mississippi")
rm(states)

# shapefile ----


epa_sa <- vect(here::here(path_sa_shps,
                          "NHDWaterbody.shp"),
               proxy = TRUE)
names(epa_sa)
# what's in here
fcodes <- query(epa_sa,
                sql = "SELECT DISTINCT FCode FROM NHDWaterbody")
values(fcodes)
db_codes |> 
    filter(FCode %in% values(fcodes)$FCode) |> 
    select(FCode, Descriptio) |> 
    View()

# get the range of shape areas in the dataset:
values(query(epa_sa, sql = "SELECT MIN(Shape_Area), MAX(Shape_Area) FROM NHDWaterbody"))

# this is in squared degrees
# claude says 25+ acres at this latitude is about 0.0000094 square degrees
# so I'll use that to query??

epa_sa_GT25 <- query(epa_sa,
                     sql = "SELECT * FROM NHDWaterbody WHERE Shape_Area > 0.000009")
epa_sa_GT25

library(ggplot2)
library(tidyterra)

ggplot(epa_sa_GT25) +
    geom_sf(data = ms_sf,
            fill = "gray90",
            col = "black") +
    geom_spatvector(aes(fill = FTYPE)) +
    scale_fill_viridis_d() +
    theme_void() 
