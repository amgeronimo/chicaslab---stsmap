
mapstyles = function(){
    list(elevs = c("over"="R over 1","under"="R under 1","uncertain"="Uncertain"),
         pal = c("#b2182b","#92c5de","#f0f0f0")
         )
}

mapstyles2 = function(){
    list(elevs = c("over"="R over 1","under"="R under 1","uncertain"="Uncertain"),
         pal = c("#FF000080","#0000FF80","#f0f0f020")
         )
}

latest_median  <- function(pf, code){
    pf$time = as.Date(pf$time)
    sps = split(pf, pf[[code]])
    slm = sapply(sps, function(sp){
        ## remove predictions
        sp = sp[!is.na(sp$observed),]
        sp$median[which.max(sp$time)]
    })
    slm
}
mapdata <- function(map, exp,codename, namename, pf){
    map$exceed1 = exp$ex_prob > .9
    map$below1 = exp$ex_prob < .1

    map$code = map[[codename]]
    map$name = map[[namename]]
    map$med = latest_median(pf, codename)
    map = st_transform(map, 4326)
    map
}

exmap <- function(mapdata, grobs=0){
#    stopifnot(all(mapdata$code == names(grobs)))
    overs = which(mapdata$exceed1 > 0.9)
    unders = which(mapdata$below1 > 0.9)

#    overgrobs = grobs[overs]
#    undergrobs = grobs[unders]
    
    mappts = st_point_on_surface(mapdata)

    undericons <- awesomeIcons(
        icon = 'arrow-graph-down-right',
        iconColor = 'black',
        library = 'ion',
        markerColor = "blue"
    )
    overicons <- awesomeIcons(
        icon = 'arrow-graph-up-right',
        iconColor = 'white',
        library = 'ion',
        markerColor = "red"
    )
    pal <- colorNumeric(
        palette = "YlOrRd",
        domain = mapdata$med
    )

    labs = lapply(1:nrow(mapdata), function(im){
        md = mapdata[im,]
        htmltools::HTML(paste0("<b>",md$name,"</b><br/>R<sub>t</sub> median estimate : ",sprintf(fmt="%04.3f", md$med)))
        })
    
    leaflet() %>%
        addProviderTiles("Esri.WorldGrayCanvas") %>%
        addAwesomeMarkers(data=mappts[unders,], group="unders", icon=undericons, label=paste0(mappts$name[unders]," : Decreasing")) %>%
        addAwesomeMarkers(data=mappts[overs,], group="overs",icon=overicons, label=paste0(mappts$name[overs]," : Increasing")) %>%
        #addPopupGraphs(overgrobs, group="overs", width=400, height=300) %>%
        addPolygons(data=mapdata, group="map", fillColor=~pal(med), fillOpacity=0.75, color="#404040", weight=1, opacity=1,
                    label=labs) %>%
        #addPopupGraphs(grobs, group="map", width=400,height=300) %>% 
        addLegend(data=mapdata, "topright", pal = pal, values = ~med,
                  title = "Median R<sub>t</sub>",
                  opacity = 1)
    
}


