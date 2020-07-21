# stsmap repository

This repository generates the public map from the sts model. The `stsmodel` repository contains the 
model code itself.

## Usage

With both `stsmodel` and `stsmap` attached as packages:

```
R> area_gpkg ="path/to/UK2019mod_pop.gpkg"
R> linelist = "path/to/Anonymised Combined Line List 20200713.xlsx"
R> trafficdata = "path/to/200616_COVID19_road_traffic_national_table.xlsx"
R> flow = "path/to/mergedflows.rds"
R> alldata = read_all(cases=linelist, flows=flow, traffic=trafficdata, areas=area_gpkg)
R> model_and_map(alldata, "./Outputs/", useDate=TRUE)
```

will run `launch()` from `stsmodel` to fit the model based on the data in `alldata`, and then
use code in `stsmap` to build maps and plots in a subdirectory of `./Outputs/` named after
the last day in the line list data.

That folder can be viewed directly in a web browser using a `file:///` URL.

In "production" mode, the output folder will be in `stsmap/inst/days/` and pushed to `gitlab.com`. That 
triggers a CI job which copies the latest day in that folder to `./public` to create the web page. To 
view historical outputs, clone this repository and view the folders directly in the `stsmap/inst/days`.

