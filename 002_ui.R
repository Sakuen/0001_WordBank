
# -------------------------------------------------------------------- #
# UI #
# -------------------------------------------------------------------- #


ui <- fluidPage(
  
  titlePanel('World Data Explorer'),
  
  sidebarLayout(
    
    
    sidebarPanel(
      
      # selectInput(inputId = 'Variable', label = 'Input', choices = sort(unique(d_WDI$Indicator.Name))),
      # selectizeInput(inputId = 'in_date', label = 'Date', choices = NULL, multiple = TRUE),
      # selectizeInput(inputId = 'in_country', label = 'Country', choices = NULL, multiple = TRUE),
      
      rowFilterSetUI("reactive_filters", maxcol = 3, colwidth = 3),
      hr(),
      
      selectInput(inputId = 'in_type', label = 'Select Plot Type', choices = c('Time', 'Scatter')),
      
      selectizeInput(inputId = 'in_plot_y', choices = sort(unique(d_WDI_2$Measure)), label = 'Y Axis', multiple = F),
      
      conditionalPanel(
        condition = "input.in_type == 'Scatter'",
        sliderInput(inputId = 'in_plot_time', min = min(year(d_WDI_2$Date)), max = max(year(d_WDI_2$Date)), value = c(min(year(d_WDI_2$Date)), max(year(d_WDI_2$Date))), label = 'Date'),
        selectizeInput(inputId = 'in_plot_x', choices = sort(unique(d_WDI_2$Measure)), label = 'X Axis', multiple = F),
        selectizeInput(inputId = 'in_plot_group', choices = sort(unique(d_WDI_2$Region)), label = 'Group', multiple = F)
      )
    ),
    
    mainPanel(
      
      # DT::dataTableOutput("view")
      plotlyOutput("plot") # , hover = "plot_hover"
      
    )
    
  )
  
)

