#SA 8905 Geovisualization Project
#Using Mapdeck in R 
#Author: Gregory Huang
#Reference: David Cooley, https://symbolixau.github.io/mapdeck/articles/mapdeck.html
#Current Version: 0.2
#Date: 17 November 2019
#Past Versions:
#0.1         Initial Code Creation
#0.2         Added text to map, as well as putting scatter plots on reserve
#0.3         Added new maps and included simple US flight data
#0.4         Minor updates; mostly design changes

install.packages("mapdeck")
library(mapdeck)


#Mapbox access token
key <- 'pk.eyJ1IjoiZ3JlZ29yeWh1YW5nIiwiYSI6ImNrMGhhZzgxODAwbGszYm81eTlrOTl1dWQifQ.K01kaB-lrjqeCjNeTbvKxg'

#Prepping data: Longest flights in the world 
flights <- read.csv("Longest_flights.csv")
airports <- read.csv("airports.csv")
flights$RouteInfo <- paste0("<b>",flights$flight_num, 
                            " ", flights$dep_airport, 
                            " - ", flights$arr_airport, 
                            "; Distance: ",  flights$distance_km,
                            "; Aircraft Type: ", flights$aircraft,
                            "; Flight Time: ", flights$time_hrs, "Hrs",
                            "</b>")

#Prepping data: US flights
url <- 'https://raw.githubusercontent.com/plotly/datasets/master/2011_february_aa_flight_paths.csv'
US_flights <- read.csv(url)
US_flights$info <- paste0("<b>",US_flights$airport1, " - ", US_flights$airport2, "</b>")


#Longest Flights in the World - Mapped with arcs
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
  

#Longest flights mapped with lines instead of arcs
mapdeck(token = key, style = 'mapbox://styles/gregoryhuang/ck33n2hav1vtn1cnkr16ls3uq', pitch = 20) %>%
  add_line(
    data = flights,
    destination = c("start_lon", "start_lat"),
    origin = c("end_lon", "end_lat"),
    auto_highlight = TRUE,
    stroke_width = 2,
    tooltip = "RouteInfo",
    update_view = TRUE,
    stroke_colour = '#FF9933',
    layer_id = 'linelayer')%>%
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
      size = 16) 

# Map with both US flights and Longest flights
mapdeck(token = key, style = 'mapbox://styles/gregoryhuang/ck33n2hav1vtn1cnkr16ls3uq', pitch = 20) %>%
  add_line(
    data = US_flights,
    origin = c("start_lon", "start_lat"),
    destination = c("end_lon", "end_lat"),
    auto_highlight = TRUE,
    tooltip = "info",
    stroke_width = 1.5,
    layer_id = 'flight_routes'
  )%>%
  add_arc(
    data = flights,
    origin = c("start_lon", "start_lat"),
    destination = c("end_lon", "end_lat"),
    stroke_from = "dep_airport",
    stroke_to = "arr_airport",
    auto_highlight = TRUE,
    stroke_width = 4,
    tooltip = "RouteInfo",
    update_view = TRUE,
    layer_id = 'arclayer')%>%
  add_text(
    data = airports,
    lon = 'lon',
    lat = 'lat',
    fill_colour = '#FFFFFF',
    text = 'display_name',
    layer_id = 'airport_names',
    size = 16)%>%
  add_scatterplot(
    data = flights,
    lon = "start_lon",
    lat = "start_lat",
    radius = 7000,
    fill_colour = "#00FF00", #lime green
    layer_id = "start_airport")%>%
  add_scatterplot(
    data = flights,
    lon = "end_lon",
    lat = "end_lat",
    radius = 7000,
    fill_colour = "#00FF00",
    layer_id = "end_airport")




