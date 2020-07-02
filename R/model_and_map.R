model_and_map <- function(cases="https://coronavirus.data.gov.uk/downloads/csv/coronavirus-cases_latest.csv",
                          modeldir,
                          outputdir){
    casename = "coronavirus-cases_latest.csv"
    here = getwd()
    on.exit(setwd(here))
    modeldir = normalizePath(modeldir)

    ip = function(dir){
        function(p){
            file.path(dir,p)
        }
    }
    od = ip(outputdir)
    if(file.exists(outputdir)){
        newdata = file.path(tempdir(), "cv.csv")
        download.file(cases, newdata)
        message("Downloaded to ",newdata)
        if(file.exists(od(casename))){
            message("Testing checksums")
            if(tools::md5sum(newdata) == tools::md5sum(od(casename))){
                stop("No change in input data case file ",cases)
            }
            message("remove old folder ",outputdir," and recreate...")
            unlink(outputdir,recursive=TRUE)
            dir.create(outputdir)
            message("copying to ",od(casename))
            file.copy(newdata,od(casename))
        }else{
            file.copy(newdata,od(casename))
        }
    }else{
        dir.create(outputdir)
        download.file(cases, file.path(outputdir,casename))
    }

    outputdir = normalizePath(outputdir)
    od = ip(outputdir) # now the normalized path exists.
    message("output dir is ",outputdir)
    setwd(modeldir)

    source("R/functions.R")

    message("Stage 01")
    source("R/01.R")
    analysis01(outputdir, casefile=file.path(outputdir,casename))

    message("Stage 02")
    source("R/02.R")
    analysis02(outputdir)

    message("Stage 04")
    source("R/04.R")
    analysis04(outputdir)

    message("making map")
    
    make_od_map(outputdir)
    build_plots(outputdir)
    clean_up(outputdir)
}
    
make_od_map <- function(outputdir){
    od = ipf(normalizePath(outputdir))
    pf = read.csv(od("pred_forecast.csv"))
    epg = read.csv(od("ex_prob_gr.csv"))
    ltla = st_read(od("data/processed/geodata/ltla.gpkg"))
    md = mapdata(ltla, epg, "lad19cd","lad19nm", pf)
    map = exmap(md,imagefolder="time_series/", plotfolder="figs/")
    htmlwidgets::saveWidget(map, od("index.html"))
}

build_plots <- function(outputdir){
    od = ipf(normalizePath(outputdir))
    pf = read.csv(od("pred_forecast.csv"))
    if(!file.exists(file.path(outputdir,"figs"))){
        dir.create(file.path(outputdir,"figs"))
    }
    save_plots(pf, file.path(outputdir,"figs"))
}

clean_up <- function(outputdir){
    od = ipf(normalizePath(outputdir))
    unlink(od("fitted_model_auxiliary_LTLA.RData"))
    unlink(od("fitted_model_LTLA.rds"))
    unlink(od("data"),recursive=TRUE)
    
}
    
