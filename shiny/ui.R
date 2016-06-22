library(shiny)
library(leaflet)

reasons <- as.list(reasonTbl[["reason"]])
names(reasons) <- reasonTbl[["pretty"]]
reasons[["All"]] <- NULL

shinyUI(fluidPage(
  titlePanel("NYC Motor Vehicle Collisions"),
  
  sidebarLayout(
    sidebarPanel(
      shiny::selectInput("reason", "Reason: ", reasons, selected="All")
    ),
    
    mainPanel(
      leafletOutput("map", width="100%", height="400px")
    )
  )
))