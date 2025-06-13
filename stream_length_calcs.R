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
                                "NHDFCode.dbf"))

# MS boundary ----
states <- states(cb = FALSE)  
ms_sf <- states |>  
    filter(NAME == "Mississippi")
rm(states)

# msep boundary ----
data(msep_boundary)

# streams ----
streams <- st_read(here::here("EPA NHD",
                              "MS_only",
                              "flowline_MS.gpkg"))
stream_lengths <- streams |> 
    mutate(length_km = st_length(geom),
           length_mi = set_units(length_km, "mi"),
           across(c(length_km, length_mi), as.numeric)) |> 
    st_drop_geometry()  

streams_msep <- st_intersection(streams, msep_boundary)
streams_msep_lengths <- streams_msep |> 
    mutate(length_km = st_length(geom),
           length_mi = set_units(length_km, "mi"),
           across(c(length_km, length_mi), as.numeric)) |> 
    st_drop_geometry()

p <- ggplot() +
    geom_sf(data = ms_sf,
            fill = "gray90",
            col = "black") +
    geom_sf(data = streams,
            col = "blue") +
    geom_sf(data = streams_msep,
            col = "purple") +
    geom_sf(data = msep_boundary,
            fill = NA,
            col = "orange",
            size = 2) +
    theme_void()

# unload the data frames with geometries
rm(streams, streams_msep)
gc()

# attach categories and calculate ----
db_codes <- db_codes |> 
    filter(FCode %in% stream_lengths$FCODE) |> 
    mutate(Description = droplevels(Descriptio)) |> 
    select(-Descriptio)
stream_lengths <- left_join(stream_lengths,
                            db_codes,
                            by = c("FCODE" = "FCode"))
streams_msep_lengths <- left_join(streams_msep_lengths,
                                 db_codes,
                                 by = c("FCODE" = "FCode"))
stream_lengths_summ <- stream_lengths |> 
    summarize(.by = c(FTYPE, Description),
              MS_length_mi = sum(length_mi))
streams_msep_lengths_summ <- streams_msep_lengths |> 
    summarize(.by = c(FTYPE, Description),
              MSEP_length_mi = sum(length_mi))
streams_summary <- full_join(stream_lengths_summ, streams_msep_lengths_summ) |> 
    arrange(Description) |> 
    mutate(Description = str_remove(Description, "Hydrographic Category = "))
knitr::kable(streams_summary,
             digits = 1,
             format.args = list(big.mark = ","))

write.csv(streams_summary,
          here::here("Outputs", "stream_length_calcs",
                     "Calculated_Flowlines_MS-and-MSEP.csv"),
          na = "",
          row.names = FALSE)
ggsave(plot = p,
       filename = here::here("Outputs",
                             "stream_length_calcs",
                             "Map_of_Flowlines_MS-and-MSEP.png"),
       height = 8,
       width = 5,
       units = "in",
       dpi = 400)
