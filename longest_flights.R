#SA 8905 Geovisualization Project
#Using Mapdeck in R 
#Author: Gregory Huang
#References: David Cooley, https://symbolixau.github.io/mapdeck/articles/layers.html
#Current Version: 0.2
#Date: 17 November 2019
#Past Versions:
#0.1         Initial Code Creation
#0.2         Added text to map, as well as putting scatter plots on reserve
#

install.packages("mapdeck")
library(mapdeck)

#Longest Flights in the World - Mapped
flights <- read.csv("Longest_flights.csv")
airports <- read.csv("airports.csv")
flights$RouteInfo <- paste0("<b>",flights$flight_num, 
                            ", ", flights$dep_airport, 
                            " - ", flights$arr_airport, 
                            "; Distance: ",  flights$distance_km,
                            "</b>")
key <- 'pk.eyJ1IjoiZ3JlZ29yeWh1YW5nIiwiYSI6ImNrMGhhZzgxODAwbGszYm81eTlrOTl1dWQifQ.K01kaB-lrjqeCjNeTbvKxg'
mapdeck(token = key, style = 'mapbox://styles/gregoryhuang/ck33n2hav1vtn1cnkr16ls3uq', pitch = 20) %>%
  add_arc(
    data = flights,
    origin = c("start_lon", "start_lat"),
    destination = c("end_lon", "end_lat"),
    stroke_from = "dep_airport",
    stroke_to = "arr_airport",
    auto_highlight = TRUE,
    stroke_width = 3,
    tooltip = "RouteInfo",
    update_view = TRUE,
    layer_id = 'arclayer')%>%
  # add_scatterplot(
  #   data = flights,
  #   lon = "start_lon",
  #   lat = "start_lat",
  #   radius = 10000,
  #   fill_colour = "#00FF00", #lime green
  #   layer_id = "start_airport")%>%
  # add_scatterplot(
  #   data = flights,
  #   lon = "end_lon",
  #   lat = "end_lat",
  #   radius = 10000,
  #   fill_colour = "#00FF00",
  #   layer_id = "end_airport")%>%
  add_text(
    data = airports,
    lon = 'lon',
    lat = 'lat',
    fill_colour = '#FFFFFF',
    text = 'display_name',
    layer_id = 'airport_names',
    size = 16
  )
  
