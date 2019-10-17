library(tidyr)
library(ggplot2)
library(Hmisc)
library(plyr)
library(RColorBrewer)
library(reshape2)
library(dplyr)

my_data<- data.out
AA_Name <- rep("B", 1000)
my_data<-cbind(my_data, AA_Name)
head(my_data)

my_datal = melt(my_data, value.name = "Output")
head(my_datal)

raincloud_theme = theme(
  text = element_text(size = 10),
  axis.title.x = element_text(size = 16),
  axis.title.y = element_text(size = 16),
  axis.text = element_text(size = 14),
  axis.text.x = element_text(angle = 45, vjust = 0.5),
  legend.title=element_text(size=16),
  legend.text=element_text(size=16),
  legend.position = "right",
  plot.title = element_text(lineheight=.8, face="bold", size = 16),
  panel.border = element_blank(),
  panel.grid.minor = element_blank(),
  panel.grid.major = element_blank(),
  axis.line.x = element_line(colour = 'black', size=0.5, linetype='solid'),
  axis.line.y = element_line(colour = 'black', size=0.5, linetype='solid'))

lb <- function(x) mean(x) - sd(x)
ub <- function(x) mean(x) + sd(x)

sumld <- ddply(my_data, "Var2")
