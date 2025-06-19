# library(tidyverse)
library(sf)

fl <- here::here("NWI",
                 "MS_geodatabase_wetlands",
                 "MS_geodatabase_wetlands.gdb")
lyrs <- st_layers(fl)

# state boundary ----
ms_sf <- st_read(here::here("HUCs - National Boundary Dataset",
                            "GOVTUNIT_Mississippi_State_GPKG.gpkg"),
                 layer = "GU_StateOrTerritory") |> 
    st_geometry()

# msep boundary ----
msep_sf <- st_read(here::here("MSEP boundary",
                              "MSEP_outline_MSonly.shp"))|> 
    st_geometry()

# wetlands metadata
meta <- terra::vect(fl, layer = "MS_Wetlands",
                    proxy = TRUE)
wetland_types <- terra::query(meta,
                              sql = "SELECT DISTINCT WETLAND_TYPE FROM MS_Wetlands")
terra::values(wetland_types)

# read in wetlands ----
wetlands <- st_read(fl, layer = "MS_Wetlands")
gc()
st_crs(wetlands)

# transform ms_sf into the crs of the wetlands df
ms_sf <- st_transform(ms_sf, st_crs(wetlands))
msep_sf <- st_transform(msep_sf, st_crs(wetlands))

# this takes over 20 minutes to render; not worth it
# ggplot(wetlands) +
#     geom_sf(aes(fill = WETLAND_TYPE),
#             col = NA,
#             alpha = 0.6) +
#     geom_sf(data = ms_sf,
#             fill = NA,
#             col = "blue")

ms_wetlands <- st_intersection(wetlands, ms_sf)
# took ~20 mins on kc's msu laptop
# 26 mins on hallway computer (used same memory, up to 9GB, but there was more to spare - just not any faster though)

rm(wetlands)
gc()

strt <- Sys.time()
msep_wetlands <- st_intersection(ms_wetlands, msep_sf)
Sys.time() - strt
beepr::beep(8)
# 12 mins kc laptop


# chatgpt says it's faster to do a filter with intersection first
ms_wetlands <- st_read(here::here("NWI", "MSEP_trimmed_files",
                                  "wetlands_MS.shp"))
ms_sf <- st_transform(ms_sf, st_crs(ms_wetlands))
msep_sf <- st_transform(msep_sf, st_crs(ms_wetlands))


strt <- Sys.time()
ms_small <- st_filter(ms_wetlands, msep_sf, .predicate = st_intersects)
msep_wetlands2 <- st_intersection(ms_small, msep_sf)
Sys.time() - strt
beepr::beep(8)
# 13.5 min


# what about cropping and then clipping?
strt <- Sys.time()
ms_cropped <- st_crop(ms_wetlands, st_bbox(msep_sf))
msep_wetlands3 <- st_intersection(ms_cropped, msep_sf)
Sys.time() - strt
beepr::beep(8)
# 13.1 mins

st_write(ms_wetlands, here::here("NWI",
                                 "MSEP_trimmed_files",
                                 "wetlands_MS.shp"))

msep_wetlands4 <- st_cast(msep_wetlands3, "MULTIPOLYGON")
st_write(msep_wetlands4, here::here("NWI",
                                 "MSEP_trimmed_files",
                                 "wetlands_MSEP.shp"))
