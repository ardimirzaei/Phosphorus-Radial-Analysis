df = read.csv('File_Outputs/Full_DataFrame_nl_Atoms.csv')

df <- df %>%
  rename(Rf.map = `Rf.map...`) %>%
  rename(Rf.LSQ = `Rf.LSQ...`) %>%
  mutate(nl = apply(df[c("n.1.", "n.2.", "n.3.", "n.4.")], 1, paste,collapse="")) %>%
  select(-`Unnamed..10`)

# df <- df %>%
#   mutate(nl = apply(df[c("n.1.", "n.2.", "n.3.", "n.4.")], 1, paste,collapse="")) %>%
#   select(N, Rf.map, alphavalue, ATOM, KAPPA, KAPPA_HAT, RMSD_MAP, nl)

cat(paste0("File has ",dim(df)[2]," columns\nFile has ",dim(df)[1], " rows\n\n" ))
cat("These are the following drugs in this data file:\n")
cat(paste(unique(df$drug), collapse = "\n"))