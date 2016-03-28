sysinfo = Sys.info()
library(readr)
library(dplyr)
library(lubridate)
library(reshape2)
library(googleVis)
library(ggplot2)
library(scales)
library(stringr)
library(zoo)
library(shiny)
library(DT)
library(shinydashboard)
library(jsonlite)
library(kimisc)
options(stringsAsFactors = F)

readtable = function(x, ...){
  read.table(x, sep=",",header=TRUE,stringsAsFactors=FALSE,quote="\"", ...)
}

countries = readtable("countries.csv")