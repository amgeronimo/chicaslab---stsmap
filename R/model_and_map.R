model_and_map <- function(alldata,
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

    last_day = max(as.Date(alldata$cases$specimen_date))
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
        ## launch will store file metadata file here for checksums
    }

    outputdir = normalizePath(outputdir)
    od = ip(outputdir) # now the normalized path exists.
    message("output dir is ",outputdir)

    stsmodel::launch(outputdir, alldata)

    message("making map")
    
    make_od_map(outputdir)
    build_plots(outputdir)
    if(clean){
        clean_up(outputdir)
    }
}
    
make_od_map <- function(outputdir){
    od = ipf(normalizePath(outputdir))
    meta = readRDS(od("run_meta.rds"))
    last_day = meta$last_day
    fandp = fits_and_predicts(outputdir)
    pf = fandp$fits
    epg = read.csv(od("ex_prob_gr.csv"))
    ltla = st_read(od("data/processed/geodata/ltla.gpkg"))
    md = mapdata(ltla, epg, "lad19cd","lad19nm", pf)
    map = exmap(md, plotfolder="figs/", last_day=last_day)
    title = paste0("Covid-19 Cases and Model by LTLA, last data: ",nicedayformat(last_day))
    htmlwidgets::saveWidget(map, od("index.html"), title=title)
}

build_plots <- function(outputdir){
    od = ipf(normalizePath(outputdir))

    meta = readRDS(od("run_meta.rds"))
    last_day = meta$last_day

    fandp = fits_and_predicts(outputdir)
    if(!file.exists(file.path(outputdir,"figs"))){
        dir.create(file.path(outputdir,"figs"))
    }
    save_plots(fandp, file.path(outputdir,"figs"))
}

clean_up <- function(outputdir){
    od = ipf(normalizePath(outputdir))
    unlink(od("fitted_model_auxiliary_LTLA.RData"))
    unlink(od("fitted_model_LTLA.rds"))
    unlink(od("data"),recursive=TRUE)
    
}


is_dir_metadata_different <- function(alldata, outputdir){
    ## if the output directory doesn't exist then there's no checksums to test
    if(!file.exists(outputdir)){
        return(sm(TRUE, paste0("Output folder ",outputdir," does not exist")))
    }

    metadatafile = file.path(outputdir, "input_metadata.csv")
    ## if there's no checksum metadata file then you should probably run the model
    if(!file.exists(metadatafile)){
        return(sm(TRUE, paste0("No input_metadata.csv file in ",outputdir)))
    }
    
    ##
    previous = read.csv(file.path(outputdir, "input_metadata.csv"), stringsAsFactors=FALSE)
    this = attr(alldata, "meta")
    return(is_metadata_different(this, previous))
}

is_metadata_different <- function(alldata_meta, outputdir_meta){

    ##
    missing_this = setdiff(alldata_meta$name, outputdir_meta$name)
    if(length(missing_this)>0){
        return(sm(rerun=TRUE, paste0("Extra data items (",paste(missing_this,collapse=","), ") in new data")))
    }
    missing_prev <- setdiff(outputdir_meta$name, alldata_meta$name)
    if(length(missing_prev) > 0){
        return(sm(TRUE, paste0("Missing data items (",paste(missing_prev,collapse=","), ") in new data")))        
    }
    ## we should have the same number of rows in each data frame 
    if(nrow(alldata_meta) != nrow(outputdir_meta)){
        stop("New and old metadata tables have different number of rows")
    }
    
    sorted_all = alldata_meta[order(alldata_meta$name),]
    sorted_out = outputdir_meta[order(outputdir_meta$name),]
    diffs = sorted_all$md5 != sorted_out$md5
    if(any(diffs)){
        return(sm(TRUE, paste0("Changed md5 checksums for ",paste(sorted_all$name[diffs],collapse=","))))
    }
    
    return(sm(FALSE, "Data and md5 checksums match"))
}

sm = function(s, m, sn="status", mn="msg"){
    ## sm = status message
    ## combine two items into a list, typically the first will be a TRUE/FALSE status and
    ## the second will be a message to go with that status
    setNames(list(s,m), c(sn, mn))
}
