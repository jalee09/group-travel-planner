ui <- dashboardPage(
  dashboardHeader(title = "Group Trip Planner"),
  dashboardSidebar(
    dateInput("departure_date", "Departure Date:", value = "2016-05-15"),
    dateInput("return_date", "Return Date:", value = "2016-05-22"),
    sliderInput("num_travelers", "Number of Travelers:", 
                min=1, max=4, value=1),
    selectInput("country1", "Origin Country:", sort(countries$Name), selected="United States"),
    conditionalPanel(
      condition = "input.num_travelers > 1",
      selectInput("country2", "Origin Country (#2):", sort(countries$Name), selected="United States")
    ),
    conditionalPanel(
      condition = "input.num_travelers > 2",
      selectInput("country3", "Origin Country (#3):", sort(countries$Name), selected="United States")
    ),
    conditionalPanel(
      condition = "input.num_travelers > 3",
      selectInput("country4", "Origin Country (#4):", sort(countries$Name), selected="United States")
    )
  ),
  dashboardBody(
    fluidRow(
      tabBox(
        title = "Destination countries by total price",
        id = "tabset1", 
        width = NULL, 
        status = "warning", 
        tabPanel("Map", htmlOutput('mapOutput')),
        tabPanel("Table", DT::dataTableOutput('mytable1'))
      ),
      downloadButton('downloadData', 'Download CSV')
    ) 
  )
)