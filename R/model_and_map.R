model_and_map <- function(linelist,
                          unrestricted,
                          restricted,
                          outputdir,
                          useDate=FALSE,
                          force=FALSE,
                          clean=TRUE){

    here = getwd()
    on.exit(setwd(here))

    ip = function(dir){
        function(p){
            file.path(dir,p)
        }
    }

    
    casedata = stsmodel::read_casefile(linelist)
    last_day = max(as.Date(casedata$specimen_date))
    if(useDate){
        outputdir=file.path(outputdir, as.character(last_day))
    }
    od = ip(outputdir)
    if(file.exists(outputdir)){
        message("Testing checksums skipped for now.")
        ## TODO check checkums here
    }else{
    ## if the dir doesn't exist, create it.
        dir.create(outputdir)
        ## TODO create md5 checksum for the data here
    }

    outputdir = normalizePath(outputdir)
    od = ip(outputdir) # now the normalized path exists.
    message("output dir is ",outputdir)

    stsmodel::launch(outputdir, linelist, unrestricted, restricted)

    message("making map")
    
    make_od_map(outputdir, last_day)
    build_plots(outputdir, last_day)
    if(clean){
        clean_up(outputdir)
    }
}
    
make_od_map <- function(outputdir, last_day){
    od = ipf(normalizePath(outputdir))
    pf = read.csv(od("pred_forecast.csv"))
    epg = read.csv(od("ex_prob_gr.csv"))
    ltla = st_read(od("data/processed/geodata/ltla.gpkg"))
    md = mapdata(ltla, epg, "lad19cd","lad19nm", pf)
    map = exmap(md,imagefolder="time_series/", plotfolder="figs/", last_day=last_day)
    title = paste0("Covid-19 Cases and Model by LTLA, last data: ",nicedayformat(last_day))
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
    
