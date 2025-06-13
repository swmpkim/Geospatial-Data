library(tidyverse)
library(mseptools)
library(sf)
library(units)
library(tigris)
options(tigris_use_cache = TRUE)
library(foreign)

# db codes ----
db_codes <- read.dbf(here::here("EPA NHD",
                                "fcode_explanations",
                                "NHDFCode.dbf")) |> 
    select(FCode, Descriptio)

# MS boundary ----
states <- states(cb = FALSE)  
ms_sf <- states |>  
    filter(NAME == "Mississippi")
rm(states)

# msep boundary ----
data(msep_boundary)


# waterbodies ----
wbs <- st_read(here::here("EPA NHD",
                          "MS_only",
                          "waterbody_MS.gpkg"))
wb_areas <- wbs |> 
    mutate(area = st_area(geom),
           area_sqkm = set_units(area, "km2"),
           area_sqmi = set_units(area, "mi2"),
           area_acres = set_units(area, "acres"),
           across(c(area, area_sqkm, area_sqmi, area_acres), as.numeric)) |> 
    st_drop_geometry()

wbs_msep <- st_intersection(wbs, msep_boundary)
wbs_msep_areas <- wbs_msep |> 
    mutate(area = st_area(geom),
           area_sqkm = set_units(area, "km2"),
           area_sqmi = set_units(area, "mi2"),
           area_acres = set_units(area, "acres"),
           across(c(area, area_sqkm, area_sqmi, area_acres), as.numeric)) |> 
    st_drop_geometry()

p <- ggplot() +
    geom_sf(data = ms_sf,
            fill = "gray90",
            col = "black") +
    geom_sf(data = wbs,
            col = "blue") +
    geom_sf(data = wbs_msep,
            col = "purple") +
    geom_sf(data = msep_boundary,
            fill = NA,
            col = "orange",
            size = 2) +
    theme_void()
p

# attach categories and calculate ----
db_codes <- db_codes |> 
    filter(FCode %in% wb_areas$fcode) |> 
    mutate(Description = droplevels(Descriptio)) |> 
    select(-Descriptio) |> 
    mutate(Description = str_remove_all(Description, "Hydrographic Category = |Reservoir Type = |Stage = "))

wb_areas <- left_join(wb_areas, db_codes,
                      by = c("fcode" = "FCode"))
wbs_msep_areas <- left_join(wbs_msep_areas, db_codes,
                      by = c("fcode" = "FCode"))

wb_areas_summ <- wb_areas |> 
    summarize(.by = c(ftype, Description),
              MS_sqmi = sum(area_sqmi),
              MS_acres = sum(area_acres))
wbs_msep_areas_summ <- wbs_msep_areas |> 
    summarize(.by = c(ftype, Description),
              MSEP_sqmi = sum(area_sqmi),
              MSEP_acres = sum(area_acres))

wbGT25acres <- wb_areas |> 
    filter(area_acres >= 25) |> 
    summarize(.by = c(ftype, Description),
              MSGT25_sqmi = sum(area_sqmi),
              MSGT25_acres = sum(area_acres))
wb_msep_GT25acres <- wbs_msep_areas |> 
    filter(area_acres >= 25) |> 
    summarize(.by = c(ftype, Description),
              MSEPGT25_sqmi = sum(area_sqmi),
              MSEPGT25_acres = sum(area_acres))

areas_all <- full_join(wb_areas_summ,
                       wbs_msep_areas_summ) |> 
    full_join(wbGT25acres) |> 
    full_join(wb_msep_GT25acres) |> 
    arrange(Description)

options(scipen = 999)
knitr::kable(areas_all,
             digits = 0,
             format.args = list(big.mark = ","))


write.csv(areas_all,
          here::here("Outputs", "waterbody_calcs",
                     "Calculated_WaterbodyAreas_MS-and-MSEP.csv"),
          na = "",
          row.names = FALSE)
ggsave(plot = p,
       filename = here::here("Outputs",
                             "waterbody_calcs",
                             "Map_of_Waterbodies_MS-and-MSEP.png"),
       height = 8,
       width = 5,
       units = "in",
       dpi = 400)
