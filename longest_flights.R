#SA 8905 Geovisualization Project
#Using Mapdeck in R 
#Author: Gregory Huang
#References: David Cooley, https://symbolixau.github.io/mapdeck/articles/layers.html
#Current Version: 0.1
#Date: 17 November 2019
#Past Versions:
#0.1         Initial Code Creation
#
#

install.packages("mapdeck")
library(mapdeck)

#Longest Flights in the World - Mapped
flights <- read.csv("Longest_flights.csv")
flights$RouteInfo <- paste0("<b>",flights$flight_num, 
                            ", ", flights$dep_airport, 
                            " - ", flights$arr_airport, 
                            "; Distance: ",  flights$distance_km,
                            "</b>")
key <- 'pk.eyJ1IjoiZ3JlZ29yeWh1YW5nIiwiYSI6ImNrMGhhZzgxODAwbGszYm81eTlrOTl1dWQifQ.K01kaB-lrjqeCjNeTbvKxg'

mapdeck(token = key, style = 'mapbox://styles/mapbox/dark-v9', pitch = 45) %>%
  add_arc(
    data = flights
    , origin = c("start_lon", "start_lat")
    , destination = c("end_lon", "end_lat")
    , stroke_from = "dep_airport"
    , stroke_to = "arr_airport"
    , tooltip = "RouteInfo"
    , layer_id = 'arclayer'
  )
