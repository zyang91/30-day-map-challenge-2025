library(sf)
library(tidyverse)
library(leaflet)


# Custom cluster options
cluster1 <- markerClusterOptions(
  iconCreateFunction = JS("
    function (cluster) {
      return new L.DivIcon({
        html: '<div style=\"background-color:#3182bd;color:white;border-radius:50%;padding:10px;text-align:center;font-weight:bold;\">' + cluster.getChildCount() + '</div>',
        className: 'custom-cluster1',
        iconSize: new L.Point(40, 40),
        iconAnchor: new L.Point(20, 20)
      });
    }
  ")
)

cluster2 <- markerClusterOptions(
  iconCreateFunction = JS("
    function (cluster) {
      return new L.DivIcon({
        html: '<div style=\"background-color:#e6550d;color:white;border-radius:50%;padding:10px;text-align:center;font-weight:bold;\">' + cluster.getChildCount() + '</div>',
        className: 'custom-cluster2',
        iconSize: new L.Point(40, 40),
        iconAnchor: new L.Point(20, 20)
      });
    }
  ")
)

# Overlay with Penn Health Facilities
# notes: due to University policy and security concerns, the raw dataset cannot be shared publicly. 
# Please replace the file path with your local file path to run the code.
data_sf <- st_read(".../upenn_core_campus_buildings_2025.geojson")
penn_health<- st_read(".../penn_health.geojson")
bid<-st_read("../university_city.geojson")
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron, # Simplified white basemap
                   options = providerTileOptions(noWrap = TRUE)) %>%
  addCircleMarkers(
    data = data_sf,
    radius = 2,
    color = "blue",
    opacity = 0.8,
    group="Core Campus Buildings",
    clusterOptions = cluster1,
    popup = ~paste0("<strong>Building Name: </strong>", Building.Name, "<br>",
                    "<strong>Occupant: </strong>", Primary.Parent.Occupant, "<br>",
                    "<strong>Area: </strong>", Assignable.Area...Sq.Ft, "<br>"),
  ) %>%
  addCircleMarkers(
    data = penn_health,
    radius = 2,
    color = "red",
    opacity = 0.8,
    group="Penn Health Facilities",
    clusterOptions = cluster2,
    popup = ~paste0("<strong>Type: </strong>", USER_Type, "<br>",
                    "<strong>Name: </strong>", USER_Property_Name, "<br>",
                    "<strong>City: </strong>", USER_City, "<br>"),
  ) %>%
  addControl("<strong>UPenn Core Campus Buildings Report 2025 (Blue) & Penn Health Facilities (Red)</strong>", position = "topright")%>%
  addPolygons(
    data = bid,
    color = "green",
    weight = 2,
    fill = TRUE,
    opacity = 0.8)%>%
# Add legend
  addLegend(position = "bottomright",
            colors = c("blue", "red", "green"),
            labels = c("Core Campus Buildings", "Penn Health Facilities", "University City Boundary"),
            title = "Legend")%>%
  addLayersControl(
    overlayGroups = c("Core Campus Buildings", "Penn Health Facilities"),
    options = layersControlOptions(collapsed = FALSE)
  )
