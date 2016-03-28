clean_data = function(x, country){
  x$DirectPrice[which(x$DirectPrice==0)] = NA
  x$IndirectPrice[which(x$IndirectPrice==0)] = NA
  x$IndirectPrice = coalesce.na(x$IndirectPrice, x$DirectPrice)
  x[[paste0("price_",country)]] = x$IndirectPrice
  x = x %>% select(-IndirectPrice, -DirectPrice)
  return(x)
}

shinyServer(function(input, output) {
  get_data = reactive({
    selected_countries = countries[which(countries$Name==input$country1),1]
    if(input$num_travelers > 1) {
      selected_countries = c(selected_countries, countries[which(countries$Name==input$country2),1])
    }
    if(input$num_travelers > 2) {
      selected_countries = c(selected_countries, countries[which(countries$Name==input$country3),1])
    }
    if(input$num_travelers > 3) {
      selected_countries = c(selected_countries, countries[which(countries$Name==input$country4),1])
    }

    dates = c(input$departure_date, input$return_date)
    dates_month = substr(dates, 1, 7)
    data = fromJSON(paste0("http://www.skyscanner.com/dataservices/browse/v3/bvweb/US/USD/en-US/destinations/",selected_countries[1],"/anywhere/",dates_month[1],"/",dates_month[2],"/?includequotedate=true&includemetadata=true&includecityid=true&profile=minimalcityrollupwithnamesv2"))$PlacePrices %>% clean_data(selected_countries[1])
    if(length(selected_countries) > 1) {
      for(i in c(2:length(selected_countries))) {
        temp = fromJSON(paste0("http://www.skyscanner.com/dataservices/browse/v3/bvweb/US/USD/en-US/destinations/",selected_countries[i],"/anywhere/",dates_month[1],"/",dates_month[2],"/?includequotedate=true&includemetadata=true&includecityid=true&profile=minimalcityrollupwithnamesv2"))$PlacePrices %>% clean_data(selected_countries[i])
         data = data %>% inner_join(temp, by=c("Id"="Id", "Name"="Name"))
      }
    }
    
    data$total_price = data %>% select(-Id, -Name) %>% rowSums
    data = data %>% arrange(total_price)
    return(data)
  })
 
  output$mytable1 <- DT::renderDataTable({
    DT::datatable(get_data() %>% select(-Id),
                  extensions = 'FixedColumns',
    options = list(
    scrollX = TRUE,
    scrollCollapse = TRUE
    ))
  })
  
  output$mapOutput <- renderGvis({
    gvisGeoChart(get_data() %>% na.omit, locationvar="Name", 
      colorvar="total_price",
      options=list(projection="kavrayskiy-vii", colorAxis = "{colors: ['#0099F7', '#F11712']}"))
  })
  
  output$downloadData <- downloadHandler(
    filename = function() { return('flight_info.csv') },
    content = function(file) {
      write.csv(get_data(), file=file)
    }
  )

})