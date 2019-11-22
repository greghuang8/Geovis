#SA 8905 Geovisualization Project - Part 2
#Using Mapdeck in R 
#Author: Gregory Huang
#Reference: David Cooley, https://symbolixau.github.io/mapdeck/articles/mapdeck.html
#Current Version: 0.2
#Date: 21 November 2019


#This is the shiny app demo of the project. Assuming all required files are downloaded
#and are in the same repository(folder) as this R file, the code should run and produce a 
#shiny app. If the initial popup menu shows blank, remember to click on "view in browser" 
#to see the app. 



install.packages("mapdeck")
library(mapdeck)

#shiny library
install.packages("shiny")
library(shiny)

#load in data
all_flights <- read.csv("flights_for_shiny.csv")

#mapdeck key: copy and paste your key in between the quotation marks
key <- ""

ui <- fluidPage(
  mapdeckOutput(outputId = 'myMap'),
  sliderInput(
    inputId = "longitudes",
    label = "Longitudes",
    min = -180,
    max = 180,
    value = c(-180,-90)),
  verbatimTextOutput(outputId = "observed_click"))

server <- function(input, output) {
  
  set_token(key) 
  slidertable <- all_flights
  
  output$myMap <- renderMapdeck({
    mapdeck(style = 'mapbox://styles/gregoryhuang/ck33n2hav1vtn1cnkr16ls3uq', 
            pitch = 20,
            height = 60) 
  })
  
  ## plot points & lines according to the selected longitudes
  slidertable_reactive <- reactive({
    if(is.null(input$longitudes)) return(NULL)
    lons <- input$longitudes
    return(
      slidertable[slidertable$destination_long >= lons[1] & slidertable$destination_long <= lons[2], ]
    )
  })
  
  observeEvent({input$longitudes}, {
    if(is.null(input$longitudes)) return()
    
    mapdeck_update(map_id = 'myMap') %>%
      add_arc(
        data = slidertable_reactive(),
        origin = c("origin_long", "origin_lat"),
        destination = c("destination_long", "destination_lat"),
        stroke_from = "From",
        stroke_to = "To",
        layer_id = "myArcLayer",
        auto_highlight = TRUE,
        tooltip = "RouteInfo",
        stroke_width = 3,
        update_view = FALSE,
        focus_layer = FALSE
      )
  })
}

shinyApp(ui,server)

