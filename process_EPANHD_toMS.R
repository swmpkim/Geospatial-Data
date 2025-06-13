# pull out flowlines in MS from the various layers I have

library(tidyverse)
# library(terra)
library(foreign)

library(sf)
library(tigris)
options(tigris_use_cache = TRUE)

# set paths ----
# South Atlantic region (east MS)
path_sa_db <- here::here("EPA NHD",
                         "NHDPlusSA",
                         "NHDPlus03W",
                         "NHDSnapshot")
path_sa_shps <- here::here(path_sa_db,
                           "Hydrography")

# Lower Mississippi region (west MS)
path_ms_db <- here::here("EPA NHD",
                         "NHDPlusV21_MS_08_NHDSnapshot_07",
                         "NHDPlusMS",
                         "NHDPlus08",
                         "NHDSnapshot")
path_ms_shps <- here::here(path_ms_db,
                           "Hydrography")

# Tennessee 06 region (northeast corner of MS)
path_ne_db <- here::here("EPA NHD",
                         "NHDPlusV21_MS_06_NHDSnapshot_09",
                         "NHDPlusMS",
                         "NHDPlus06",
                         "NHDSnapshot")
path_ne_shps <- here::here(path_ms_db,
                           "Hydrography")

# FCodes with descriptions 
db_codes <- read.dbf(here::here(path_sa_db,
                                "NHDFCode.dbf"))

# MS state boundary ----
states <- states(cb = FALSE)  
ms_sf <- states |>  
    filter(NAME == "Mississippi")
rm(states)


# read and clip MS flowlines ----
flowline_ms <- st_read(here::here(path_ms_shps,
                                  "NHDFlowline.shp"))
flowline_ms <- st_intersection(flowline_ms, ms_sf)
gc()


# read and clip SA flowlines ----
flowline_sa <- st_read(here::here(path_sa_shps,
                                  "NHDFlowline.shp"))
flowline_sa <- st_intersection(flowline_sa, ms_sf)
gc()

# read and clip NE corner flowlines ----
flowline_ne <- st_read(here::here(path_ne_shps,
                                  "NHDFlowline.shp"))
flowline_ne <- st_intersection(flowline_ne, ms_sf)
gc()

# make sure it worked
ggplot() +
    geom_sf(data = ms_sf,
            fill = "gray90",
            col = "black") +
    geom_sf(data = flowline_sa,
            col = "blue") +
    geom_sf(data = flowline_ms,
            col = "red") +
    geom_sf(data = flowline_ne,
            col = "purple")

# it did not.... that's the same as the MS08 file
rm(flowline_ne)
gc()

# combine two objects into one ----
flowline_MS <- bind_rows(flowline_ms,
                             flowline_sa)
ggplot() +
    geom_sf(data = ms_sf,
            fill = "gray90",
            col = "black") +
    geom_sf(data = flowline_MS,
            col = "blue")

# write out ----
st_write(flowline_MS,
         here::here("EPA NHD",
                    "MS_only",
                    "flowline_MS.gpkg"))


