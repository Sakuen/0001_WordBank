
# -------------------------------------------------------------------- #
# SERVER #
# -------------------------------------------------------------------- #

server <- function(input, output, session) {
  
  
  # MAKE DATA REACTIVE 
  dt_original <- reactive({ dt.filtered <- d_WDI_2 })
  
  dt_filtered <- callModule(columnFilterSet, "reactive_filters", df = dt_original, maxcol = 3)

  dt_plot <- reactive({

    dt_aggregation <- dt_filtered() %>% 
      dplyr::filter(
        Measure %in% c(input$in_plot_x, input$in_plot_y),
        dplyr::between(year(Date), input$in_plot_time[1], input$in_plot_time[2])
        ) 
      
    # IN CASE MANY COUNTRIES -> CALCULATE AVERAGE
    if ( length(unique(dt_filtered()$Country)) > 10) {
      
      dt_aggregation <- dt_aggregation %>% 
        dplyr::group_by(Date, Measure) %>% 
        dplyr::summarise(
          value = mean(value, na.rm=T)
          ) %>% 
        dplyr::mutate(Country = 'Average')
      
      } else { dt_aggregation }
      
  })
  
  dt_plot_wide <- reactive({
    
    dt.wide <- dt_plot() %>% 
      tidyr::pivot_wider(names_from = Measure, values_from = value, id_cols = -starts_with('s_'))
    
    print(colnames(dt.wide))
    
    return(dt.wide)
  })
  
  output$plot <- renderPlotly(
    
    
    # TIMESERIES
    
    ggplotly(
      
      # LINE CHART OVER DATES
      if (input$in_type == 'Time') {
        ggplot(dt_plot() %>% dplyr::filter(Measure == input$in_plot_y)) + geom_line(aes(x = Date, y = value, col = Country, group = Country))
          
      } else {
        ggplot(dt_plot_wide()) + geom_point(aes(x = !!sym(input$in_plot_x), y = !!sym(input$in_plot_y), col = Country, group = Country, alpha = as.numeric(Date)))
      }
      

    )
    
  )
  
}


