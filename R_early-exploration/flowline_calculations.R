# Flow line calculations


# spoiler alert: outputs. Units are miles
# |fcode_description                                                             |  MS_total| MSEP_total|
#     |:-----------------------------------------------------------------------------|---------:|----------:|
#     |Artificial Path                                                               |  28,361.9|   11,279.2|
#     |Canal/Ditch                                                                   |   5,646.2|    1,102.4|
#     |Coastline                                                                     |     344.1|      344.2|
#     |Connector                                                                     |     715.2|      231.5|
#     |Pipeline: Pipeline Type = Aqueduct; Relationship to Surface = Underground     |     534.5|      244.6|
#     |Pipeline: Pipeline Type = General Case; Relationship to Surface = Underground |       0.4|         NA|
#     |Pipeline: Pipeline Type = Siphon                                              |       0.1|         NA|
#     |Pipeline: Pipeline Type = Stormwater; Relationship to Surface = Underground   |       0.3|         NA|
#     |Stream/River                                                                  |  76,753.7|   27,766.2|
#     |Stream/River: Hydrographic Category = Intermittent                            | 121,432.1|   43,901.6|
#     |Stream/River: Hydrographic Category = Perennial                               |  23,944.4|   10,294.1|

library(tidyverse)
library(sf)
library(tigris)
options(tigris_use_cache = TRUE)

# MS state boundary ----

states <- states(cb = FALSE)  
ms_sf <- states |>  
    filter(NAME == "Mississippi")
st_crs(ms_sf)  # also NAD83 / EPSG:4269

rm(states)

# MSEP boundary ----
msep_sf <- st_read(here::here("MSEP boundary",
                              "MSEP_outline.shp")) |> 
    dplyr::select(-all_of(ends_with("_1")))

st_crs(msep_sf)
# also NAD83, EPSG 4269


# hydrography data ----

# set path to geospatial data
path_ms_hydrogr <- here::here("National Hydrography Dataset",
                              "NHD_H_Mississippi_State_GPKG",
                              "NHD_H_Mississippi_State_GPKG.gpkg")

# get layers
lyrs.sf <- st_layers(path_ms_hydrogr)


# read in data
flowline <- st_read(path_ms_hydrogr,
                        layer = "NHDFlowline")

# trim it to my boundaries of interest
msep_flowline <- flowline |> 
    st_intersection(msep_sf)

gc()

ms_flowline <- flowline |> 
    st_intersection(ms_sf)

# remove first df and clean up
rm(flowline)
gc()


ms_lengths <- ms_flowline |> 
    mutate(length = st_length(SHAPE),
           length_mi = as.numeric(units::set_units(length, "mi")),
           orig_mi = lengthkm / 1.609) |> 
    st_drop_geometry() |> 
    summarize(.by = fcode_description,
              MS_total = sum(length_mi),
              MS_orig = sum(orig_mi, na.rm = TRUE))

msep_lengths <- msep_flowline |> 
    mutate(length = st_length(SHAPE),
           length_mi = as.numeric(units::set_units(length, "mi")),
           orig_mi = lengthkm / 1.609) |> 
    st_drop_geometry() |> 
    summarize(.by = fcode_description,
              MSEP_total = sum(length_mi),
              MSEP_orig = sum(orig_mi, na.rm = TRUE))

options(scipen = 999)
all_lengths <- full_join(ms_lengths, msep_lengths) |> 
    arrange(fcode_description) |> 
    select(-MS_orig, -MSEP_orig)
knitr::kable(all_lengths,
             digits = 1,
             format.args = list(big.mark = ","))
