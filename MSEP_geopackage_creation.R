# National Boundary Dataset HUCs
# do these align any better than the ones in the NHD?
# state boundary: downloaded from USGS: https://www.sciencebase.gov/catalog/item/4f70b219e4b058caae3f8e19
# HUC2, 03 downloaded from USGS: https://prd-tnm.s3.amazonaws.com/index.html?prefix=StagedProducts/Hydrography/WBD/HU2/GPKG/
# General WBD dataset info: https://www.usgs.gov/national-hydrography/access-national-hydrography-products


library(sf)
library(tidyverse)
library(mapview)

# State of MS ----
fl_state <- here::here("HUCs - National Boundary Dataset",
                 "GOVTUNIT_Mississippi_State_GPKG.gpkg")
# st_layers(fl_state)
state <- st_read(fl_state, layer = "GU_StateOrTerritory")
state <- st_geometry(state)
# mapview(state)

# HUC 03 ----
fl_huc <- here::here("HUCs - National Boundary Dataset",
                     "WBD_03_HU2_GPKG",
                     "WBD_03_HU2_GPKG.gpkg")
# st_layers(fl_huc)

# HUC4s ----
huc4 <- st_read(fl_huc, layer = "WBDHU4")

msep_huc4_fullHUCs <- huc4 |> 
    filter(huc4 %in% c("0317", "0318"))
# mapview(msep_huc4_fullHUCs,
#         zcol = "huc4") +
#     mapview(state,
#             color = "blue", lwd = 2,
#             alpha.regions = 0)

msep_huc4_MSonly <- st_intersection(msep_huc4_fullHUCs, state)

# Outline ----
# based on HUC4s
msep_outline_fullHUCs <- st_union(msep_huc4_fullHUCs) |> 
    st_as_sf()
msep_outline_MSonly <- st_intersection(msep_outline_fullHUCs, state)


# HUC8s ----
huc8 <- st_read(fl_huc, layer = "WBDHU8")
msep_huc8_fullHUCs <- huc8 |> 
    filter(str_starts(huc8, "0317|0318"))
msep_huc8_MSonly <- st_intersection(msep_huc8_fullHUCs, state)

# mapview(msep_huc8_fullHUCs,
#         zcol = "huc8") +
#     mapview(state,
#             color = "blue", lwd = 2,
#             alpha.regions = 0)

# HUC10s ----
huc10 <- st_read(fl_huc, layer = "WBDHU10")
msep_huc10_fullHUCs <- huc10 |> 
    filter(str_starts(huc10, "0317|0318"))
msep_huc10_MSonly <- st_intersection(msep_huc10_fullHUCs, state)

# mapview(msep_huc10_MSonly,
#         zcol = "huc10") +
#     mapview(state,
#             color = "blue", lwd = 2,
#             alpha.regions = 0)

# HUC12s ----
huc12 <- st_read(fl_huc, layer = "WBDHU12")
msep_huc12_fullHUCs <- huc12 |> 
    filter(str_starts(huc12, "0317|0318"))
msep_huc12_MSonly <- st_intersection(msep_huc12_fullHUCs, state)

# mapview(msep_huc12_MSonly,
#         zcol = "huc12") +
#     mapview(state,
#             color = "blue", lwd = 2,
#             alpha.regions = 0)


# write out ----

# geopackages ----
out_gpkg_full <- here::here("MSEP boundary",
                            "MSEP_HUCs_full.gpkg")

st_write(msep_outline_fullHUCs, out_gpkg_full, layer = "outline_fullHUCs", delete_dsn = TRUE)
st_write(msep_huc4_fullHUCs, out_gpkg_full, layer = "huc4_fullHUCs", append = FALSE)
st_write(msep_huc8_fullHUCs, out_gpkg_full, layer = "huc8_fullHUCs", append = FALSE)
st_write(msep_huc10_fullHUCs, out_gpkg_full, layer = "huc10_fullHUCs", append = FALSE)
st_write(msep_huc12_fullHUCs, out_gpkg_full, layer = "huc12_fullHUCs", append = FALSE)
zip(zipfile = here::here("MSEP boundary", "MSEP_HUCS_full.zip"), files = out_gpkg_full)


out_gpkg_ms <- here::here("MSEP boundary",
                          "MSEP_HUCs_MSonly.gpkg")

st_write(msep_outline_MSonly, out_gpkg_ms, layer = "outline_MSonly", append = FALSE)
st_write(msep_huc4_MSonly, out_gpkg_ms, layer = "huc4_MSonly", append = FALSE)
st_write(msep_huc8_MSonly, out_gpkg_ms, layer = "huc8_MSonly", append = FALSE)
st_write(msep_huc10_MSonly, out_gpkg_ms, layer = "huc10_MSonly", append = FALSE)
st_write(msep_huc12_MSonly, out_gpkg_ms, layer = "huc12_MSonly", append = FALSE)
zip(zipfile = here::here("MSEP boundary", "MSEP_HUCS_MSonly.zip"), files = out_gpkg_ms)


# esri format geodatabase ----
out_gdb <- here::here("MSEP boundary", "MSEP_HUCS_full.gdb")

st_write(msep_outline_fullHUCs, out_gdb, layer = "outline_fullHUCs", delete_dsn = TRUE)
st_write(msep_huc4_fullHUCs, out_gdb, layer = "huc4_fullHUCs", append = TRUE)
st_write(msep_huc8_fullHUCs, out_gdb, layer = "huc8_fullHUCs", append = TRUE)
st_write(msep_huc10_fullHUCs, out_gdb, layer = "huc10_fullHUCs", append = TRUE)
st_write(msep_huc12_fullHUCs, out_gdb, layer = "huc12_fullHUCs", append = TRUE)

# zip it
gdb_folder <- here::here("MSEP boundary", "MSEP_HUCS_full.gdb")
zipfile <- here::here("MSEP boundary", "MSEP_HUCS_full.gdb.zip")
# List all files recursively in the .gdb folder
files_to_zip <- list.files(gdb_folder, recursive = TRUE, full.names = TRUE)
# Zip the entire folder contents
zip(zipfile = zipfile, files = files_to_zip)


# and again for MS only files
out_gdb <- here::here("MSEP boundary", "MSEP_HUCS_MSonly.gdb")

st_write(msep_outline_MSonly, out_gdb, layer = "outline_MSonly", delete_dsn = TRUE)
st_write(msep_huc4_MSonly, out_gdb, layer = "huc4_MSonly", append = TRUE)
st_write(msep_huc8_MSonly, out_gdb, layer = "huc8_MSonly", append = TRUE)

msep_huc10_MSonly2 <- st_cast(msep_huc10_MSonly, "MULTIPOLYGON")
st_write(msep_huc10_MSonly2, out_gdb, layer = "huc10_MSonly", append = TRUE)

msep_huc12_MSonly2 <- st_cast(msep_huc12_MSonly, "MULTIPOLYGON")
st_write(msep_huc12_MSonly2, out_gdb, layer = "huc12_MSonly", append = TRUE)

# zip it
gdb_folder <- here::here("MSEP boundary", "MSEP_HUCS_MSonly.gdb")
zipfile <- here::here("MSEP boundary", "MSEP_HUCS_MSonly.gdb.zip")
# List all files recursively in the .gdb folder
files_to_zip <- list.files(gdb_folder, recursive = TRUE, full.names = TRUE)
# Zip the entire folder contents
zip(zipfile = zipfile, files = files_to_zip)


# shapefiles and geojson for outline, both versions ----
st_write(msep_outline_fullHUCs,
         here::here("MSEP boundary",
                    "MSEP_outline_fullHUCs.shp"))
st_write(msep_outline_MSonly,
         here::here("MSEP boundary",
                    "MSEP_outline_MSonly.shp"))

st_write(msep_outline_fullHUCs,
         here::here("MSEP boundary",
                    "MSEP_outline_fullHUCs.geojson"))
st_write(msep_outline_MSonly,
         here::here("MSEP boundary",
                    "MSEP_outline_MSonly.geojson"))

# shapefiles and geojson for outline with subbasins, both versions ----
st_write(msep_huc8_fullHUCs,
         here::here("MSEP boundary",
                    "MSEP_subbasins_fullHUCs.shp"))
st_write(msep_huc8_MSonly,
         here::here("MSEP boundary",
                    "MSEP_subbasins_MSonly.shp"))

st_write(msep_huc8_fullHUCs,
         here::here("MSEP boundary",
                    "MSEP_subbasins_fullHUCs.geojson"))
st_write(msep_huc8_MSonly,
         here::here("MSEP boundary",
                    "MSEP_subbasins_MSonly.geojson"))
