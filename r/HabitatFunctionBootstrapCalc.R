# Define the Assessment Area (use AA.names if unsure).
#Select the Assessment Area and confidence interval
AA <- "Fall Burn"
sample.plots <- 395
actual_habitat_function <- .63
mw.sp.rich.actual.score <- .63
conserve_priority <- 1
threats <- 1

Conf.int <- .9
reps <- 1000


max.np.richness <- 10
weight.mw.dense <- .8 
weight.mw.rich <- .2
weight.np.freq <- .6
weight.np.rich <- .4
weight.mw <- .5
weight.np <- .5

##MW
mw.plot.data <- df.mw[AA,]

# Define milkweed scoring function
mw.score <- function(mw){
  if(is.na(mw)){
    x <- 0
  } else if (mw > 2000){
    x <- 1
  } else {
    x <-  1-(2/(1+exp(6*(mw/2000))))
  }
  return (x)
}

# Calculate mean (in plants/acre) and convert to a score, print to console
xbar <- sum(mw.plot.data)/sample.plots*4046.86
xscore <- mw.score(xbar)*100
print(cat('Assessment Area', AA, 'Milkweed Density Sample mean: ', xbar, '(', xscore, '% )', "\n"), sep = "")

# Set up a dataframe for storing samples, one column per plot (100) 
if (is.na(xbar)){
  mw.dense <- rep(0, sample.plots)
  mw.dense.score <- rep(0 , sample.plots)
} else {
  m <- matrix(data = NA, nrow = 0, ncol = sample.plots)
  mw.temp <- as.data.frame(m)
  colnames(mw.temp) <- colnames(df.mw[1:sample.plots])
  
  # Sample the plot data 100 times and add each sample as a new row in the created dataframe
  for (i in 1:reps){
    F.star <- sample(mw.plot.data[1:sample.plots], sample.plots, replace = TRUE)
    colnames(F.star) <- colnames(mw.temp)
    mw.temp <- rbind(mw.temp, F.star)
  }
  mw.dense <- rowSums(mw.temp)/sample.plots*4046.86
  plot(mw.dense)
  
  # Score each bootstrap rep
  mw.dense.score <- sapply(mw.dense, mw.score)
  plot(x = mw.dense.score)
  
  ### Use below if only interested in milkweed uncertainty
  # Sum across each row (sample) and subtract from the actual mean to get the difference between the bootstrap sample
  # and the actual mean
  mw.delta.star <- mw.dense - xbar
  plot(mw.delta.star)
  
  # Identify the 10% and 90% quantile values of the delta
  mw.d <- quantile(mw.delta.star, c(1-Conf.int, Conf.int))
  # Subtract the 10% and 90% quantile values from the actual mean to get the high and low confidence interval bounds
  mw.ci <- xbar + c(mw.d[1],mw.d[2])
  # Score each confidence bound and print to console
  mw.ci.score.low <- round(mw.score(mw.ci[1])*100)
  mw.ci.score.high <- round(mw.score(mw.ci[2])*100)
  
  print(cat('Assessment Area', AA, '- Milkweed Density Confidence interval:', mw.ci, 
            '(', mw.ci.score.low, "-", mw.ci.score.high, "% )\n"))
  
  # Plot the results
  plot(mw.dense)
  abline (h = mw.ci[2])
  abline (h = mw.ci[1])
}

# Bootstrap for milkweed richness
unique.species = unique(mw.data$GENSPE[which(mw.data$AA==AA)])
unique.species
num.mw <- length(mw.data$GENSPE[which(mw.data$AA==AA)])
num.mw
if(num.mw == 0){
  mw.eff.sp <- rep(0, reps)
  mw.sp.rich.score <- rep (0, reps)
} else {
  m <- matrix(data = NA, nrow = 0, ncol = num.mw)
  mw.sp.temp <- as.data.frame(m)
  colnames (mw.sp.temp) <- paste("SP", c(1:num.mw), sep = "")
  
  for (i in 1:reps){
    sp.sample <- sample(mw.data$GENSPE[which(mw.data$AA==AA)], num.mw, replace = TRUE)
    sp.sample <- as.data.frame(t(sp.sample))
    colnames(sp.sample) <- colnames(mw.sp.temp)
    sp.sample
    mw.sp.temp <- rbind(mw.sp.temp, sp.sample)
  }
  head(mw.sp.temp)
  tail(mw.sp.temp)
  
  m <- matrix(data = NA, nrow = reps, ncol = 0)
  mw.sp.temp.agg <- as.data.frame(m)
  
  for (sp in unique.species){
    sp.count <- apply(mw.sp.temp, 1, function (mw.sp.temp){length(which(mw.sp.temp==sp))})
    sp.count
    length(sp.count)
    mw.sp.temp.agg <- cbind(mw.sp.temp.agg, sp.count)
    head(mw.sp.temp.agg)
    colnames(mw.sp.temp.agg)[names(mw.sp.temp.agg)=="sp.count"] <- sp
  }
  head(mw.sp.temp.agg)
  
  mw.sp.temp.prop2 <- (mw.sp.temp.agg/num.mw)^2
  mw.eff.sp <- 1/rowSums(mw.sp.temp.prop2)
  mw.eff.sp
  mw.sp.rich.score <- 1.2 - (1.4/(1 + exp(mw.eff.sp - 1)))
  mw.sp.rich.score
  
  plot(mw.sp.rich.score)
  
  # Calculate confidence intervals from the difference in average score (bootstrap minus actual)
  mw.sp.delta.star <- mw.sp.rich.score -  mw.sp.rich.actual.score
  mw.sp.d <- quantile(mw.sp.delta.star, c(1-Conf.int, Conf.int))
  
  # Subtract the 10% and 90% quantile values from the actual score to get the high and low 
  # confidence interval bounds
  mw.sp.ci <- mw.sp.rich.actual.score + c(mw.sp.d[1],mw.sp.d[2])
  # Score each confidence bound and print to console
  mw.sp.ci.score.low <- round(mw.sp.ci[1]*100)
  mw.sp.ci.score.high <- round(mw.sp.ci[2]*100)
  
  print(cat('Assessment Area', AA, '- Milkweed Richness Confidence interval:', '(', mw.sp.ci.score.low, "-", 
            mw.sp.ci.score.high, "% score)\n"))
}

# Combine the data into an output table
mw.out <- cbind(mw.dense, mw.dense.score, mw.eff.sp, mw.sp.rich.score)
colnames(mw.out) <- c("MWDense", "MWDense.Score", "MWRich", "MWRich.Score")
head(mw.out)

###NP
np.plot.data <- df.np[AA,]
head(np.plot.data)

# Define scoring function for nectar plant frequency
n.score <- function(freq, area = .25) {
  if (freq >= 1){
    x <- 1
  } else {
    raw.score <- .155*-log(1-freq)/area
    if (raw.score >= 1) {
      x <- 1
    } else {
      x <- raw.score
    }
  }
  return (x)
}

# Define scoring function for nectar plant richness
ns.score <- function(rich, max){
  if (rich >= max){
    x <- 1
  } else {
    x <- 1 - (2/(1+exp(6*rich/max)))
  }
  return (x)
}

# Calculate the sampled mean and score
np.act.freq.ones <- length(which(np.plot.data==1))/sample.plots
np.act.freq.twos <- length(which(np.plot.data==2))/sample.plots + np.act.freq.ones
np.act.freq.threes <- length(which(np.plot.data==3))/sample.plots + np.act.freq.twos
np.act.freq.ones.score <- n.score(np.act.freq.ones, area = .25)
np.act.freq.twos.score <- n.score(np.act.freq.twos, area = .5)
np.act.freq.threes.score <- n.score(np.act.freq.threes, area = 1)
np.act.freq.score <- mean(c(np.act.freq.ones.score, np.act.freq.twos.score, np.act.freq.threes.score))
print(cat("Nectar Plant Frequency Score: ", round(np.act.freq.score*100), "%\n"))

# Set up a dataframe for storing samples, one column per plot (100) 
m <- matrix(data = NA, nrow = 0, ncol = sample.plots)
np.temp <- as.data.frame(m)
colnames(np.temp) <- colnames(df.np[1:sample.plots])

# Sample the plot data 100 times and add each sample as a new row in the created dataframe
for (i in 1:reps){
  F.star <- sample(np.plot.data, length(np.plot.data), replace = TRUE)
  colnames(F.star) <- colnames(np.temp)
  np.temp <- rbind(np.temp, F.star)
}
head(np.temp)

# Count the frequency of plots for each subplot size and combine into a single table, rows are bootsrap reps
np.freq.ones <- apply(np.temp, 1, function (np.temp){length(which(np.temp==1))/sample.plots})
np.freq.twos <- apply(np.temp, 1, function (np.temp){length(which(np.temp==2))/sample.plots}) + np.freq.ones
np.freq.threes <- apply(np.temp, 1, function (np.temp){length(which(np.temp==3))/sample.plots}) + np.freq.twos

np.freq <- cbind(np.freq.ones, np.freq.twos, np.freq.threes)
colnames(np.freq) <- c("Subplot1.Freq", "Subplot2.Freq", "Subplot3.Freq") 
head(np.freq)

# Score the frequency data and combine intoa single table, rows are bootstrap reps
np.freq.ones.scores <- sapply(np.freq.ones, n.score, area = .25)
np.freq.twos.scores <- sapply(np.freq.twos, n.score, area = .5)
np.freq.threes.scores <- sapply(np.freq.threes, n.score, area = 1)
np.freq.scores <- cbind(np.freq.ones.scores, np.freq.twos.scores, np.freq.threes.scores)
np.freq.scores.mean <- apply(np.freq.scores, 1, mean)
np.freq.scores <- cbind(np.freq.scores, np.freq.scores.mean)
colnames(np.freq.scores) <- c("Subplot1.Score", "Subplot2.Score", "Subplot3.Score", "NP.Freq.Score")
head(np.freq.scores)

#Combine observations and scores into a single table
np.freq.out <- cbind(np.freq, np.freq.scores)
head(np.freq.out)

# Calculate confidence intervals from the difference in average score (bootstrap minus actual)
np.delta.star <- np.freq.scores.mean -  np.act.freq.score
np.d <- quantile(np.delta.star, c(1-Conf.int, Conf.int))

# Subtract the 10% and 90% quantile values from the actual score to get the high and low 
# confidence interval bounds
np.ci <- np.act.freq.score + c(np.d[1],np.d[2])
# Score each confidence bound and print to console
np.ci.score.low <- round(np.ci[1]*100)
np.ci.score.high <- round(np.ci[2]*100)

print(cat('Assessment Area', AA, '- Nectar Plant Frequency Confidence interval:', '(', np.ci.score.low, "-", 
          np.ci.score.high, "% score)\n"))

# Plot the results
plot(np.freq.scores.mean)
abline (h = np.ci[2])
abline (h = np.ci[1])

# Sample species richness
ns.richness.act <- length(which(df.ns$AA==AA))
print(cat("Nectar Plant Richness: ", ns.richness.act, " species (", ns.score(ns.richness.act, max = max.np.richness)*100, "%)\n"))
ns.richness <- round(rnorm(reps, mean = ns.richness.act, sd = ns.richness.act*.25))
ns.richness.score <- sapply(ns.richness, ns.score, max = max.np.richness)

#Combine observations and scores into a single table
ns.rich.out <- cbind(ns.richness, ns.richness.score)
colnames(ns.rich.out) <- c("NPRich", "NPRich.score")
head(ns.rich.out)

# Combine all nectar plant outputs to a single table
np.out <- cbind(np.freq.out, ns.rich.out)
head(np.out)

# Calculate confidence intervals from the difference in average score (bootstrap minus actual)
ns.delta.star <- ns.richness -  ns.richness.act
ns.d <- quantile(ns.delta.star, c(1-Conf.int, Conf.int))

# Subtract the 10% and 90% quantile values from the actual mean to get the high and low confidence interval bounds
ns.ci <- ns.richness.act + c(ns.d[1],ns.d[2])
# Score each confidence bound and print to console
ns.ci.score.low <- round(ns.score(ns.ci[1], max.np.richness)*100)
ns.ci.score.high <- round(ns.score(ns.ci[2], max.np.richness)*100)

print(cat('Assessment Area', AA, '- Nectar Plant Richness Confidence interval:', ns.ci, 
          'species (', ns.ci.score.low, "-", ns.ci.score.high, "% )\n"))

##Habitat Function
data.out <- cbind(mw.out, np.out)
head(data.out)

Milkweed.SI <- (data.out[,"MWDense.Score"] * weight.mw.dense + data.out[,"MWRich.Score"] * weight.mw.rich) * threats * conserve_priority
data.out <- cbind(data.out, Milkweed.SI)
head(data.out)

Nectar.SI <- data.out[,"NP.Freq.Score"]*weight.np.freq + data.out[,"NPRich.score"]*weight.np.rich
data.out <- cbind(data.out, Nectar.SI) * threats * conserve_priority
head(data.out)

Habitat_Function <- data.out[,"Milkweed.SI"]*weight.mw + data.out[,"Nectar.SI"]*weight.np
data.out <- cbind(data.out, Habitat_Function)
head(data.out)

plot(Habitat_Function)

# Sum across each row (sample) and subtract from the actual mean to get the difference between the bootstrap sample
# and the actual mean
hsi.delta.star <- Habitat_Function - actual_habitat_function
plot(hsi.delta.star)

# Identify the 10% and 90% quantile values of the delta
hsi.d <- quantile(hsi.delta.star, c(1-Conf.int, Conf.int))
# Subtract the 10% and 90% quantile values from the actual mean to get the high and low confidence interval bounds
hsi.ci <- actual_habitat_function + c(hsi.d[1],hsi.d[2])

print(cat('Habitat Function Confidence interval:', round(hsi.ci*100), "% \n"))

# Plot the results
plot(Habitat_Function, main = AA, ylim = c(0,1))
abline (h = hsi.ci[2], col = 3)
abline (h = hsi.ci[1], col = 2)
abline (h = actual_habitat_function, col = 1)

