# map perennial streams in MS
# use terra and proxy to only pull in what I want


library(tidyverse)
library(terra)
library(tidyterra)
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

# find the layers
lyrs.tr <- vector_layers(path_ms_hydrogr)

# find out the names in the layer with flowlines
# read in the layer as a proxy
flowline.tr <- terra::vect(path_ms_hydrogr,
                           layer = "NHDFlowline",
                           proxy = TRUE)
# see the names
names(flowline.tr)

# find out the distinct values of fcode_description
# query them
descrs <- query(flowline.tr, 
                sql = "SELECT DISTINCT fcode_description FROM NHDFlowline")
# see them
values(descrs)

# I want 'Stream/River: Hydrographic Category = Perennial'
strms_peren <- query(flowline.tr,
                     sql = "SELECT * FROM NHDFlowline WHERE fcode_description LIKE 'Stream/River: Hydrographic Category = Perennial'")
glimpse(values(strms_peren))

# map it
# see if the data's already within MS boundaries or needs to be trimmed
ggplot() +
    geom_sf(data = ms_sf,
            fill = NA,
            col = "black") +
    geom_spatvector(data = strms_peren,
                    col = "blue")

# it does reach outside MS, so I need to clip it
# first, turn it into an st object because I know how to do these things
strms_peren <- st_as_sf(strms_peren)
strms_peren_ms <- st_intersection(strms_peren, ms_sf)
strms_peren_msep <- st_intersection(strms_peren, msep_sf)

ggplot() +
    geom_sf(data = ms_sf,
            fill = NA,
            col = "black") +
    geom_sf(data = strms_peren_ms,
            col = "blue")

ggplot() +
    geom_sf(data = ms_sf,
            fill = NA,
            col = "black") +
    geom_sf(data = msep_sf,
            fill = NA,
            col = "darkorange") +
    geom_sf(data = strms_peren_msep,
            col = "blue")

# calculate total lengths of perennial streams
all_lengths <- strms_peren |> 
    mutate(length = st_length(geometry),
           length_mi = as.numeric(units::set_units(length, "mi"))) |> 
    st_drop_geometry() |> 
    summarize(.by = fcode_description,
              all_total = sum(length_mi))

ms_lengths <- strms_peren_ms |> 
    mutate(length = st_length(geometry),
           length_mi = as.numeric(units::set_units(length, "mi"))) |> 
    st_drop_geometry() |> 
    summarize(.by = fcode_description,
              ms_total = sum(length_mi))

msep_lengths <- strms_peren_msep |> 
    mutate(length = st_length(geometry),
           length_mi = as.numeric(units::set_units(length, "mi"))) |> 
    st_drop_geometry() |> 
    summarize(.by = fcode_description,
              msep_total = sum(length_mi))

comb_lengths <- full_join(all_lengths, ms_lengths) |> 
    full_join(msep_lengths)

knitr::kable(comb_lengths,
             digits = 1,
             format.args = list(big.mark = ","))
