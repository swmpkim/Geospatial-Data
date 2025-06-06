library(tidyverse)
library(sf)
library(terra)
library(tidyterra)

path_ms_hydrogr <- here::here("National Hydrography Dataset",
                              "NHD_H_Mississippi_State_GPKG",
                              "NHD_H_Mississippi_State_GPKG.gpkg")

lyrs <- st_layers(path_ms_hydrogr)

# HUC10 layer ----
ms_huc10 <- st_read(path_ms_hydrogr,
                    layer = "WBDHU10")
# hutype_descriptions: Frontal; Island; Multiple Outlet; Standard; Water

ggplot() +
    geom_sf(data = ms_huc10,
            aes(fill = hutype_description))


# waterbody layer ----
ms_waterbody <- st_read(path_ms_hydrogr,
                        layer = "NHDWaterbody")
# this layer takes up like half a gig
# these are not streams; they are Estuary; Lake/Pond; Reservoir; Swamp/Marsh
# ggplot() +
#     geom_sf(data = ms_waterbody,
#             aes(fill = as.factor(ftype),
#                 col = as.factor(ftype)))

waterbodySizes <- ms_waterbody |> 
    st_drop_geometry() |> 
    summarize(.by = fcode_description,
              fcode = mean(fcode, na.rm = TRUE),
              ftype = mean(ftype, na.rm = TRUE),
              areasqkm = sum(areasqkm, na.rm = TRUE))
rm(ms_waterbody)
gc()

waterbodySizes2 <- waterbodySizes |> 
    mutate(ftype_description = str_split_i(fcode_description, ":|;", i = 1))

# total area by water body type ----
waterbodySizes2 |> 
    summarize(.by = ftype_description,
              areasqkm = sum(areasqkm)) |> 
    knitr::kable()

# NHDLine layer ----
ms_lines <- st_read(path_ms_hydrogr,
                    layer = "NHDLine")
table(ms_lines$fcode_description)
# dams, weirs, locks

rm(ms_lines)


# NHDFlowline ----

# ms_lines2 <- st_read(path_ms_hydrogr,
#                      layer = "NHDFlowline")
# # 2.8 gigs!!!!!!!
# # use terra for this, and proxy
# # then query for the codes I'll want
# ms_lines_dict <- sort(unique(ms_lines2$fcode_description))
# ms_lines_dict
# # would want to keep code descriptions starting with
# # Stream/River; Canal/Ditch; Canal Ditch
# rm(ms_lines2)
# gc()

ms_lines2 <- terra::vect(path_ms_hydrogr,
                         layer = "NHDFlowline",
                         proxy = TRUE)
ms_lines2_filtered <- terra::query(ms_lines2,
                                   sql = "SELECT * FROM NHDFlowline WHERE 
   fcode_description LIKE 'Stream/River%' OR 
   fcode_description LIKE 'Canal/Ditch%' OR 
   fcode_description LIKE 'Canal Ditch%'")

ggplot(ms_lines2_filtered) +
    geom_spatvector(aes(col = fcode_description,
                        fill = fcode_description))
