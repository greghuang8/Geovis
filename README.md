# Geovis
SA8905 Geovisualization Project - Mapdeck R Package  
Created by: Gregory Huang  
References: David Cooley, https://symbolixau.github.io/mapdeck/articles/mapdeck.html  
Initial Commit: Nov 17th, 2019  
Last update:    Nov 21st, 2019

Tl;dr: For those who want to jump right into playing with the ShinyApp:  
https://greghuang8.shinyapps.io/geovis/

=====  

This module is divided into two main focuses. The first focus is a demonstration of mapdeck's capabilities, including drawing arcs, lines, text, and others; as well as the package's customizability. The second focus is an application on a large real-life dataset to show how this package may be applied using open access data, including using Shiny as an interactive interface.  


The first focus will be demonstrated via the longest_flights.R code. The second focus will be demonstrated via the yyz_fra.R code. Finally, shinyApp.R is created for a quick look at the shiny interface I created. Just download the relevant files and Run (in web browser). 

To run the longest_flights.R code:  
1. Download, save, and open longest_flights.R in R Studio  
2. Download airports.csv and Longest_flights.csv into the same folder as longest_flights  
3. Acquire a valid map token from mapbox.com  
4. Use that map token as the "key" variable in longest_flights.R  
5. Run longest_flights.R  
6. Under the "Viewer" tab in the right hand side of the window, click on the "show in new window" icon  
7. The map should be displayed on your broswer  

To run the yyz_fra.R code:  
1. Download and save yyz_fra.R, all_airports.csv, openflights-export-2019-11-19.csv, and fra.csv.  
2. Open yyz_fra.R and Run. Same instructions apply for running mapdeck.  
3. Read the comments. There can be multiple variations of the maps run - you can just run specific chunks of code to get separate results.    
4. Run all code in the shinyApp function. Go to "show in new window" icon, and click on "view in web browser" to use the interactive map.  


Please forward any questions or comments to gregory.huang@ryerson.ca.   
Find us at https://spatial.blog.ryerson.ca! I have a blog post there for more details on the project.    


