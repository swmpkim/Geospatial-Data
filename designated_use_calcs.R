# Designated Uses in the MSEP boundary
# Per DEQ, anything not specifically listed in these files is "fish and wildlife"
# Some waters have 2 designated uses 
# any water designated for shellfish harvesting is *also* designated for recreation
# DEQ sent files that were already clipped to the MSEP boundary


library(tidyverse)
library(sf)
library(units)
library(tigris)
options(tigris_use_cache = TRUE)

# MS boundary ----
states <- states(cb = FALSE)  
ms_sf <- states |>  
    filter(NAME == "Mississippi")
rm(states)

# msep boundary ----
data(msep_boundary)

in_path <- here::here("DEQ_designated_uses",
                      "SelectedWQSWaters")

# dictionary for abbreviations
abbrevs <- tribble(
    ~ATTR_VAL, ~Description,
    "EPH", "Ephemeral",
    "PWS", "Public Water Supply",
    "REC", "Recreation",
    "SHF", "Shellfish Harvesting",
    "PWS-REC", "Public Water Supply & Recreation",
    "SHF-REC", "Shellfish Harvesting & Recreation",
    "SFH-REC", "Shellfish Harvesting & Recreation",
    "FW1", "Fish and Wildlife"
)


# stream designations ----
streams <- st_read(here::here(in_path, "SelectedWQSLinearWaters.shp"))
stream_lengths <- streams |> 
    mutate(length = st_length(geometry),
           length_mi = set_units(length, "mi"),
           length_mi = as.numeric(length_mi)) |> 
    st_drop_geometry()
stream_length_summ <- stream_lengths |> 
    mutate(ATTR_VAL = case_when(ATTR_VAL == "SFH-REC" ~ "SHF-REC",
                                .default = ATTR_VAL)) |> 
    left_join(abbrevs) |> 
    summarize(.by = c(ATTR_VAL, Description),
              length_mi = sum(length_mi)) |> 
    arrange(ATTR_VAL)
knitr::kable(stream_length_summ,
             digits = 1,
             format.args = list(big.mark = ","))


# polygons ----
polys <- st_read(here::here(in_path, "SelectedWQSPolygonalWaters.shp"))
wb_areas <- polys |> 
    mutate(area = st_area(geometry),
           area_sqmi = set_units(area, "mi2"),
           area_acres = set_units(area, "acres"),
           across(c(area_sqmi, area_acres), as.numeric)) |> 
    st_drop_geometry()

wb_area_summ <- wb_areas |> 
    left_join(abbrevs) |> 
    summarize(.by = c(ATTR_VAL, Description),
              area_sqmi = sum(area_sqmi, na.rm = TRUE),
              area_acres = sum(area_acres, na.rm = TRUE)) |> 
    arrange(ATTR_VAL)
knitr::kable(wb_area_summ,
             digits = 1,
             format.args = list(big.mark = ","))



library(writexl)
write_xlsx(list("Linear" = stream_length_summ,
                "Polygon" = wb_area_summ),
           here::here("Outputs",
                      "designated_use_calcs",
                      "MSEP_designated_use_amounts.xlsx"))


col_labs <- sort(unique(c(unique(stream_length_summ$Description), unique(wb_area_summ$Description))))
col_pal <- khroma::color("muted")(length(col_labs))
col_pal <- as.character(col_pal)
names(col_pal) <- col_labs

streams <- streams |> 
    left_join(abbrevs)
polys <- polys |> 
    left_join(abbrevs)

ggplot() + 
    geom_sf(data = ms_sf, fill = "gray90") +
    geom_sf(data = streams, aes(col = Description)) + 
    geom_sf(data = polys, aes(fill = Description)) +
    geom_sf(data = msep_boundary, fill = NA, col = "orange") +
    scale_colour_manual(values = col_pal,
                        aesthetics = c("colour", "fill")) +
    theme_bw() +
    ggtitle("Water Body Use Classifications in the MSEP Boundary")
ggsave(here::here("Outputs",
                  "designated_use_calcs",
                  "Map_of_MSEP_DesignatedWaters.png"),
       height = 8,
       width = 6, 
       units = "in",
       dpi = 400)
    