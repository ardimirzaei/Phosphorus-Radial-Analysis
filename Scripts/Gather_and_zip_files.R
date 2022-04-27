
DATE <- format(Sys.time(), '%Y%m%d')
zip_file_list <- list.files(pattern = paste0('FileMergeOutput/'),recursive = TRUE)

zip(zipfile = paste0('_Archive/File_Outputs_',format(Sys.time(), '%Y%m%d'),'.zip'),, files = zip_file_list)


zip_file_list <- list.files(pattern = paste0('Analysis/'),recursive = TRUE)
zip(zipfile = paste0('_Archive/Analysis_',format(Sys.time(), '%Y%m%d'),'.zip'),, files = zip_file_list)


