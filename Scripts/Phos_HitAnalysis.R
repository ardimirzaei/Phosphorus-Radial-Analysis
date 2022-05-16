
  
hit_analysis <- df %>%
  mutate(nl =   apply(df[c("n.1.", "n.2.", "n.3.", "n.4.")], 1, paste,collapse="")) %>%
  filter(ATOM == 'P') %>%
  group_by(drug, compound, alphavalue) %>%
  arrange(RMSD_MAP) %>%
  slice(1:20) %>%
  mutate(Nl_Ranking = row_number()) %>%
  mutate(drug_grouping = str_sub(drug,-3,-1)) %>%
  mutate(drug_grouping = replace(drug_grouping, drug_grouping=='ide','ate')) %>%
  mutate(drug_grouping = replace(drug_grouping, drug_grouping=='ine','ite')) %>%
  filter(alphavalue < 3.6) %>% 
  ungroup() %>%
  select(nl, Nl_Ranking, drug_grouping) %>%
  group_by(nl, Nl_Ranking, drug_grouping) %>%
  summarise(n = n()) %>%
  arrange(Nl_Ranking, desc(n)) 

hit_analysis %>%
  ungroup() %>%
  mutate(nl = factor(hit_analysis$nl, levels = sort(unique(hit_analysis$nl)))) %>%
  # pivot_wider(names_from = nl, values_from = n) %>%
  ggplot(aes(x = nl, y = Nl_Ranking, fill = n)) + 
    geom_tile() + 
    
    theme_bw() + 
  theme(axis.text.x = element_text(angle = 90, size = 6.5, hjust = -1 )) + 
    facet_wrap(~drug_grouping) + 
  scale_fill_viridis_c()  


