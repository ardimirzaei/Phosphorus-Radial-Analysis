

phosp_grouping = read.table( text = "drug,drug_grouping
Phosphonite,3
Phosphinite,3
Phosphine,3
Phosphonamidite,3
Phosphonodiamidite,3
Phosphinamidite,3
Phosphonate,5
Phosphinate,5
Phosphineoxide,5
Phosphonamidate,5
Phosphondiamidate,5
Phosphinamidate,5
Phosphite,3
Phosphoamidite,3
Phosphorodiamidite,3
Phosphorotriamidite,3
phosphate,5
phosphoroamidate,5
Phosphorodiamidate,5
Phosphorotriamidate,5
",
sep = ",", header = TRUE, stringsAsFactors = FALSE)

phosp_grouping$drug <- tolower(phosp_grouping$drug)
  
hit_analysis <- df %>%
  mutate(nl =   apply(df[c("n.1.", "n.2.", "n.3.", "n.4.")], 1, paste,collapse="")) %>%
  filter(ATOM == 'P') %>%
  left_join(phosp_grouping, by = 'drug') %>%
  # filter(is.na(drug_grouping))
  group_by(drug, compound, alphavalue) %>%
  arrange(RMSD_MAP) %>%
  slice(1:15) %>%
  mutate(Nl_Ranking = row_number()) %>%
  # mutate(drug_grouping = str_sub(drug,-3,-1)) %>%
  # mutate(drug_grouping = replace(drug_grouping, drug_grouping=='ide','ate')) %>%
  # mutate(drug_grouping = replace(drug_grouping, drug_grouping=='ine','ite')) %>%
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
  mutate(drug_grouping = gsub("3","III",drug_grouping), 
         drug_grouping = gsub("5","V",drug_grouping)) %>%
  ggplot(aes(x = nl, y = Nl_Ranking, fill = as.factor(drug_grouping), alpha = n)) + 
    geom_tile() + 
    xlab(TeX("$n_{(l)}$")) + 
    ylab('Ranking') + 
    theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90, size = 10, hjust = -1 , face="bold")) + 
    # facet_wrap(~drug_grouping) + 
  scale_fill_manual(values = c('blue', 'red')) + 
  guides(fill=guide_legend("Factor Grouping"),
         alpha=guide_legend("n")) -> g
  # scale_fill_viridis_d()  


ggsave(paste0("Hit_Analysis_",format(Sys.time(), '%Y%m%d'),".pdf"), 
       path = "./Analysis",
       plot = g, 
       width=12, height=8)



hit_analysis %>%
  ungroup() %>%
  mutate(nl = factor(hit_analysis$nl, levels = sort(unique(hit_analysis$nl)))) %>%
  # pivot_wider(names_from = nl, values_from = n) %>%
  filter(drug_grouping == 3 ) %>%
  mutate(drug_grouping = gsub("3","III",drug_grouping), 
         drug_grouping = gsub("5","V",drug_grouping)) %>%
  ggplot(aes(x = nl, y = Nl_Ranking, fill = as.factor(drug_grouping), alpha = n)) + 
  geom_tile() + 
  xlab(TeX("$n_{(l)}$")) + 
  ylab('Ranking') + 
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90, size = 10, hjust = -1 , face="bold")) + 
  facet_wrap(~drug_grouping) +
  scale_fill_manual(values = c('blue')) + 
  guides(fill=guide_legend("Factor Grouping"),
         alpha=guide_legend("n")) -> g
# scale_fill_viridis_d()  


ggsave(paste0("Hit_Analysis_Seperate_3s_",format(Sys.time(), '%Y%m%d'),".pdf"), 
       path = "./Analysis",
       plot = g, 
       width=12, height=8)



hit_analysis %>%
  ungroup() %>%
  mutate(nl = factor(hit_analysis$nl, levels = sort(unique(hit_analysis$nl)))) %>%
  # pivot_wider(names_from = nl, values_from = n) %>%
  filter(drug_grouping == 5 ) %>%
  mutate(drug_grouping = gsub("3","III",drug_grouping), 
         drug_grouping = gsub("5","V",drug_grouping)) %>%
  ggplot(aes(x = nl, y = Nl_Ranking, fill = as.factor(drug_grouping), alpha = n)) + 
  geom_tile() + 
  xlab(TeX("$n_{(l)}$")) + 
  ylab('Ranking') + 
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90, size = 10, hjust = -1 , face="bold")) + 
  facet_wrap(~drug_grouping) +
  scale_fill_manual(values = c('red')) + 
  guides(fill=guide_legend("Factor Grouping", position = "none"),
         alpha=guide_legend("n")) -> g
# scale_fill_viridis_d()  


ggsave(paste0("Hit_Analysis_Seperate_5s_",format(Sys.time(), '%Y%m%d'),".pdf"), 
       path = "./Analysis",
       plot = g, 
       width=12, height=8)