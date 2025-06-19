# calculate total area of wetland types in MS and MSEP areas
# Using NWI data downloaded from https://www.fws.gov/program/national-wetlands-inventory/download-state-wetlands-data

library(sf)
library(tidyverse)
library(units)

# MS ----
wetlands_ms <- st_read(here::here("NWI", "MSEP_trimmed_files",
                                  "wetlands_MS.shp"))
wetland_ms_areas <- wetlands_ms |> 
    mutate(area = st_area(geometry),
           area_acres = set_units(area, "acres"),
           area_sqkm = set_units(area, "km2"),
           area_sqmi = set_units(area, "mi2")) |> 
    st_drop_geometry()

wetland_ms_summary <- wetland_ms_areas |> 
    rename(Wetland_Type = WETLAND) |> 
    summarize(.by = Wetland_Type,
              MS_acres = sum(area_acres),
              MS_sqkm = sum(area_sqkm),
              MS_sqmi = sum(area_sqmi))

wetland_ms_GT25 <- wetland_ms_areas |> 
    filter(as.numeric(area_acres) >= 25) |> 
    rename(Wetland_Type = WETLAND) |> 
    summarize(.by = Wetland_Type,
              MS_acres = sum(area_acres),
              MS_sqkm = sum(area_sqkm),
              MS_sqmi = sum(area_sqmi))


# MSEP ----
wetlands_msep <- st_read(here::here("NWI", "MSEP_trimmed_files",
                                  "wetlands_MSEP.shp"))
wetland_msep_areas <- wetlands_msep |> 
    mutate(area = st_area(geometry),
           area_acres = set_units(area, "acres"),
           area_sqkm = set_units(area, "km2"),
           area_sqmi = set_units(area, "mi2")) |> 
    st_drop_geometry()

wetland_msep_summary <- wetland_msep_areas |> 
    rename(Wetland_Type = WETLAND) |> 
    summarize(.by = Wetland_Type,
              MSEP_acres = sum(area_acres),
              MSEP_sqkm = sum(area_sqkm),
              MSEP_sqmi = sum(area_sqmi))

wetland_msep_GT25 <- wetland_msep_areas |> 
    filter(as.numeric(area_acres) >= 25) |> 
    rename(Wetland_Type = WETLAND) |> 
    summarize(.by = Wetland_Type,
              MSEP_acres = sum(area_acres),
              MSEP_sqkm = sum(area_sqkm),
              MSEP_sqmi = sum(area_sqmi))


# combine ----
wetland_areas_all <- full_join(wetland_ms_summary, wetland_msep_summary) |> 
    mutate(across(MS_acres:MSEP_sqmi, as.numeric)) |> 
    arrange(Wetland_Type)

knitr::kable(wetland_areas_all,
             digits = 0,
             format.args = list(big.mark = ","))

write.csv(wetland_areas_all,
          here::here("Outputs",
                     "wetland_inventory_calcs",
                     "wetland_areas_all.csv"),
          na = "",
          row.names = FALSE)

# this greater than 25 acre filtering matches the 305b report better than 
# the full datasets
wetland_areas_GT25 <- full_join(wetland_ms_GT25, wetland_msep_GT25) |> 
    mutate(across(MS_acres:MSEP_sqmi, as.numeric)) |> 
    arrange(Wetland_Type)

knitr::kable(wetland_areas_GT25,
             digits = 0,
             format.args = list(big.mark = ","))

write.csv(wetland_areas_GT25,
          here::here("Outputs",
                     "wetland_inventory_calcs",
                     "wetland_areas_GT25acres.csv"),
          na = "",
          row.names = FALSE)
