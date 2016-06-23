library(raster)
library(shiny)
library(leaflet)
library(sparklyr)
library(dplyr)

colors <- c(rgb(0,0,0), rgb(.3,.6,.2), rgb(1, .3, .3))

shinyServer(function(input, output) {
  
  selected <- reactive({
    if (is.null(input$reason)){
      NULL
    } else {
      cleanNY %>% 
        filter(CONTRIBUTING_FACTOR_VEHICLE_1 == input$reason)
    }
  })
  
  bins <- reactive({
    req(selected())
    
    cleanNY %>% 
      group_by(latbin, longbin) %>% 
      summarize(total=n()) %>% 
      inner_join(selected() %>% 
                  group_by(latbin, longbin) %>% 
                  summarize(selected=n()),
                by=c("latbin", "longbin")
      ) %>% 
      select(latbin, longbin, total, selected) %>% 
      mutate(selected = ifelse(is.na(selected), 0, as.integer(selected))) %>% # NA -> 0
      collect()
  })
  
  curRaster <- reactive({
    req(selected())
    lats <- seq(to=min(bins()$latbin), from=max(bins()$latbin), by=-0.01)
    longs <- seq(from=min(bins()$longbin), to=max(bins()$longbin), by=0.01)
    
    grid <- matrix(NA, nrow=length(lats), ncol=length(longs), dimnames=list(latitude=lats, longitude=longs))
    
    localBins <- bins() 
    for (i in 1:nrow(localBins)) {
      row <- localBins[i,]
      if (row$total > 8){
        grid[as.character(row$latbin), as.character(row$longbin)] <- row$selected / row$total * 100
      }
    }
    
    raster(grid,
           xmn=min(localBins$longbin), xmx=max(localBins$longbin),
           ymn=min(localBins$latbin), ymx=max(localBins$latbin),
           crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))
    
  })
  
  pal <- reactive({
  })
  
  output$tod <- renderPlot({
    req(selected())
    orig <- par("mar")
    
    par(mar=c(0,0,0,0))
    
    byhour <- selected() %>% 
      group_by(TIME) %>% 
      tally() %>% 
      collect() %>% 
      mutate(hour=as.numeric(gsub("(\\d+):\\d+", "\\1", TIME))) %>% 
      group_by(hour) %>% 
      tally(wt=n) %>% 
      arrange(hour)
    
    plot(byhour, type="l", ylim=c(0, max(byhour[["nn"]])))  
    text(c(0,12,23), 0, labels=c(0,12,23), pos=3)
    rug(0:23, 0.08)
  
    par(mar=orig)
  })

  output$legend <- renderPlot({
    req(curRaster())
    vals <- values(curRaster())
    minVal <- round(min(vals, na.rm = TRUE))
    maxVal <- round(max(vals, na.rm = TRUE))
    
    orig <- par("mar")
  
    par(mar=c(0,0,0,0))
    
    m <- matrix(1:100, ncol=1, nrow=100)
    pal <- colorNumeric(colors, 1:100)
    image(m, col=pal(1:100))
    
    text(.1, 0, paste0(minVal, "%"), col="#FFFFFF")
    text(.9, 0, paste0(maxVal, "%"), col="#222288")
    
    par(mar=orig)
  })
  
  output$map <- renderLeaflet({
    ras <- curRaster()
    req(ras)
    
    pal <- colorNumeric(colors, values(ras),
                        na.color = "transparent")
    
    leaflet() %>% 
      addProviderTiles("CartoDB.Positron") %>% 
      #addTiles() %>% 
      addRasterImage(ras, colors=pal, opacity=0.5)
  }) 
  
})
