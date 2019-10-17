#First load in the data with 100 columns, each representing a subplot, and the number of plants/stems in each.

library (reshape2)

AA <- plot.data[1,]

m <- matrix(data = NA, nrow = 0, ncol = 100)

for(j in 1:100){
  density <- vector()
  for(i in 1:100){
    x <- sum(sample(AA,i))/i
    density <- append(density,x)
  }
  density.acres <- density*4048
  m <- rbind(m, density.acres)
}                 

m.sorted <- apply(m, 2, sort)
df <- as.data.frame(m.sorted)
colnames(df)<-c(seq(1,100))
df.melted <- melt(df)

boxplot <- boxplot(value~variable, data = df.melted, 
        main = "Bootstrap Confidence Intervals for Milkweed Densities", 
        sub = "Shield Ranch E - Fall 2017", xlab = "Number of Plots", 
        ylab = "Plants per Acre", ylim=c(0, 2000))

actual = mean(df[,100])
abline(h = actual * 1.2, col = "red")
abline(h = actual * 0.8, col = "red")
abline(h = actual, col = "blue")
print (actual)

