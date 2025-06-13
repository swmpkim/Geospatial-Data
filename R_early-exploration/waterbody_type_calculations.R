# water body types with terra and proxy
# in MS, and only in MSEP watershed
# actually I could use sf for this, because I don't need to filter

library(tidyverse)
library(sf)
# library(terra)
# library(tidyterra)
library(tigris)  # state boundaries from US Census Bureau
options(tigris_cache_use = TRUE)

# MS state boundary ----

states <- states(cb = FALSE)  
# `cb = TRUE` gives simplified (cartographic) boundaries;
# cb = FALSE to include state waters

# Filter for Mississippi
ms <- states |>  
    filter(NAME == "Mississippi")

# Plot
plot(st_geometry(ms))

st_crs(ms)  # also NAD83 / EPSG:4269


# MSEP boundary ----
msep_sf <- st_read(here::here("MSEP boundary",
                              "MSEP_outline.shp")) |> 
    dplyr::select(-all_of(ends_with("_1")))

st_crs(msep_sf)
# also NAD83, EPSG 4269

# MSEP boundary 2 ----
library(mseptools)
data(msep_boundary)

# how big is our area?
st_area(msep_sf) |> 
    units::set_units("km2") |> 
    prettyNum(big.mark = ",")
st_area(msep_sf) |> 
    units::set_units("mi2") |> 
    prettyNum(big.mark = ",")


# hydrography data ----

# set path to geospatial data
path_ms_hydrogr <- here::here("National Hydrography Dataset",
                              "NHD_H_Mississippi_State_GPKG",
                              "NHD_H_Mississippi_State_GPKG.gpkg")

# get layers
lyrs.sf <- st_layers(path_ms_hydrogr)


# read in data
ms_waterbody <- st_read(path_ms_hydrogr,
                        layer = "NHDWaterbody")

# this layer takes up like half a gig
# these are not streams; they are Estuary; Lake/Pond; Reservoir; Swamp/Marsh


# check the crs
st_crs(ms_waterbody)
# NAD83
# EPSG:4269


# water body types ----
# summarize size for each type based on what is in the attribute table
# need to split the type descriptions first
waterbodySizes <- ms_waterbody |> 
    st_drop_geometry() |> 
    mutate(ftype_description = str_split_i(fcode_description, ":|;", i = 1)) |> 
    summarize(.by = ftype_description,
              areasqkm = sum(areasqkm, na.rm = TRUE))
knitr::kable(waterbodySizes,
             digits = 0,
             format.args = list(big.mark = ","))

# calculate it from the geometries
# start with a smaller batch though
swampmarshSizes_geom <- ms_waterbody |> 
    filter(str_starts(fcode_description, "Swamp")) |> 
    mutate(area_calc_sqm = st_area(SHAPE),
           area_calc_sqkm = units::set_units(area_calc_sqm, "km2"))

sum(swampmarshSizes_geom$area_calc_sqkm)

ggplot() +
    geom_sf(data = ms,
            fill = "red",
            alpha = 0.5) +
    geom_sf(data = swampmarshSizes_geom,
            fill = "blue",
            alpha = 0.5) +
    coord_sf(ylim = c(28.9, 31.2))

# now we only want Mississippi swamps and marshes:
ms_swamps <- ms_waterbody |> 
    filter(str_starts(fcode_description, "Swamp")) |>
    st_intersection(ms)  |> 
    mutate(area_calc_sqm = st_area(SHAPE),
           area_calc_sqkm = units::set_units(area_calc_sqm, "km2"))
sum(ms_swamps$area_calc_sqkm)

ggplot() +
    geom_sf(data = ms,
            fill = "red",
            alpha = 0.5) +
    geom_sf(data = ms_swamps,
            fill = "blue",
            alpha = 0.5) +
    geom_sf(data = msep_sf,
            fill = NA,
            col = "blue") +
    coord_sf(ylim = c(29.5, 33))

# calculate area of msep
msep_swamps <- ms_waterbody |> 
    filter(str_starts(fcode_description, "Swamp")) |>
    st_intersection(msep_sf)  |> 
    mutate(area_calc_sqm = st_area(SHAPE),
           area_calc_sqkm = units::set_units(area_calc_sqm, "km2"))
sum(msep_swamps$area_calc_sqkm)
sum(msep_swamps$areasqkm)  # this is a bigger number - so it retained geometry outside the boundary if it was in the same row

# clean up a bunch
rm(ms_swamps, states, swampmarshSizes_geom, msep_swamps)
gc()


# now calculate for all water body types:
# in the file
# in MS
# in MSEP

# deal with descriptions
waterbodyTypes <- ms_waterbody |> 
    mutate(ftype_description = str_split_i(fcode_description, ":|;", i = 1))
# remove the full water body object
rm(ms_waterbody)
gc()

# calculate
fileAreas <- waterbodyTypes |> 
    mutate(area_calc_sqm = st_area(SHAPE),
           area_calc_sqkm = units::set_units(area_calc_sqm, "km2")) |> 
    st_drop_geometry() |> 
    summarize(.by = ftype_description,
              File_areasqkm = sum(areasqkm, na.rm = TRUE))


msAreas <- waterbodyTypes |> 
    st_intersection(ms) |> 
    mutate(area_calc_sqm = st_area(SHAPE),
           area_calc_sqkm = units::set_units(area_calc_sqm, "km2")) |> 
    st_drop_geometry() |> 
    summarize(.by = ftype_description,
              State_areasqkm = sum(areasqkm, na.rm = TRUE))

msepAreas <- waterbodyTypes |> 
    st_intersection(msep_sf) |> 
    mutate(area_calc_sqm = st_area(SHAPE),
           area_calc_sqkm = units::set_units(area_calc_sqm, "km2")) |> 
    st_drop_geometry() |> 
    summarize(.by = ftype_description,
              MSEP_areasqkm = sum(areasqkm, na.rm = TRUE))

areas_all <- full_join(fileAreas, msAreas) |> 
    full_join(msepAreas)

knitr::kable(areas_all,
             digits = 0,
             format.args = list(big.mark = ","))

# terra proxy ----
library(terra)
library(tidyterra)
fl_proxy <- vect(path_ms_hydrogr, 
                 layer = "NHDWaterbody",
                 proxy = TRUE)
types <- query(fl_proxy, 
      sql = "SELECT DISTINCT fcode_description FROM NHDWaterbody")
values(types)
types <- as.data.frame(types)

types2 <- types |> 
    filter(str_starts(fcode_description, "Lake/Pond")) |> 
    mutate(types2 = str_remove(fcode_description, "; Stage .*"),
           types2 = str_remove(types2, "Hydrographic Category = "))

lakeponds <- query(fl_proxy,
                   sql = "SELECT * from NHDWaterbody
                   WHERE fcode_description LIKE 'Lake/Pond%'")
ggplot(lakeponds) +
    geom_sf(data = ms,
            fill = NA,
            col = "black") +
    geom_sf(data = msep_boundary,
            fill = NA,
            col = "orange") +
    geom_spatvector(aes(fill = fcode_description),
                    col = NA)

library(leaflet)
ms2 <- ms |> 
    st_transform(crs = "EPSG:4326")
msep2 <- msep_boundary |> 
    st_transform(crs = "EPSG:4326")
lakeponds2 <- lakeponds |> 
    st_as_sf() |> 
    st_transform(crs = "EPSG:4326") |> 
    st_intersection(ms2)
lakeponds2 <- lakeponds2 |> 
    mutate(types2 = str_remove(fcode_description, "; Stage .*"),
           types2 = str_remove(types2, "Hydrographic Category = "))

colorfun <- colorFactor(palette = "viridis",
                        domain = lakeponds2$types2)

leaflet() |> 
    addProviderTiles("CartoDB.Positron") |> 
    addPolylines(data = ms2,
                 fill = FALSE,
                 weight = 2,
                 color = "black") |> 
    addPolylines(data = msep2,
                 fill = FALSE,
                 weight = 2,
                 color = "orange") |> 
    addPolygons(data = lakeponds2,
                stroke = FALSE,
                fillColor = ~colorfun(types2),
                fillOpacity = 0.8) |> 
    addLegend(position = "bottomright",
              pal = colorfun,
              values = unique(lakeponds2$types2),
              opacity = 0.8)

lakeponds3 <- lakeponds2 |> 
    mutate(sizes = st_area(geometry)) |> 
    st_drop_geometry()
lakeponds3 |> 
    summarize(.by = types2,
              n = n(),
              lengths = sum(sizes)) |> 
    mutate(lengths = units::set_units(lengths, "km2")) |> 
    knitr::kable(format.args = list(big.mark = ","))

ggplot() +
    geom_sf(data = ms2,
            fill = "gray80",
            col = "black") +
    geom_sf(data = msep2,
            fill = NA,
            col = "orange") +
    geom_sf(data = lakeponds2,
            aes(fill = types2),
            col = NA) +
    scale_fill_viridis_d() +
    theme_void()
ggsave(here::here("pondlakes_ggplot.png"),
       width = 10,
       height = 18,
       units = "in",
       dpi = 400)
