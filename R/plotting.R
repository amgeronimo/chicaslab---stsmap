save_plots <- function(preds, ddir){
    ddir = normalizePath(ddir)
    for(code in unique(preds$lad19cd)){
        fig = make_plot_for(preds, code)
        save_html(fig,file.path(ddir,paste0(code,".html")))
    }
}

make_plot_for <- function(preds, code){
    preds$time = as.Date(preds$time)
    pred = preds[preds$lad19cd == code,]
    fore = pred[is.na(pred$observed),]
    pred = pred[!is.na(pred$observed),]
    make_plotly(pred, fore)
}

make_ggplot <- function(ltla_pred, ltla_forecast){
    ltla_pred$time = as.Date(ltla_pred$time)
    ltla_forecast = rbind(ltla_pred[nrow(ltla_pred),], ltla_forecast)
###  ltla_forecast <- forecast[forecast$lad19cd == i, ] %>% 
#    bind_rows(ltla_pred[ltla_pred$time == pred_start - 1, ])
#  ltla_forecast$ltla_name <- name
  ggplot(ltla_pred, aes(x = time)) +
    geom_ribbon(aes(ymin = low50, ymax = up50), fill = "dodgerblue3", alpha = .3) +
    geom_ribbon(aes(ymin = low95, ymax = up95), fill = "dodgerblue3", alpha = .3) +
    geom_ribbon(data = ltla_forecast, aes(ymin = low50, ymax = up50), 
                fill = "orange", alpha = .3) +
    geom_ribbon(data = ltla_forecast, aes(ymin = low95, ymax = up95), 
                fill = "orange", alpha = .3) +
    geom_line(aes(y = median), col = "dodgerblue3", size = .8) +
    # geom_line(aes(y = mean), col = "dodgerblue3", size = .8, linetype = 2) +
    geom_line(data = ltla_forecast, aes(y = median), col = "orange", size = .8) +
    # geom_line(data = ltla_forecast, aes(y = mean), col = "orange", size = .8, linetype = 2) +
    geom_line(aes(y = observed), linetype = 2) +   
    # geom_point(aes(y = observed), shape = 21) + 
#    facet_wrap(~ ltla_name, scales = "free_y") +
    labs(x = "", y = "Reported cases") +
    scale_x_date(date_breaks = "1 week", date_labels = "%b %d") +
    coord_cartesian(expand = 0)
}

make_plotly <- function(pred, fore){

    xaxis = list(title="Date")
    yaxis = list(title="Count")

    ## make the first prediction join up with the last data:
    fore = rbind(pred[nrow(pred),], fore)
    
    fig = plot_ly(pred, x=~time)



    fig <- fig %>% add_ribbons(ymin=~low95, ymax=~up95,
                               legendgroup="Model",
                               visible="legendonly",
                               line=list(color="transparent"),fillcolor='rgb(208,227,245)',
                               showlegend=TRUE, name="95% CI") # name doesn't show
    fig <- fig %>% add_ribbons(ymin=~low50, ymax=~up50,
                               legendgroup="Model",
                               visible="legendonly",
                               line=list(color="transparent"),fillcolor='rgb(171,205,237)',
                               showlegend=TRUE, name="50% CI") # name doesn't show
    fig  <- fig %>% add_trace(y=~mean, type="scatter",mode="lines",
                              legendgroup="Model",
                              visible="legendonly",
                              line=list(color="black"),
                              showlegend=TRUE,
                               fillcolor='rgba(100,100,80,.2)', name="Mean")


    fig <- fig %>% add_ribbons(data=fore,
                               ymin=~low95, ymax=~up95,
                               legendgroup="Forecast",
                               line=list(color="transparent"),fillcolor='rgb(255,237,204)',
                               showlegend=TRUE, name="95% CI") # name doesn't show
    fig <- fig %>% add_ribbons(ymin=~low50, ymax=~up50,
                               legendgroup="Forecast",
                               line=list(color="transparent"),fillcolor='rgb(255,201,102)',
                               showlegend=TRUE, name="50% CI") # name doesn't show

    fig <- fig %>% add_trace(x=~time, y=~mean, data=fore,
                             legendgroup="Forecast",
                              line=list(color="red"),
                              type="scatter", mode="lines", name="Forecast")
    
    fig <- fig %>% add_markers(data=pred, y=~observed, x=~time,
                               marker=list(color="red",  symbol="cross",
                                           line=list(width=1, color="white")
                                           ),
                               name="Cases")

    fig <- fig %>% layout(xaxis=xaxis, yaxis=yaxis, showlegend=TRUE, title=pred$lad19nm[1])
    return(fig)
    
}
