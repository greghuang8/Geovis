#SA 8905 Geovisualization Project - Part 2
#Using Mapdeck in R 
#Author: Gregory Huang
#Reference: David Cooley, https://symbolixau.github.io/mapdeck/articles/mapdeck.html
#Current Version: 0.3
#Date: 19 November 2019
#Past Versions:
#0.1         Initial Code Creation
#0.2         Added shinyApp capabilities
#0.3         Added more shinyApp capabilities
#
#This is part 2 of the Geovisualization project. 



# for data wrangling
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

#create arcs for flights out of those two airports with mapdeck
#remember to add your own key between the quotation marks or else it won't work
key <- ''


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


# Shiny capabilities (drop-down menu) 
shinyApp(
  ui <- fluidPage(
    selectInput("select", label = h3("Select a map:"),
                c("Frankfurt" = "Frankfurt",
                  "Toronto" = "Toronto",
                  "Both" = "Both")),
    mapdeckOutput(outputId = "map")
  ),
  
  server <- function(input, output) {
    output$map <- renderMapdeck({
      mapdeck(token = key, style = 'mapbox://styles/gregoryhuang/ck33n2hav1vtn1cnkr16ls3uq', pitch = 20)
    })
    
    observeEvent({input$select},
                 {if(input$select == "Frankfurt"){
                   mapdeck_update(map_id = "map")%>%
                     clear_arc(layer_id = "yyz_arcs")%>%
                     clear_arc(layer_id = "yyz_fra_arcs")%>%
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
                       layer_id = 'fra_arcs')}
                   
                   else if (input$select == "Toronto"){
                     mapdeck_update(map_id = "map")%>%
                       clear_arc(layer_id = "fra_arcs")%>%
                       clear_arc(layer_id = "yyz_fra_arcs")%>%
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
                         layer_id = 'yyz_arcs')}
                   
                   else if (input$select == "Both"){
                     mapdeck_update(map_id = "map")%>%
                       clear_arc(layer_id = "fra_arcs")%>%
                       clear_arc(layer_id = "yyz_arcs")%>%
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
                         layer_id = 'yyz_fra_arcs')}})}
)



#shiny slidertable function 

ui2 <- dashboardPage(
  dashboardHeader(), dashboardSidebar(),
  dashboardBody(
    mapdeckOutput(outputId = 'myMap'),
    sliderInput(
      inputId = "longitudes",
      label = "Longitudes",
      min = -180,
      max = 180,
      value = c(-180,-90)),
    verbatimTextOutput(outputId = "observed_click")))

server2 <- function(input, output) {
  
  set_token(key) 
  slidertable <- all_flights
  
  output$myMap <- renderMapdeck({
    mapdeck(style = 'mapbox://styles/gregoryhuang/ck33n2hav1vtn1cnkr16ls3uq', pitch = 20) 
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
        update_view = FALSE
      )
    })
  }

shinyApp(ui2,server2)
