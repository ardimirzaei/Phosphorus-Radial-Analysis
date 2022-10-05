df = read.csv('FileMergeOutput/Full_DataFrame_nl_Atoms.csv')

df <- df %>%
  rename(Rf.map = `Rf.map...`) %>%
  rename(Rf.LSQ = `Rf.LSQ...`) %>%
  mutate(nl = apply(df[c("n.1.", "n.2.", "n.3.", "n.4.")], 1, paste,collapse="")) %>%
  select(-`Unnamed..10`) %>%
  filter(ATOM == "P") # REMOVE THIS IF DOING ANALYSIS ON MORE

cat(paste0("File has ",dim(df)[2]," columns\nFile has ",dim(df)[1], " rows\n\n" ))
cat("These are the following drugs in this data file:\n")
cat(paste(unique(df$drug), collapse = "\n"))

cat("\n\nCleaning Prefix File Names\n")
df$drug <- gsub("DataFiles\\/","",df$drug)
df$drug <- gsub("DataFiles\\\\","",df$drug)
df$drug <- gsub("MOSS\\\\","",df$drug)
df$drug <- tolower(df$drug)
