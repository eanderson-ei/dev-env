#Erik Anderson
#June 27, 2015
#A quick bootstrap function for a confidence interval for the mean

#x is a single quantitative sample
#y is the attribute of interest (expressed as 'x$y' (no quotes))
#a is the attribute of interest (expressed as y)
#z is the variable to subset by (if applicable; expressed as 'x$z' (no quotes))
#v is the observation of the variable 'z' to subset by (if applicable)
#B is the desired number of bootstrap samples
#t is the t- or z-statistic used to construct the confidence interval

#boot.ci = function(x,y,a,z,v,n = length(x), B=1000,t=1.684) {
#  select = subset(x, z == v, select = a)
#  print (select)
#  result = rep(NA, B)
#  for (i in 1:B) {
#    boot.sample = sample(select, n, replace = TRUE)
#    result[i] = mean(y[boot.sample])
#  }
#  with(x, mean(y) + c(-1,1) * t *sd(result))
#}

boot.ci = function(x, y, n = length(x), B=1000,t=1.684) {
  result = rep(NA, B)
  for (i in 1:B) {
    boot.sample = sample(x, n, replace = TRUE)
    result[i] = mean(y[boot.sample])
  }
  with(x, mean(y) + c(-1,1) * t *sd(result))
}
