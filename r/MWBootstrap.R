# This script creates a bootstrap sample of milkweed density and richness for a specified Assessment Area.
# Run 'MonarchHQTReadfile.R" first to create df.mw (dataframe of milkweed data). Update the Assessment Area name below.

# Define the Assessment Area (use AA.names if unsure).
#Select the Assessment Area and confidence interval
AA <- "B"
Conf.int <- .8
reps <- 1000
sample.plots <- 100

mw.plot.data <- df.mw[AA,]

# Define milkweed scoring function
mw.score <- function(mw){
  if(mw > 2000){
    x <- 1
  } else {
    x <-  1-(2/(1+exp(6*(mw/2000))))
  }
  return (x)
}

# Calculate mean (in plants/acre) and convert to a score, print to console
xbar <- sum(mw.plot.data)/sample.plots*4046.86
xscore <- mw.score(xbar)*100
print(cat('Sample mean: ', xbar, '(', xscore, '% )', "\n"), sep = "")


# Set up a dataframe for storing samples, one column per plot (100) 
m <- matrix(data = NA, nrow = 0, ncol = sample.plots)
mw.temp <- as.data.frame(m)
colnames(mw.temp) <- colnames(df.mw)

# Sample the plot data 100 times and add each sample as a new row in the created dataframe
for (i in 1:reps){
  F.star <- sample(mw.plot.data, length(mw.plot.data), replace = TRUE)
  colnames(F.star) <- colnames(mw.temp)
  mw.temp <- rbind(mw.temp, F.star)
}
mw.dense <- rowSums(mw.temp)/sample.plots*4046.86
plot(mw.dense)

# Score each bootstrap rep
mw.dense.score <- sapply(mw.dense, mw.score)
plot(x = mw.dense.score)

# Bootstrap for milkweed richness
unique.species = unique(mw.data$GENSPE[which(mw.data$AA==AA)])
unique.species
num.mw <- length(mw.data$GENSPE[which(mw.data$AA==AA)])
num.mw
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

# Combine the data into an output table
mw.out <- cbind(mw.dense, mw.dense.score, mw.eff.sp, mw.sp.rich.score)
colnames(mw.out) <- c("MWDense", "MWDense.Score", "MWRich", "MWRich.Score")
head(mw.out)

### Use below if only interested in milkweed uncertainty
# Sum across each row (sample) and subtract from the actual mean to get the difference between the bootstrap sample
# and the actual mean
mw.delta.star <- mw.dense - xbar
plot(mw.delta.star)

# Identify the 10% and 90% quantile values of the delta
mw.d <- quantile(mw.delta.star, c(1-Conf.int, Conf.int))
# Subtract the 10% and 90% quantile values from the actual mean to get the high and low confidence interval bounds
mw.ci <- xbar - c(mw.d[2],mw.d[1])
# Score each confidence bound and print to console
mw.ci.score.low <- round(mw.score(mw.ci[1])*100)
mw.ci.score.high <- round(mw.score(mw.ci[2])*100)

print(cat('Assessment Area', AA, '- Confidence interval:', mw.ci, '(', mw.ci.score.low, "-", mw.ci.score.high, "% )\n"))

# Plot the results
plot(mw.dense)
abline (h = mw.ci[2])
abline (h = mw.ci[1])



