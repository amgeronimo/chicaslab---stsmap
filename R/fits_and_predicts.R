fits_and_predicts <- function(outputdir, daysoff=7){
    od = ipf(normalizePath(outputdir))
    fits = NA
    predicts = NA
    if(file.exists(od("pred_forecast.csv"))){
        ## single file needs splitting
        fp = read.csv(od("pred_forecast.csv"))
        last_predict <- max(as.Date(fp$time))
        is_fit = as.Date(fp$time) <= (last_predict - daysoff)
        fits = fp[is_fit,]
        predicts = fp[!is_fit,]
    }
    if(all(file.exists(od("model_fitted.csv"), od("model_predicted.csv")))){
        fits = read.csv(od("model_fitted.csv"))
        predicts = read.csv(od("model_predicted.csv"))
    }
    return(list(fits=fits, predicts=predicts))
    
}
