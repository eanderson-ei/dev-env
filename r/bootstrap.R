#Create a bootstrap
boot1 <- rep(NA, 1000)
for (i in 1:length(boot1)) boot1[i] <- sd(sample(csm_pilot_data$SAGECC, length(csm_pilot_data$SAGECC), replace = TRUE))
quantile(boot1, probs = c(.95, .05))
mean(boot1)
