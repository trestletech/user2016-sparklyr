library(raster)
library(shiny)
library(leaflet)
library(sparklyr)
library(dplyr)

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
  
  output$map <- renderLeaflet({
    req(selected())
    print(as.data.frame(bins()))
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
    
    print(summary(grid))
    
    ras <- raster(grid,
                  xmn=min(localBins$longbin), xmx=max(localBins$longbin),
                  ymn=min(localBins$latbin), ymx=max(localBins$latbin),
                  crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))
    
    pal <- colorNumeric(c(rgb(0,0,0), rgb(0,.5,0), rgb(1, 0, 0)), values(ras),
                        na.color = "transparent")
    leaflet() %>% addTiles() %>% 
      addRasterImage(ras, colors=pal, opacity=0.6) %>% 
      addLegend(pal = pal, values = values(ras), title = paste0("% ", input$reason))
  }) 
  
})
