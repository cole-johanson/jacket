# jacket

## Overview
Editing datasets for consumption can be a bit tiresome. By reading in CSV files, Excel files, and 
SAS files and package them for use by a non-technical audience, jacket helps dataset creators quickly
create zip files containing multiple datasets.

## Installation
```
if (!require("remotes")) install.packages("remotes")
remotes::install_github('cole-johanson/jacket')
jacket::run_app()
```

## Usage

### Importing datasets
Browse and find .xlsx, .sas7bdat, and .csv files for uploading. Note that the uploaded files are now
available under the files dropdown. If a file of the same name is uploaded twice, the newer version is used. 

### Editing the datasets
The files tab contains a list of the column names. If any labels are availables (e.g. from SAS files), they 
are used as the column names. These are editable, and are automatically all selected. The user can deselect
columns to remove them from the downloaded dataset. 

### Reviewing the output
The Data Listings tab displays the output datasets. (You can quickly access the appropriate subtab by using 
the Data Listings dropdown in the side panel). 

### Downloading the content
Select the Download All link in the side panel to download the data. Your jacket output will be zipped up 
with the appropriate file names, column names, selected columns.