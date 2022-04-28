# Main Script for Analysis of the Output File

library(corrplot)
library(ggplot2)
library(dplyr)
library(psych) # for describeby
library(car) #for leven's test
library(flextable)
# devtools::install_github("davidgohel/officedown")
library(officedown)

Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/quarto/bin") # Do this in order to find the pandoc and run

# Filtering for P atom from here. 
source('Scripts/Phos_Load_and_Preprocess.R')

source('Scripts/Phos_Alpha_vs_RMSD.R')

# Top and bottom 5

rmarkdown::render(input = 'Scripts/Phos_Top5Bottom5_Tables.rmd',
                  output_file = paste0('TopAndBottom_Tables_',format(Sys.time(), '%Y%m%d'),'.docx'),
                  output_dir = 'Analysis/')

# Ranking of nl = 6666 and 6677
rmarkdown::render(input = 'Scripts/Phos_Rankings_6666_6677.rmd',
                  output_file = paste0('Rankings_6666_6677_',format(Sys.time(), '%Y%m%d'),'.docx'),
                  output_dir = 'Analysis/')


# source('Scripts/Gather_and_zip_files.R')
list.files(pattern = "*bestnl.csv", recursive = TRUE)
