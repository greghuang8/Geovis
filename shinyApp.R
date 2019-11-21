#SA 8905 Geovisualization Project - Part 2
#Using Mapdeck in R 
#Author: Gregory Huang
#Reference: David Cooley, https://symbolixau.github.io/mapdeck/articles/mapdeck.html
#Current Version: 0.1
#Date: 20 November 2019


#This is the shiny app demo of the project. Assuming all required files are downloaded
#and are in the same repository(folder) as this R file, the code should run and produce a 
#shiny app. If the initial popup menu shows blank, remember to click on "view in browser" 
#to see the app. 


install.packages("dplyr")
library(dplyr)

install.packages("mapdeck")
library(mapdeck)

#shiny library
library(shiny)
install.packages("shinydashboard")
library(shinydashboard)

#clean up airport coordinates 
all_airport_coordinates <- read.csv("all_airports.csv")
all_airport_coordinates <- select(all_airport_coordinates, iata_code, name, longitude_deg, latitude_deg)
colnames(all_airport_coordinates)[1] <- "To"
write.csv(all_airport_coordinates, "all_airports_cleaned.csv")

#clean up YYZ flights
ac_flights <- read.csv("openflights-export-2019-11-19.csv")

toDelete <- seq(1, nrow(ac_flights), 2)
ac_flights <- ac_flights[toDelete,]

ac_flights <- select(ac_flights, From, To, Airline, Distance, Duration)
yyz_ac_flights <- merge(ac_flights,all_airport_coordinates, by = "To")

colnames(yyz_ac_flights)[7:8] <- c("destination_long", "destination_lat")

yyz_ac_flights$origin_long <- rep(-79.6248,nrow(yyz_ac_flights)) 
yyz_ac_flights$origin_lat <- rep(43.6777, nrow(yyz_ac_flights))
yyz_ac_flights <- yyz_ac_flights[!duplicated(yyz_ac_flights$To),]

#add route info for display later
yyz_ac_flights$RouteInfo <- paste0("<b>",
                                   yyz_ac_flights$From, 
                                   " - ", yyz_ac_flights$To,
                                   "; Airline: ", yyz_ac_flights$Airline,
                                   "; Distance: ",  yyz_ac_flights$Distance,
                                   "; Flight Time: ", yyz_ac_flights$Duration, "Hrs",
                                   "</b>")

#Frankfurt flights
fra_flights <- read.csv("fra.csv")
toDelete <- seq(1, nrow(fra_flights), 2)
fra_flights <- fra_flights[toDelete,]

fra_flights <- select(fra_flights, From, To, Airline, Distance, Duration)
fra_flights <- merge(fra_flights, all_airport_coordinates, by = "To")
colnames(fra_flights)[7:8] <- c("destination_long", "destination_lat")


fra_flights$origin_long <- rep(8.5622,nrow(fra_flights)) 
fra_flights$origin_lat <- rep(50.0379, nrow(fra_flights))
fra_flights <- fra_flights[!duplicated(fra_flights$To),]

#add route info for display later
fra_flights$RouteInfo <- paste0("<b>",
                                fra_flights$From, 
                                " - ", fra_flights$To,
                                "; Airline: ", fra_flights$Airline,
                                "; Distance: ",  fra_flights$Distance,
                                "; Flight Time: ", fra_flights$Duration, "Hrs",
                                "</b>")

#final table for mapdeck (both yyz and fra airports)
yyz_fra <- rbind(yyz_ac_flights, fra_flights)

#add more flights
ams_flights <- read.csv("ams.csv")
dxb_flights <- read.csv("dxb.csv")
kef_flights <- read.csv("kef.csv")

flight_list <- list(ams_flights, dxb_flights, kef_flights)
long_list <- c(4.7683, 55.3657, -22.6350)
lat_list <- c(52.3105, 25.2532, 63.9786)

for (i in seq(1,3)){
  toDelete <- seq(1, nrow(flight_list[[i]]), 2)
  flight_list[[i]] <- flight_list[[i]][toDelete,]
  flight_list[[i]] <- select(flight_list[[i]], From, To, Airline, Distance, Duration)
  flight_list[[i]] <- merge(flight_list[[i]], all_airport_coordinates, by = "To")
  colnames(flight_list[[i]])[7:8] <- c("destination_long", "destination_lat")
  flight_list[[i]]$origin_long <- rep(long_list[i], nrow(flight_list[[i]]))
  flight_list[[i]]$origin_lat <- rep(lat_list[i], nrow(flight_list[[i]]))
  flight_list[[i]] <- flight_list[[i]][!duplicated(flight_list[[i]]$To),]
  flight_list[[i]]$RouteInfo <- paste0("<b>",
                                       flight_list[[i]]$From, 
                                       " - ", flight_list[[i]]$To,
                                       "; Airline: ", flight_list[[i]]$Airline,
                                       "; Distance: ",  flight_list[[i]]$Distance,
                                       "; Flight Time: ", flight_list[[i]]$Duration, "Hrs",
                                       "</b>")
}

ams_flights <- flight_list[[1]]
dxb_flights <- flight_list[[2]]
kef_flights <- flight_list[[3]]

all_flights <- rbind(yyz_fra, ams_flights, dxb_flights, kef_flights)

#mapdeck key
key <- 'pk.eyJ1IjoiZ3JlZ29yeWh1YW5nIiwiYSI6ImNrMGhhZzgxODAwbGszYm81eTlrOTl1dWQifQ.K01kaB-lrjqeCjNeTbvKxg'

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
        focus_layer = TRUE
      )
  })
}

shinyApp(ui,server)

