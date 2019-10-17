#Monarch restoration costs script 1
#
#This script imports all GIS data from Thogmartin et.al. and determines the costs. 
#
#Use this with data from "All Hands on Deck" Thogmartin et.al. 2017
#All code here Copyright 2017, Kevin Bracy Knight and Environmental Defense Fund
#Last updated: 29 November 2017 by Kevin Bracy Knight

#Initialize
library(raster)

#2 Import dataset

#bring in the milkweed by-acre dataset
mh <- shapefile('E:\\ArcGIS\\Monarch HQT\\monarch_cons_plan_tools\\gis_data\\north_central_mw_seamless_summaries_090915_acres.shp') 

#bring in the scenarios dataset 
# this is just the Excel file from the supplemental to "all hands"
# I stripped off the top row, leaving the scenario descriptions
tm <- read.csv('C:\\Users\\Erik\\Downloads\\thog.milk.2.csv')

#3 Data prep

#subset the shapefile to contain only the North Central Core area
mhc <- mh[which(mh$reg_des == "North Central Core"),]
plot(mhc, col = "dark blue")
lines(mhc, col = 'grey')
#View(mhc)

m2 <- mhc@data #to speed up process extract data from shapefile
db <- m2 #create duplicate of data, so changes do not alter original
db <- db[,c(4:35,38:48)] #subset data 
m3 <- db #set aside this duplicate of data to get values for analysis
db[,3:43] <- NA #empty the db dataset so that any values here represent results

cl <- names(db[c(3:11,16:23,28:35,37:40, 42)]) #get list of land cover classes for analysis



#4 Run models

#####
#Create baseline stems for calculations
  #Use this if you are interested in comparing a particular scenario
base <- db
for(i in 1:length(cl)){
  base[,cl[i]] <- m3[,cl[i]]*tm[1,cl[i]] #number after tm[ is chosen scenario
}
base$total <- rowSums(db[,3:43], na.rm = T)
total.stems <- sum(base$total)


#####
#  Calulate total stems for each scenario
# NOTE: as currently designed, this just calcs the total stems for each scenario and places them into a DB ("total.stems")
cl <- names(db[3:43])
total.stems <- rep(NA, length(tm$Scenario))

for(k in 1:length(tm$Scenario)){
  for(i in 1:length(cl)){
    db[,cl[i]] <- m3[,cl[i]]*tm[k,cl[i]]
    db$total <- rowSums(db[,3:43], na.rm = T)
    total.stems[k] <- sum(db$total)
  }
}


tm$myres <- total.stems #get total stems for each scenario
tm$mydif <-  tm$sum.stems - tm$myres #difference between my results and Wayne's
tm$myfrac <- tm$myres / tm$sum.stems #fraction difference between my results and Waybes
tm$mydif = tm$myres - tm$myres[1] #how many new stems did each of my scenarios create over my dbline results?

#Find out differences between my results and Wayne's
tm1 <- tm[order(tm$sum.stems, decreasing = T),] #duplicate the DB and sort by Wayne's model performance
tm1$rank <- 1:length(tm1$Scenario) #label model rank
tm2 <- tm1[order(tm1$myres, decreasing = T), ] #duplicate DB sorted by my rank

order(tm2$rank)

#5 Data visualization

#create a plot showing how my results' ranks compare to Wayne's
plot(tm2$rank, col = "grey", pch = 16, xlab = "Wayne's results ranked",
     ylab = 'my results ranked')
abline(a = 0, b = 1, col = 'red', lwd = 2)
points(tm2$rank, col = "grey", pch = 16)

#how many more or fewer stems did my model create compared to his?
tm$d.fr.tm <- (tm$sum.stems - tm$myres)/tm$sum.stems #fraction difference between the two results

#plot differences between the two models as a percent
plot(tm$d.fr.tm*100, col = "grey", pch = 16, ylab = '% Diff from Results', 
     xlab = 'Scenario')
abline(a = 0, b = 0, col = 'red', lwd = 2)
points(tm$d.fr.tm*100, col = "grey", pch = 16)

tm$num <- seq(from = 0, to = 218, by =1 )
