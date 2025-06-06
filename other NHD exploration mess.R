# NHDFlowLine layer
ms_lines2 <- vect(path_ms_hydrogr,
                  layer = "NHDFlowline",
                  proxy = TRUE)
names(ms_lines2)
unique_vals <- query(ms_lines2,
                     sql = "SELECT DISTINCT fcode_description FROM NHDFlowline")
unique_vals
# doesn't look like there's more than one, but:
values(unique_vals)



##############################################################
# HUC10 layer ----
ms_huc10 <- st_read(path_ms_hydrogr,
                    layer = "WBDHU10")
object.size(ms_huc10)
ms_huc10b <- vect(path_ms_hydrogr,
                  layer = "WBDHU10")
prettyNum(object.size(ms_huc10), big.mark = ",")
prettyNum(object.size(ms_huc10b), big.mark = ",")
glimpse(ms_huc10)
head(ms_huc10)
ms_huc10
glimpse(ms_huc10b)
names(ms_huc10)
names(ms_huc10b)
unique(ms_huc10$hutype_description)
unique(ms_huc10b$hutype_description)
# so terra lets you do the same things as sf
# when proxy = FALSE
ms_huc10c <- vect(path_ms_hydrogr,
                  layer = "WBDHU10",
                  proxy = TRUE)
prettyNum(object.size(ms_huc10c), big.mark = ",")
prettyNum(object.size(ms_huc10b), big.mark = ",")
glimpse(ms_huc10c)
# glimpse doesn't work when you use proxy


######################################################################

# NHDFlowLine layer
ms_lines2 <- vect(path_ms_hydrogr,
                  layer = "NHDFlowline",
                  proxy = TRUE)
ms_lines3 <- vect(path_ms_hydrogr,
                  layer = "NHDFlowline",
                  proxy = FALSE)
prettyNum(object.size(ms_lines2), big.mark = ",")
prettyNum(object.size(ms_lines3), big.mark = ",")
names(ms_lines3)
unique(ms_lines3$fcode_description)
stream_types <- unique(ms_lines3$fcode_description)
sort(stream_types)
names(ms_huc10b)

unique(ms_huc10b$hutype_description)
ms_huc10b2 <- ms_huc10b |>
    filter(hutype_description == "Frontal")
ms_lines3_sub <- ms_lines3 |>
    filter(fcode_description %in% c(
        "Artificial Path",
        "Stream/River",
        "Stream/River: Hydrographic Category = Perennial"
    ))
glimpse(ms_lines3_sub)
ms_lines3_df <- values(ms_lines3, dataframe = TRUE)
ms_lines3_df_sub <- ms_lines3_df |>
    filter(fcode_description %in% c(
        "Artificial Path",
        "Stream/River",
        "Stream/River: Hydrographic Category = Perennial"
    ))
names(ms_lines3_df_sub)
ms_lines3_summary <- ms_lines3_df_sub |>
    mutate(type = case_when(fcode_description == "Artificial Path" ~ "Artificial Path",
                            .default = "Stream/River"))
glimpse(ms_lines3_summary)
ms_lines3_summary <- ms_lines3_df_sub |>
    mutate(type = case_when(fcode_description == "Artificial Path" ~ "Artificial Path",
                            .default = "Stream/River")) |>
    summarize(.by = type,
              lengthkm = sum(lengthkm, na.rm = TRUE))
knitr::kable(ms_lines3_summary)
?knitr::kable
knitr::kable(ms_lines3_summary,
             format.args = list(big.mark = ","))
ms_lines3_df |>
    summarize(.by = fcode_description,
              lengthkm = sum(lengthkm, na.rm = TRUE)) |>
    arrange(fcode_description) |>
    knitr::kable(format.args = list(big.mark = ","))
ms_lines3_df |>
    summarize(.by = fcode_description,
              lengthkm = sum(lengthkm, na.rm = TRUE)) |>
    arrange(fcode_description) |>
    knitr::kable(format.args = list(big.mark = ","))
options(scipen = 999)
ms_lines3_df |>
    summarize(.by = fcode_description,
              lengthkm = sum(lengthkm, na.rm = TRUE)) |>
    arrange(fcode_description) |>
    knitr::kable(format.args = list(big.mark = ","))
ms_lines3_df |>
    summarize(.by = fcode_description,
              lengthkm = sum(lengthkm, na.rm = TRUE)) |>
    arrange(fcode_description) |>
    knitr::kable(digits = 1,
                 format.args = list(big.mark = ","))
ms_lines3_df |>
    summarize(.by = fcode_description,
              length_km = sum(lengthkm, na.rm = TRUE)) |>
    mutate(length_mi = length_km / 1.609) |>
    arrange(fcode_description) |>
    knitr::kable(digits = 1,
                 format.args = list(big.mark = ","))
?st_distance
ms_lines4 <- mslines3[1:2, , ]
ms_lines4 <- ms_lines3[1:2, , ]
ms_lines4
st_distance(ms_lines4[1])
ms_lines4_sf <- as.sf(ms_lines4)
sf::st_as_sf()
?st_as_sf
ms_lines4_sf <- st_as_sf(ms_lines4)
ms_lines4_sf
st_length(ms_lines4_sf[1])
st_length(ms_lines4_sf)
st_lengths(ms_lines4_sf)
ms_lines3_dfb  <- as.data.frame(ms_lines3)
View(ms_lines3_dfb)
?perim
perim(ms_lines4)
vector_layers(path_ms_hydrogr)
lyrs2 <- terra::vector_layers(path_ms_hydrogr)

###############################################################

stream_types2 <- query(ms_lines2,
                       sql = "SELECT DISTINCT fcode_description FROM NHDFlowline")
values(stream_types2)

unique_vals