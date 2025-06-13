designated_use_calcs/
- generated _______, from data files provided by MDEQ in ______ folder and script _______
- contains:



stream_length_calcs/ 
- generated 6/13/25, from data files in EPA NHD folder and script 'stream_length_calcs.R'
- used the NHDFlowlines layer/shapefile. Had to combine multiple regions (R script 'process_EPANHD_toMS.R').
- multiline geometry in these files.  
- note: the northeast corner of the state is missing; when I tried to download the data file I got a repeat of the Lower Mississippi River Basin instead. This is probably why my calculations come up a few thousand miles less than DEQ's estimate of 82,000 miles in the state; and makes me feel comfortable with the calculations of lengths inside the MSEP boundary.
- contains:
  - Calculated_Flowlines_MS-and-MSEP.csv - spreadsheet output of the summary table. Columns are FTYPE (e.g. StreamRiver; ArtificialPath); Description - a shortened version of the description associated with each FCODE (e.g. Stream/River: Perennial; Stream/River: Intermittent); MS_length_mi - the total miles of this line type in Mississippi; MSEP_length_mi - the total miles of this line type in the Mississippi Sound Estuary Program boundary.
  - Map_of_Flowlines_MS-and-MSEP.png - very basic map of all flowlines in the state. Purple lines are within the MSEP boundary (the MSEP boundary itself is outlined in orange).
  - flowline_outputs_MS.png - screenshot of the summary table and map
- these values are essentially the denominator for designated use calculations  



waterbody_calcs/
- generated 6/13/25, from data files in EPA NHD folder and script 'waterbody_calcs.R'
- used the NHDWaterbody layer/shapefile. Had to combine multiple regions (R script 'process_EPANHD_toMS.R').
- polygon geometry in these files.  
- had to use st_make_valid() on the polygons; there were several duplicate vertices.
- note: the northeast corner of the state is missing; when I tried to download the data file I got a repeat of the Lower Mississippi River Basin instead. This is probably why my calculations come up a few thousand miles less than DEQ's estimate of 82,000 miles in the state; and makes me feel comfortable with the calculations of lengths inside the MSEP boundary.
- contains:
  - Calculated_WaterbodyAreas_MS-and_MSEP.csv - spreadsheet output of summary table. Columns are ftype (LakePond, Resevoir, SwampMarsh); Description - a shortened version of the description associated with each fcode (e.g. Lake/Pond: Intermittent; Reservoir: Aquaculture); several columns of calculated areas. First for the entire (portion represented here) state of MS, in square miles (MS_sqmi) then acres (MS_acres). Then for the MSEP boundary, in square miles (MSEP_sqmi) followed by acres (MSEP_acres). Finally, because MDEQ separately quantifies lakes/ponds that are > 25 acres, the columns are repeated for data first filtered to water bodies of 25 acres or more in size; 'GT25' in a column name represents that the sum only includes water bodies *G*reater *T*han *25* acres (MSGT25_sqmi etc.).
  - Map_of_Waterbodies_MS-and-MSEP.png - very basic map of all waterbodies (from this layer) in the state. This is all-inclusive; it includes water bodies <25 acres in size. Purple waterbodies are within the MSEP boundary (the MSEP boundary itself is outlined in orange).
  - waterbody_outputs_MS.png - screenshot of the summary table and map
- these values are essentially the denominator for designated use calculations  
