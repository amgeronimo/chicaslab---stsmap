
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

exmap <- function(mapdata, grobs=0, imagefolder, plotfolder, last_day){
#    stopifnot(all(mapdata$code == names(grobs)))
    overs = which(mapdata$exceed1)
    unders = which(mapdata$below1)

#    overgrobs = grobs[overs]
#    undergrobs = grobs[unders]

    w = options()$warn
    options(warn=-1) # prevent CRS warnings
    mappts = st_point_on_surface(mapdata)
    options(warn=w)

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
        if(im %in% overs){
            return(htmltools::HTML(paste0("<b>",md$name," : increasing</b><br/>Case report median estimate : ",sprintf(fmt="%d", round(md$med)))))
        }
        if(im %in% unders){
            return(htmltools::HTML(paste0("<b>",md$name," : decreasing</b><br/>Case report median estimate : ",sprintf(fmt="%d", round(md$med)))))
        }
        htmltools::HTML(paste0("<b>",md$name,"</b><br/>Case report median estimate : ",sprintf(fmt="%d", round(md$med))))
        })

    ims = lapply(1:nrow(mapdata), function(im){
        md = mapdata[im,]
        ip = file.path(imagefolder, paste0(md$code,".png"))
        fp = file.path(plotfolder, paste0(md$code,".html"))
        htmltools::HTML(paste0('<b>',md$name,'</b><br/><a href="',fp,'"><img src="',ip,'"></a><br/><a href="',fp,'">Interactive Plot</a>'))
        })
    
    imagepaths = file.path(imagefolder, paste0(mapdata$lad19cd,".png"))

    tag.map.title <- tags$style(HTML("
  .leaflet-control.map-title { 
    transform: translate(-50%,20%);
    xxxposition: fixed !important;
    left: 50%;
    xxtext-align: center;
    padding-left: 10px; 
    padding-right: 10px;
margin-bottom: 4em;
    background: rgba(255,255,255,0.75);
    xxxfont-weight: bold;
width: 10em;
    font-size: 1.5em;
  }
"))
 
    last_day = as.Date(last_day)
    niceday = nicedayformat(last_day)
    text = paste0("<p>Case counts, markers show significant increasing and decreasing areas.</p><p>Last data report: ", niceday,"</p>")
    title <- tags$div(
                      tag.map.title, HTML(text)
                  )  
    popopts = list(minWidth=350, maxWidth=350)
    M = leaflet() %>%
        addProviderTiles("Esri.WorldGrayCanvas")
    if(length(unders)>0){
        M = M %>% addAwesomeMarkers(data=mappts[unders,],
                                    group="unders", icon=undericons,
                                    label=labs[unders],
                                    popup=ims[unders], popupOptions=popopts
                                    )
    }
    if(length(overs)>0){
        M = M %>% addAwesomeMarkers(data=mappts[overs,], group="overs",icon=overicons, label=labs[overs],
                                    popup=ims[overs], popupOptions=popopts)
    }
    M = M %>%  addPolygons(data=mapdata, group="map", fillColor=~pal(med), fillOpacity=0.75, color="#404040", weight=1, opacity=1,
                    label=labs,
                    popup=ims,
                    popupOptions=popopts) %>%
        
        addLegend(data=mapdata, "topright", pal = pal, values = ~med,
                  title = "Case count",
                  opacity = 1) %>%
        addControl(title, position = "bottomleft", className="map-title")
    return(M)
}


suffice = function(n){
    n = as.character(n)
    suff=list("1"="st", "21"="st", "31"="st", "2"="nd", "22"="nd", "3"="rd", "23"="rd")
    if(n %in% names(suff)){
        return(paste0(n,suff[n]))
    }else{
        return(paste0(n,"th") )
    }
}

nicedayformat <- function(d){
    d = as.Date(d)
    format(d,paste0("%A, %B ",suffice(format(d,"%-d"))," %Y"))
}
