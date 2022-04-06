library(corrplot)
library(ggplot2)
library(dplyr)
library(caret)
library(fastDummies)
library(DiagrammeR)
library(xgboost)
library(forcats)
df = read.csv('Full_DataFrame_nl_Atoms.csv')

# Check some correlations
m <- df[c("Rf.map...", "alphavalue", "KAPPA", "KAPPA_HAT")]

testRes = cor.mtest(m, conf.level = 0.95)
corrplot(cor(m), p.mat = testRes$p, sig.level = 0.10, order = 'hclust', addrect = 2)

corrplot(cor(m),p.mat = testRes$p, method = 'circle', type = 'lower', insig='blank', addCoef.col ='black', number.cex = 0.8, order = 'AOE', diag=FALSE)

cor.mtest(df[c("n.0.", "n.1.", "n.2.", "n.3.", "n.4.", "alphavalue")], conf.level = 0.95)

cor.mtest(df[c("n.1.", "n.2.", "n.3.", "n.4.", "RMSD_MAP")], conf.level = 0.95)
corrplot(cor(df[c("n.1.", "n.2.", "n.3.", "n.4.", "RMSD_MAP")],), addrect = 2, insig='blank', addCoef.col ='black', number.cex = 0.8, order = 'hclust', diag=FALSE)

# Model best numbers

df_cut <- df[c("N", "Rf.map...", "alphavalue", "ATOM","KAPPA", "KAPPA_HAT","RMSD_MAP")]
df_cut$nl <- 
  apply(df[c("n.1.", "n.2.", "n.3.", "n.4.")], 1, paste,collapse="")

head(df_cut)

# 
g <- df_cut %>% 
  mutate(n1 = df$n.1.) %>%
  mutate(n2 = df$n.2.) %>%
  mutate(n3 = df$n.3.) %>%
  mutate(n4 = df$n.4.) %>%
  arrange(n3, RMSD_MAP) %>%
  distinct(N, RMSD_MAP, nl, n1, n2, n3, n4) %>%
  ggplot(aes(x = N, y = RMSD_MAP)) + 
    geom_point(aes(color = n1), alpha = 0.2) + 
    theme_classic() + 
    facet_grid(n2+n3 ~ n4)
  
ggsave(
  'plotting_n_vs_rsmd.pdf',
  plot = g, 
  width = 15,
  height = 15,
  units = 'in',
  dpi = 300,
)

df_cut %>% 
  mutate(n1 = df$n.1.) %>%
  mutate(n2 = df$n.2.) %>%
  mutate(n3 = df$n.3.) %>%
  mutate(n4 = df$n.4.) %>%
  group_by(nl) %>%
  summarise(count = n(), mean = mean(RMSD_MAP), min = min(RMSD_MAP), max = max(RMSD_MAP)) %>%
  arrange(mean)


# Visualising top 100 numbers by mean

chr_loc = 3
g <- df_cut %>% 
  group_by(nl) %>%
  summarise(count = n(), mean = mean(RMSD_MAP), min = min(RMSD_MAP), max = max(RMSD_MAP)) %>%
  arrange(mean) %>%
  mutate(nl = fct_relevel(as.factor(.$nl), .$nl)) %>%
  mutate(n_n = as.integer(substr(as.character(nl),chr_loc,chr_loc))) %>%
  mutate(n1 = as.integer(substr(as.character(nl),1,1))) %>%
  mutate(n2 = as.integer(substr(as.character(nl),2,2))) %>%
  mutate(n3 = as.integer(substr(as.character(nl),3,3))) %>%
  mutate(n4 = as.integer(substr(as.character(nl),4,4))) %>%
  dplyr::slice(1:100) %>%
  ggplot(aes(x=nl)) + 
    geom_point(aes(y = mean*1.01, color = as.factor(n1))) + 
    geom_point(aes(y = mean*1.02, color = as.factor(n2))) + 
    geom_point(aes(y = mean*1.03, color = as.factor(n3))) + 
    geom_point(aes(y = mean*1.04, color = as.factor(n4))) + 
    # stat_smooth(aes(x = 1:300,y = min), size=1.5, method = "loess", level = 0.95, fullrange = TRUE, se = FALSE,  color = 'royalblue', alpha = 0.2)+
    # stat_smooth(aes(x = 1:300,y = max), size=1.5, method = "loess", level = 0.95, fullrange = TRUE, se = FALSE,  color = 'royalblue', alpha = 0.2)+
    theme_classic() + 
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  
ggsave(
  'colored_n_vs_rsmd_mean.pdf',
  plot = g, 
  width = 25,
  height = 15,
  units = 'in',
  dpi = 300,
)



# VIOLIN PLOT
top_50 <- df_cut %>% 
  arrange(RMSD_MAP) %>%
  distinct(nl) %>%
  dplyr::slice(1:50)


g <- df_cut %>%
  filter(df_cut$nl %in% top_50$nl) %>%
  mutate(nl = fct_relevel(as.factor(.$nl), top_50$nl)) %>%
  ggplot(aes(x=nl, y=RMSD_MAP)) + 
    geom_violin() + 
    theme_classic()

g <- g + stat_summary(fun.data='mean_sdl', mult=1, geom="pointrange", color="red")

ggsave(
  'violin_plot_n_vs_rsmd.pdf',
  plot = g, 
  width = 45,
  height = 15,
  units = 'in',
  dpi = 300,
)


# OTHER PLOTS
df %>%
  ggplot(aes(x = as.factor(n.1.), y = RMSD_MAP)) + 
    geom_point() 

df %>%
  group_by(RMSD_MAP) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = as.factor(RMSD_MAP), y = count)) + 
    geom_histogram()


df %>%
  group_by(RMSD_MAP) %>%
  ggplot(aes(x = RMSD_MAP)) +
    geom_histogram(alpha = 0.3) + 
    facet_grid(rows = vars(n.1.), cols = vars(n.4.))

#

dat <- df[c("n.1.", "n.2.", "n.3.", "n.4.", "RMSD_MAP")]

dat <- dummy_cols(dat, select_columns = c("n.1.", "n.2.", "n.3.", "n.4."), remove_first_dummy = FALSE) %>%
  select(-c("n.1.", "n.2.", "n.3.", "n.4."))

dat$RMSD_MAP <- 1 - dat$RMSD_MAP

#dummyVars(~ n.1. + n.2. + n.3. + n.4., data = dat)


# split into training and testing
set.seed(2202)
train_index <- createDataPartition(
  y = dat$RMSD_MAP,
  p = .75,
  list = FALSE
)
training <- dat[ train_index,]
testing  <- dat[-train_index,]

nrow(training)
nrow(testing)

# 
# adaFit <- train(
#   RMSD_MAP ~ .,
#   data = training,
#   method = "xgbTree"#,
#   ## Center and scale the predictors for the training
#   ## set and all future samples.
#   # preProc = c("center", "scale")
# )

xgbGrid <- expand.grid(nrounds = c(1, 10),
                       max_depth = c(1, 4),
                       eta = c(.1, .4),
                       gamma = 0,
                       colsample_bytree = .7,
                       min_child_weight = 1,
                       subsample = c(.8, 1))

rctrl1 <- trainControl(method = "cv", number = 3, returnResamp = "all")


test_reg_cv_model <- train(  RMSD_MAP ~ .,
                             data = training,
                           method = "xgbTree", 
                           trControl = rctrl1
                           #,
                           #tuneGrid = xgbGrid
                           )

# Save to File
saveRDS(test_reg_cv_model, "./xgb_cv_reg_model.rds")
test_reg_cv_model <- readRDS("./xgb_cv_reg_model.rds")


varImp(test_reg_cv_model,scale=FALSE)

# Metrics
test_reg_pred <- predict(test_reg_cv_model, testing[-1])
postResample(pred = test_reg_pred, obs = testing[,1])

gr <- xgboost::xgb.plot.tree(model = test_reg_cv_model$finalModel, trees = NULL, show_node_id = TRUE)
export_graph(gr, 'tree.png', width=1500, height=1900)

xgboost::xgb.plot.importance(model = test_reg_cv_model$finalModel)
xgboost::xgb.plot.importance(as.table(varImp(test_reg_cv_model)))


importance_matrix <- xgb.importance(test_reg_cv_model$finalModel$xNames, model = test_reg_cv_model$finalModel)

xgb.plot.importance(importance_matrix, rel_to_first = TRUE, xlab = "Relative importance")


############ LINEAR REGRESSOIn

test_reg_lm_model <- train(  RMSD_MAP ~ .,
                             data = training,
                             method = "lm"
                             #, 
                             #trControl = rctrl1
                             #,
                             #tuneGrid = xgbGrid
)


saveRDS(test_reg_lm_model, "./lm_reg_model.rds")
test_reg_lm_model <- readRDS("./lm_reg_model.rds")
varImp(test_reg_lm_model,scale=FALSE)

# Metrics

test_reg_pred_LM <- predict(test_reg_lm_model, testing[-1])
postResample(pred = test_reg_pred_LM, obs = testing[,1])



#### ANOVA

res.aov <- df_cut %>%
  mutate(nl = as.factor(nl)) %>%
  # Compute the analysis of variance
  aov(RMSD_MAP ~ nl, data = .)

# Summary of the analysis
summary(res.aov)
