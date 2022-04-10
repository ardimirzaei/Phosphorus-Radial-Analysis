# Does the Alpha value matter?

cat("Does the Alpha Value Matter?\n\n")

# Check some correlations
m <- df[c("Rf.map", 'RMSD_MAP', "alphavalue", "KAPPA", "KAPPA_HAT")] 
# %>%
#   rename(c(
#     "Rf map" = Rf.map,
#     "alpha value" = alphavalue
#     )) %>%
#   rename("RMSD Map" = RMSD_MAP) %>%
#   rename("Kappa" = KAPPA) %>%
#   rename("Kappa'" = KAPPA_HAT) 

# Confidence Level 0.95%
testRes = cor.mtest(m, conf.level = 0.95)
# corrplot(cor(m), p.mat = testRes$p, sig.level = 0.05, order = 'hclust', addrect = 2)

M <- as.data.frame(cor(m)[c(1:2,4:5),3, drop=FALSE])
testP <- as.data.frame(testRes$p[c(1:2,4:5),3, drop=FALSE])
testP['Lower'] <- testRes$p[c(1:2,4:5),3, drop=TRUE]
testP['Upper'] <- testRes$p[c(1:2,4:5),3, drop=TRUE]

M['Lower'] <-as.numeric(testRes$lowCI[c(1:2,4:5),3, drop=TRUE])
M['Upper'] <- as.numeric(testRes$uppCI[c(1:2,4:5),3, drop=TRUE])

colnames(M) <- c("$alpha-value", "Lower Confidence", "Upper Confidence")
rownames(M) <- c("Rf map", "RMSD Map", "Kappa", "Kappa'")
colnames(testP) <- colnames(M)
rownames(testP) <- rownames(M)
  
  
corrplot(as.matrix(M),
         p.mat = as.matrix(testP),
         number.digits = 3,
         sig.level = 0.05,
         method = 'circle',
         insig='blank',
         addCoef.col ='black',
         tl.col = "black",
         number.cex = 1.8, 
         cl.pos = 'n', 
         tl.srt = 25, 
         tl.cex = 1.2, 
         tl.offset = 1,
         mar=c(0,0,4,0))

mtext("Correlation of alpha value", at=2.5, line=0.2, cex=2)


cat("Correlation Analysis tells us not really, but slightly\n\n")

cat("ANOVA Results\n")

#https://towardsdatascience.com/doing-and-reporting-your-first-anova-and-ancova-in-r-1d820940f2ef

cat("Levene's Test:\n")
leveneTest(RMSD_MAP~as.factor(alphavalue),df)

fit = aov(RMSD_MAP ~ as.factor(alphavalue), df)
summary(fit)

describeBy(df$RMSD_MAP, df$alphavalue)

# Control for n value
fit2 = aov(RMSD_MAP ~ as.factor(alphavalue) + n.1. + n.2. + n.3. + n.4., df)
Anova(fit2, type="III")
summary(fit2)

ggplot(df,aes(y=RMSD_MAP, x=as.factor(alphavalue), fill=as.factor(alphavalue)))+
  stat_summary(fun="mean", geom="bar",position="dodge")+
  stat_summary(fun.data = mean_se, geom = "errorbar", position="dodge",width=.8) + 
  coord_cartesian(ylim = c(0.0382,0.0384)) + 
  xlab("Alpha Value") + 
  theme_minimal() + 
  theme(legend.position = "none")



ggplot(df,aes(y=KAPPA_HAT, x=as.factor(alphavalue), fill=as.factor(alphavalue)))+
  stat_summary(fun="mean", geom="bar",position="dodge")+
  stat_summary(fun.data = mean_se, geom = "errorbar", position="dodge",width=.8) + 
  coord_cartesian(ylim = c(1.06,1.09)) + 
  xlab("Alpha Value") + 
  theme_minimal() + 
  theme(legend.position = "none")

