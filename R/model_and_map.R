model_and_map <- function(cases="https://coronavirus.data.gov.uk/downloads/csv/coronavirus-cases_latest.csv",
                          modeldir,
                          outputdir,
                          useDate=FALSE){
    casename = "coronavirus-cases_latest.csv"
    here = getwd()
    on.exit(setwd(here))
    modeldir = normalizePath(modeldir)

    ip = function(dir){
        function(p){
            file.path(dir,p)
        }
    }

    
    newdata = file.path(tempdir(), "cv.csv")
    download.file(cases, newdata)
    message("Downloaded to ",newdata)

    casedata = read.csv(newdata, stringsAsFactors=FALSE)
    last_day = max(as.Date(casedata$Specimen.date))
    if(useDate){
        outputdir=file.path(outputdir, as.character(last_day))
    }
    od = ip(outputdir)
    if(file.exists(outputdir)){
        if(file.exists(od(casename))){
            ## see if we already have this identical file
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
            ## if the csv doesn't exist, copy it
            file.copy(newdata,od(casename))
        }
    }else{
        ## if the dir doesn't exist, create it.
        dir.create(outputdir)
        file.copy(newdata,od(casename))
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
    
    make_od_map(outputdir, last_day)
    build_plots(outputdir, last_day)
    clean_up(outputdir)
}
    
make_od_map <- function(outputdir, last_day){
    od = ipf(normalizePath(outputdir))
    pf = read.csv(od("pred_forecast.csv"))
    epg = read.csv(od("ex_prob_gr.csv"))
    ltla = st_read(od("data/processed/geodata/ltla.gpkg"))
    md = mapdata(ltla, epg, "lad19cd","lad19nm", pf)
    map = exmap(md,imagefolder="time_series/", plotfolder="figs/", last_day=last_day)
    title = paste0("Covid-19 Cases and Model by LTLA, last data: ",niceformat(last_day))
    htmlwidgets::saveWidget(map, od("index.html"), title=title)
}

build_plots <- function(outputdir, last_day){
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
    
