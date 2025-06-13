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
# (didn't work out - repeat of MS files)
# path_ne_db <- here::here("EPA NHD",
#                          "NHDPlusV21_MS_06_NHDSnapshot_09",
#                          "NHDPlusMS",
#                          "NHDPlus06",
#                          "NHDSnapshot")
# path_ne_shps <- here::here(path_ms_db,
#                            "Hydrography")

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

# # read and clip NE corner flowlines ----
# flowline_ne <- st_read(here::here(path_ne_shps,
#                                   "NHDFlowline.shp"))
# flowline_ne <- st_intersection(flowline_ne, ms_sf)
# gc()

# make sure it worked
ggplot() +
    geom_sf(data = ms_sf,
            fill = "gray90",
            col = "black") +
    geom_sf(data = flowline_sa,
            col = "blue") +
    geom_sf(data = flowline_ms,
            col = "red")

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



####################################################


# read and clip waterbody polygons ----
polys_ms <- st_read(here::here(path_ms_shps,
                                  "NHDWaterbody.shp"))
# something is wrong with the geometries and they won't join
sum(st_is_valid(polys_ms) == FALSE)
inds <- which(st_is_valid(polys_ms) == FALSE)
polys_ms[inds, ] |> 
    st_is_valid(reason = TRUE)
# lots of duplicate vertices

# try making it valid
polys_ms2 <- st_make_valid(polys_ms)
sum(st_is_valid(polys_ms2) == FALSE)
# that seems to have worked

polys_ms <- st_intersection(polys_ms2, ms_sf)
rm(polys_ms2)
gc()


# read and clip SA flowlines ----
polys_sa <- st_read(here::here(path_sa_shps,
                                  "NHDWaterbody.shp"))
sum(st_is_valid(polys_sa) == FALSE)  # 7
polys_sa2 <- st_make_valid(polys_sa)
sum(st_is_valid(polys_sa2) == FALSE) # all good
polys_sa <- st_intersection(polys_sa2, ms_sf)
rm(polys_sa2)
gc()

# make sure it worked
ggplot() +
    geom_sf(data = ms_sf,
            fill = "gray90",
            col = "black") +
    geom_sf(data = polys_sa,
            fill = "blue",
            col = NA) +
    geom_sf(data = polys_ms,
            fill = "red",
            col = NA)

# combine two objects into one ----
# have to make the names the same first
polys_ms <- janitor::clean_names(polys_ms)
names(polys_ms) <- str_remove_all(names(polys_ms), "_")

polys_sa <- janitor::clean_names(polys_sa)
names(polys_sa) <- str_remove_all(names(polys_sa), "_")

polys_MS <- bind_rows(polys_ms,
                      polys_sa)
ggplot() +
    geom_sf(data = ms_sf,
            fill = "gray90",
            col = "black") +
    geom_sf(data = polys_MS,
            fill = "blue",
            col = NA)

# write out ----
st_write(polys_MS,
         here::here("EPA NHD",
                    "MS_only",
                    "waterbody_MS.gpkg"),
         delete_dsn = TRUE)

