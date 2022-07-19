


# DIRECTORY
setwd('D:/Projects/0001_World_Bank')

# LIBRARIES
library(tidyverse)
library(plotly)

# LOAD
d_files_csv <- list.files('01_data/', pattern = '.csv')
list2env(
  lapply(setNames(paste0('01_data/', d_files_csv), make.names(gsub("*.csv$", "", d_files_csv))), 
         read.csv), envir = .GlobalEnv)

unique(WDIData$Indicator.Name)

# CLEAN
d_WDI <- WDIData %>% 
  tidyr::pivot_longer(starts_with('X'), names_to = 'Date') %>% 
  dplyr::filter(!is.na(value)) %>% 
  dplyr::mutate(Date = as.Date(paste0(substr(Date, 2, 5), '-01-01'), format = '%Y-%m-%d')) %>% 
  dplyr::left_join(
    WDICountry %>% dplyr::select(Country.Code, Currency.Unit, Region, Income.Group, Lending.category, Other.groups), by = c('Country.Code') # MISSING PRE-AGGREGATED REGIONS
    
  ) %>% 
  
  # ADD GROWTH RATES
  dplyr::group_by(Country.Name, Country.Code, Indicator.Name) %>% 
  dplyr::mutate(
    s_growth_1y = (value / lag(value, 1, order_by = Date)) - 1,
    s_growth_5y = (value / lag(value, 5, order_by = Date)) - 1,
    s_growth_10y = (value / lag(value, 10, order_by = Date)) - 1,
    x_newest = case_when(Date == max(Date, na.rm=T) ~ 1, TRUE ~ 0)
  ) %>% 
  dplyr::ungroup() %>% 
  dplyr::select(
    Country = Country.Name, Region, Income.Group, Date, Measure = Indicator.Name, value, s_growth_1y, s_growth_5y, s_growth_10y
  )

# RESTRICT DATASET
d_WDI_2 <- d_WDI %>% 
  dplyr::filter(grepl('emissions', Measure)  | Measure == '	GDP (current US$)') 


save(d_WDI, file = '01_data/WDI.RData')
save(d_WDI_2, file = '01_data/WDI_emissions.RData')



# EARLY PLOT
d_plot <- d_WDI %>% 
  filter(Date == '2015' & Region != '' & Indicator.Name == 'Population, total') # grepl('population', tolower(Indicator.Name))) # x_newest == 1 # -> UNCLEAN COMPARISON


ggplotly(
  
  ggplot2::ggplot(d_plot, aes(
      x=reorder(Country.Name, -s_growth_1y), 
      y=s_growth_1y, 
      fill = Income.Group,
      text = paste(
        'Country:', Country.Name,
        '\nGrowth Rate:', round(100*s_growth_1y, 1), '%',
        '\nIncome Group:', Income.Group
      )
      
      )) +
    geom_bar(stat='identity') +
    facet_grid(Region~., scales = 'free_y') +
    scale_fill_brewer(type = 'd') + 
    coord_flip() + 
    theme_minimal() +
    labs(
      title = '1-Year Poplation Growth Rates 2015'
    ) +
    ylab('Growth Rate') +
    xlab('Country') +
    theme(
      
      axis.text.y = element_text(size=4),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_blank(),
      axis.line = element_line(color='black'),
      axis.line.x = element_line(color='black')
      )
 , tooltip = 'text'
)



