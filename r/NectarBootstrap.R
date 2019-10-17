# This script creates a bootstrap sample of nectar plant frequency and richness for a specified Assessment Area.
# Run 'MonarchHQTReadfile.R" first to create df.np (dataframe of nectar data). Update the Assessment Area name below
# and adjust the max.np.richness for the region and season.

# Define the Assessment Area (use AA.names if unsure) and update the max species richness for the region and season.
AA <- "B"
max.np.richness <- 10

# Pre-defined variables
Conf.int <- .8
reps <- 1000
sample.plots <- 100


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
np.act.freq.ones <- length(which(np.plot.data==1))/100
np.act.freq.twos <- length(which(np.plot.data==2))/100 + np.act.freq.ones
np.act.freq.threes <- length(which(np.plot.data==3))/100 + np.act.freq.twos
np.act.freq.ones.score <- n.score(np.act.freq.ones, area = .25)
np.act.freq.twos.score <- n.score(np.act.freq.twos, area = .5)
np.act.freq.threes.score <- n.score(np.act.freq.threes, area = 1)
np.act.freq.score <- mean(c(np.act.freq.ones.score, np.act.freq.twos.score, np.act.freq.threes.score))
print(cat("Nectar Plant Frequency Score: ", round(np.act.freq.score*100), "%\n"))

# Set up a dataframe for storing samples, one column per plot (100) 
m <- matrix(data = NA, nrow = 0, ncol = sample.plots)
np.temp <- as.data.frame(m)
colnames(np.temp) <- colnames(df.np)

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
np.delta.star <- np.freq.scores.mean -  np.act.freq.score
np.d <- quantile(np.delta.star, c(1-Conf.int, Conf.int))

# Subtract the 10% and 90% quantile values from the actual score to get the high and low 
# confidence interval bounds
np.ci <- np.act.freq.score - c(np.d[2],np.d[1])
# Score each confidence bound and print to console
np.ci.score.low <- round(np.ci[1]*100)
np.ci.score.high <- round(np.ci[2]*100)

print(cat('Assessment Area', AA, '- Nectar Plant Frequency Confidence interval:', '(', np.ci.score.low, "-", 
          np.ci.score.high, "% score)\n"))

# Plot the results
plot(np.freq.scores.mean)
abline (h = np.ci[2])
abline (h = np.ci[1])

# Calculate confidence intervals from the difference in average score (bootstrap minus actual)
ns.delta.star <- ns.richness -  ns.richness.act
ns.d <- quantile(ns.delta.star, c(1-Conf.int, Conf.int))

# Subtract the 10% and 90% quantile values from the actual mean to get the high and low confidence interval bounds
ns.ci <- ns.richness.act - c(ns.d[2],ns.d[1])
# Score each confidence bound and print to console
ns.ci.score.low <- round(ns.score(ns.ci[1], max.np.richness)*100)
ns.ci.score.high <- round(ns.score(ns.ci[2], max.np.richness)*100)

print(cat('Assessment Area', AA, '- Nectar Plant RichnessConfidence interval:', ns.ci, 
          'species (', ns.ci.score.low, "-", ns.ci.score.high, "% )\n"))
