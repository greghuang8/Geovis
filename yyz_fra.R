install.packages("dplyr")
library(dplyr)

install.packages("mapdeck")
library(mapdeck)

#clean up airport coordinates 
all_airport_coordinates <- read.csv("all_airports.csv")
all_airport_coordinates <- select(all_airport_coordinates, iata_code, name, longitude_deg, latitude_deg)
colnames(all_airport_coordinates)[1] <- "To"

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

#create arcs for flights out of those two airports with mapdeck
key <- 'pk.eyJ1IjoiZ3JlZ29yeWh1YW5nIiwiYSI6ImNrMGhhZzgxODAwbGszYm81eTlrOTl1dWQifQ.K01kaB-lrjqeCjNeTbvKxg'
mapdeck(token = key, style = 'mapbox://styles/gregoryhuang/ck33n2hav1vtn1cnkr16ls3uq', pitch = 20) %>%
  add_arc(
    data = yyz_fra,
    origin = c("origin_long", "origin_lat"),
    destination = c("destination_long", "destination_lat"),
    stroke_from = "From",
    stroke_to = "To",
    auto_highlight = TRUE,
    stroke_width = 3,
    tooltip = "RouteInfo",
    update_view = TRUE,
    layer_id = 'yyz_fra_arcs')


# for just yyz flights:
mapdeck(token = key, style = 'mapbox://styles/gregoryhuang/ck33n2hav1vtn1cnkr16ls3uq', pitch = 20) %>%
  add_arc(
    data = yyz_ac_flights,
    origin = c("origin_long", "origin_lat"),
    destination = c("destination_long", "destination_lat"),
    stroke_from = "From",
    stroke_to = "To",
    auto_highlight = TRUE,
    stroke_width = 3,
    tooltip = "RouteInfo",
    update_view = TRUE,
    layer_id = 'yyz_arcs')

# for just fra flights
mapdeck(token = key, style = 'mapbox://styles/gregoryhuang/ck33n2hav1vtn1cnkr16ls3uq', pitch = 20) %>%
  add_arc(
    data = fra_flights,
    origin = c("origin_long", "origin_lat"),
    destination = c("destination_long", "destination_lat"),
    stroke_from = "From",
    stroke_to = "To",
    auto_highlight = TRUE,
    stroke_width = 3,
    tooltip = "RouteInfo",
    update_view = TRUE,
    layer_id = 'fra_arcs')