# hucs and boundaries?

library(tidyverse)
library(sf)
library(mapview)
library(tigris)
options(tigris_use_cache = TRUE)

library(terra)

ms_sf <- states(cb = FALSE) |>  
    filter(NAME == "Mississippi")
st_crs(ms_sf)
# NAD83

ms_nhd_path <- here::here("National Hydrography Dataset",
                          "NHD_H_Mississippi_State_GPKG",
                          "NHD_H_Mississippi_State_GPKG.gpkg")

ms.lyrs <- st_layers(ms_nhd_path)

# huc8 ----
huc8s <- st_read(ms_nhd_path,
                 layer = "WBDHU8")
ms_huc8s <- st_crop(huc8s, st_bbox(ms_sf))
mapview(ms_huc8s) +
    mapview(ms_sf, col.regions = "yellow")

# huc10 ----
huc10s <- st_read(ms_nhd_path,
                 layer = "WBDHU10")
ms_huc10s <- st_crop(huc10s, st_bbox(ms_sf))
mapview(ms_huc10s) +
    mapview(ms_sf, col.regions = "yellow")


# huc4 ----
# looks like river basins are based on huc 4s
huc4s <- st_read(ms_nhd_path,
                 layer = "WBDHU4")
huc4s <- huc4s |> 
    mutate(huc_name = paste(huc4, name, sep = "; "))

mapview(ms_sf, 
        color = "blue", lwd = 2,
        alpha.regions = 0,
        map.types = "CartoDB.Positron") +
    mapview(huc4s,
            zcol = "huc_name") 

ms_huc4s <- st_crop(huc4s, st_bbox(ms_sf))

mapview(ms_huc8s, col.regions = "gray90",
        map.types = "CartoDB.Positron") +
    mapview(ms_huc4s, color = "red3",
            lwd = 2,
            alpha.regions = 0) +
    mapview(ms_sf, color = "blue", lwd = 2,
            alpha.regions = 0)


huc12s <- st_read(ms_nhd_path,
                 layer = "WBDHU12")
ms_huc12s <- st_crop(huc12s, st_bbox(ms_sf))

mapview(ms_sf, 
        color = "blue", lwd = 2,
        alpha.regions = 0,
        map.types = "CartoDB.Positron") +
mapview(ms_huc12s, col.regions = "gray90",
        alpha.regions = 0.1) 


mapview(ms_sf, 
        color = "blue", lwd = 2,
        alpha.regions = 0,
        map.types = "CartoDB.Positron") +
    mapview(ms_huc10s, col.regions = "gray90",
            alpha.regions = 0.1) 

mapview(ms_sf, 
        color = "blue", lwd = 2,
        alpha.regions = 0,
        map.types = "CartoDB.Positron") +
    mapview(ms_huc8s, col.regions = "gray90",
            alpha.regions = 0.1) 

mapview(ms_sf, 
        color = "blue", lwd = 2,
        alpha.regions = 0,
        map.types = "CartoDB.Positron") +
    mapview(huc4s,
            zcol = "huc_name",
            alpha.regions = 0.4) 

mapview(ms_sf, 
        color = "blue", lwd = 2,
        alpha.regions = 0,
        map.types = "CartoDB.Positron") +
    mapview(ms_huc8s,
            zcol = "huc8",
            alpha.regions = 0.4) 

msep_huc8s <- ms_huc8s |> 
    filter(str_starts(huc8, "0317|0318")) |> 
    mutate(huc_name = paste(huc8, name, sep = ", "))

mapview(ms_sf, 
        color = "blue", lwd = 2,
        alpha.regions = 0,
        map.types = "CartoDB.Positron") +
    mapview(msep_huc8s,
            zcol = "huc_name",
            alpha.regions = 0.4)
