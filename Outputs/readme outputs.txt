designated_use_calcs/
-  generated 6/13/25, from data files provided by MDEQ in DEQ_designated_uses folder and script 'designated_use_calcs.R'
-  contains:
    -  MSEP_designated_use_amounts.xlsx - workbook with two spreadsheets, one for linear calculations (streams/rivers) and one for polygons.  
       -  Linear - three columns. ATTR_VAL, the abbreviation for the use; Description, the use designation; length_mi, sum of individual geometry lengths in miles.
       -  Polygon - four columns. ATTR_VAL and Description as above. area_sqmi is the sum of areas for that designation in square miles; area_acres is the area in acres.
    -  Map_of_MSEP_DesignatedWaters.png - map of the state with the MSEP boundary, and all lines/polygons from the DEQ files, colored by use designation.


stream_length_calcs/ 
-  generated 6/13/25, from data files in EPA NHD folder and script 'stream_length_calcs.R'
-  used the NHDFlowlines layer/shapefile. Had to combine multiple regions (R script 'process_EPANHD_toMS.R').
-  multiline geometry in these files.  
-  note: the northeast corner of the state is missing; when I tried to download the data file I got a repeat of the Lower Mississippi River Basin instead. This is probably why my calculations come up a few thousand miles less than DEQ's estimate of 82,000 miles in the state; and makes me feel comfortable with the calculations of lengths inside the MSEP boundary.
-  contains:
    -  Calculated_Flowlines_MS-and-MSEP.csv - spreadsheet output of the summary table. Columns are FTYPE (e.g. StreamRiver; ArtificialPath); Description - a shortened version of the description associated with each FCODE (e.g. Stream/River: Perennial; Stream/River: Intermittent); MS_length_mi - the total miles of this line type in Mississippi; MSEP_length_mi - the total miles of this line type in the Mississippi Sound Estuary Program boundary.
    -  Map_of_Flowlines_MS-and-MSEP.png - very basic map of all flowlines in the state. Purple lines are within the MSEP boundary (the MSEP boundary itself is outlined in orange).
    -  flowline_outputs_MS.png - screenshot of the summary table and map
-  these values are essentially the denominator for designated use calculations  



waterbody_calcs/
-  generated 6/13/25, from data files in EPA NHD folder and script 'waterbody_calcs.R'
-  used the NHDWaterbody layer/shapefile. Had to combine multiple regions (R script 'process_EPANHD_toMS.R').
-  polygon geometry in these files.  
-  had to use st_make_valid() on the polygons; there were several duplicate vertices.
-  note: the northeast corner of the state is missing; when I tried to download the data file I got a repeat of the Lower Mississippi River Basin instead. This is probably why my calculations come up a few thousand miles less than DEQ's estimate of 82,000 miles in the state; and makes me feel comfortable with the calculations of lengths inside the MSEP boundary.
-  contains:
    -  Calculated_WaterbodyAreas_MS-and_MSEP.csv - spreadsheet output of summary table. Columns are ftype (LakePond, Resevoir, SwampMarsh); Description - a shortened version of the description associated with each fcode (e.g. Lake/Pond: Intermittent; Reservoir: Aquaculture); several columns of calculated areas. First for the entire (portion represented here) state of MS, in square miles (MS_sqmi) then acres (MS_acres). Then for the MSEP boundary, in square miles (MSEP_sqmi) followed by acres (MSEP_acres). Finally, because MDEQ separately quantifies lakes/ponds that are > 25 acres, the columns are repeated for data first filtered to water bodies of 25 acres or more in size; 'GT25' in a column name represents that the sum only includes water bodies *G*reater *T*han *25* acres (MSGT25_sqmi etc.).
    -  Map_of_Waterbodies_MS-and-MSEP.png - very basic map of all waterbodies (from this layer) in the state. This is all-inclusive; it includes water bodies <25 acres in size. Purple waterbodies are within the MSEP boundary (the MSEP boundary itself is outlined in orange).
    -  waterbody_outputs_MS.png - screenshot of the summary table and map
-  these values are essentially the denominator for designated use calculations  


wetland_inventory_calcs/
-  generated 6/19/25, from data files in NWI folder and script 'wetland_inventory_calculations.R'
-  first trimmed data from full NWI Mississippi coverage to only that within MS boundaries and within MSEP boundaries (where MSEP boundary was restricted to the state line, not the full HUCs); using script 'NWI_process_to_MSEPboundary.R'
-  then calculated wetland areas by wetland type (in the attribute table) for the entire state of MS and only the MSEP-within-MS boundary
-  totals were converted to multiple units (acres, sqkm, sqmi), then joined; with MS_ as the prefix for full-state totals, and MSEP_ as the prefix for MSEP-area totals
-  for each of the two geographies, two totals were calculated per wetland type: grand total, and total of those areas that were >=25 acres, which seems to match DEQ's use for lakes/ponds/reservoirs in the 2024 305b report table 1.  
-  two files were written out: one for each type of total.  
    -  wetland_areas_all.csv - the grand total
    -  wetland_areas_GT25.csv - the totals after filtering to only polygons of 25 acres or larger
