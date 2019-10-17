library(boot)

AA <- "A"
AA.data <- df.mw[AA,]
AA.boot <- t(AA.data)

data <- data.frame(AA.boot)
data

meanfun <- function(data, i){
  d <- data[i, ]
  return(mean(d))
}

bo <- boot(data=data[ ,1 , drop = FALSE], statistic = meanfun, R=100)
bo$t0

plot(bo)

ci <- boot.ci(bo, conf=0.8, type = "bca")

ci.high <- ci$bca[5]*4046.86
ci.low <- ci$bca[4]*4046.86

ci.score.high <- round((1-(2/(1+exp(6*(ci.high/2000)))))*100)
ci.score.low <- round((1-(2/(1+exp(6*(ci.low/2000)))))*100)

print(cat('Confidence interval:', ci$bca[4]*4048, ci$bca[5]*4048, '(', ci.score.low, "-", ci.score.high, "% )\n"))
