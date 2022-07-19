


library(shiny)
library(DT)
library(plotly)
library(ggplot2)
library(dplyr)
library(lubridate)

setwd('D:/Projects/0001_World_Bank')

# LOAD DATA
load('01_data/WDI_emissions.RData')

# LOAD MODULES
source('03_shiny/001_modules_filtering.R')
source('03_shiny/002_ui.R')
source('03_shiny/003_server.R')


shinyApp(ui, server)
