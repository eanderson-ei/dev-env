#####
# EI rcode modifying Kevin Knight's rcode 
# Goal is to run stem and cost model for agriculture and pasture scnearios only including those two types of land classes

# This code builds off of cost.loop.r and thog.scenarios.r
####################################################

library(rjava)
library(xlsx)
library(tidyr)
library(dplyr)

####################################################

#Run lines 10, 15, 20 of thog.scenarios.r
library(raster)
ei.mh <- shapefile('national_mw_seamless_summaries_120616_acres.shp')
ei.tm <- read.csv('thog.milk.2.csv')

####################################################
#DATA PREP

#Filter scenarios so that only the scenarios based on the agriculture sector remain
ei.tm1 <- filter(ei.tm,Scenario == "Baseline")
ei.tm2 <- filter(ei.tm,Scenario == "Grass Protected Areas + Agriculture")

#order ei.tm3 by myres
ei.tm3 <- ei.tm2[order(ei.tm2$dif, decreasing = T),]

ei.tm4 <- bind_rows(ei.tm1,ei.tm3)

#clarify which scenario each row is
ei.tm4$pasture <- c("baseline","amended","amended","amended","amended")
ei.tm4$agriculture <- c("baseline","medium","medium","low","low")

#Keep only ag and pasture land cover classes
  ### see spreadsheet ERL_12_7_074005_suppdata.xlsx for land cover class names for each code

  ### land cover classes in Thog's scenario ("cl001", "cl002", "cl003", "cl004", "cl005", "cl007", "cl008"   ,     "cl009",'cl014',	'cl015',	'cl026','cl052',	'cl076',	'cl077',	'cl078',	'cl079','cl098'	,'cl099'   ,'cl100','cl110','cl120','cl140','cl174','cl200')

  ### land cover classes to keep
  # farm <- c("cl001", "cl002","cl003","cl004","cl005","cl007","cl008","cl009",'cl014','cl015')
  # pasture <- c('cl052','cl076','cl077','cl078','cl079')

### land cover classes to remove
###c("cl026",'cl098'	,'cl099','cl100','cl110','cl120','cl140','cl174','cl200')
ei.tm4 <- ei.tm4[,c(1:13,20:24,33:36)]


####################################################

# STEP 1: determine total stems for the 4 agriculture + pasture scenarios
########

## 1.1 run lines 25:31 of thog.scenario.r
ei.mhc <- ei.mh[which(ei.mh$reg_des == "North Central Core"),]
plot(ei.mhc, col = "gray96")
lines(ei.mhc, col = 'gray20')

ei.m2 <- ei.mhc@data 
ei.db <- ei.m2 

## 1.2 modify lines 32:36 of thog.scenario.r to include only relevant land cover classes

ei.db <- ei.db[,c(4:14,19:20,31,32:35)] #subset data #remove unnecessary columns
ei.m3 <- ei.db #set aside this duplicate of data to get values for analysis
ei.db[,3:18] <- NA #empty the ei.db dataset so that any values here represent results

cl <- names(ei.db[c(3:18)]) #get list of land cover classes for analysis


## 1.3 modify model in thog.scenario.r based on updated ei.db dataset and use ei.tm4 instead of tm
ei.base <- ei.db
for(i in 1:length(cl)){
  ei.base[,cl[i]] <- ei.m3[,cl[i]]*ei.tm4[1,cl[i]] #number after tm[ is chosen scenario
}
ei.base$total <- rowSums(ei.db[,3:18], na.rm = T)
total.stems <- sum(ei.base$total)


cl <- names(ei.db[3:18])
total.stems <- rep(NA, length(ei.tm4$Scenario))

for(k in 1:length(ei.tm4$Scenario)){
  for(i in 1:length(cl)){
    ei.db[,cl[i]] <- ei.m3[,cl[i]]*ei.tm4[k,cl[i]]
    ei.db$total <- rowSums(ei.db[,3:18], na.rm = T)
    total.stems[k] <- sum(ei.db$total)
  }
}


## 1.4 modify code in thog.scenario.r to use updated datasets
ei.tm4$myres <- total.stems #get total stems for each scenario
ei.tm4$mydif <-  ei.tm4$sum.stems - ei.tm4$myres #difference between my results and Wayne's



#########    RESULTS    ########
#Scenario: Grass Protected Areas + Agriculture, Agriculture: Medium, Pasture: Amended  
    #Rank: 1   
    #Total stems (myres): 976,224,049

#Scenario: Grass Protected Areas + Agriculture, Agriculture: Medium, Pasture: Amended  
    #Rank: 2   
    #Total stems (myres): 975,007,161

#Scenario: Grass Protected Areas + Agriculture, Agriculture: low, Pasture: Amended  
    #Rank: 3   
    #Total stems (myres): 955,062,689

#Scenario: Grass Protected Areas + Agriculture, Agriculture: low, Pasture: Amended  
    #Rank: 4   
    #Total stems (myres): 953,845,801

## 1.5 export data to Excel
write.csv(ei.m3,file='export_ei.m3_data.csv')
write.csv(ei.tm4,file='export_ei.tm4_data.csv')

####################################################

# STEP 2: identify cost results for ag + pasture scenarios
########

## 2.1 run lines 10-13 of cost.loop.r to bring in max productivitiy and costs data 
max.pot <- read.csv("max_potential_byclass.csv") #bring in potential productivity
max.pot <- max.pot[2,] #keep only max potential productivity
max.pot <- max.pot[,-1] #remove row names
costs <- read.csv('costs_by_class.v2.csv')


## 2.2 modify sectors from cost.loop.r
agriculture <- c("cl001", "cl002", "cl003", "cl004", "cl005", "cl007", "cl008" ,  "cl009",'cl014',	'cl015')
pasture <- c("cl052",	"cl076",	"cl077",	"cl078","cl079")


## 2.3 modify scenario cost table for results from cost.loop.r
ei.scenario.costs <- matrix(nrow=length(ei.tm4$Scenario),ncol = 19 ) # create blank ei.db with number of rows equalto the length of the scenario column in the tm ei.db and the number of columns equal to 37
colnames(ei.scenario.costs) <- c('total','agriculture','pasture', cl ) #add column names to the string scenario.costs
rownames(ei.scenario.costs) <- c('baseline','Pasture(Amended1)+Ag(Medium1)','Pasture(Amended2)+Ag(Medium2)','Pasture(Amended1)+Ag(Low1)','Pasture(Amended2)+Ag(Low2)')
ei.scenario.costs <- data.frame(ei.scenario.costs) #makes string into ei.db

## 2.4 modify state cost table for results from cost.loop.r
ei.state.costs <- matrix(ncol=ncol(ei.scenario.costs), nrow = nrow(costs)) #creates ei.db with number of columns = to scenario.costs and number of rows = to costs ei.dbs
rownames(ei.state.costs) <- costs$state #gives ei.db row names of states
colnames(ei.state.costs) <- colnames(ei.scenario.costs) #gives ei.db same column names as scenario.costs
ei.state.costs <- data.frame(ei.state.costs) #makes string into ei.db
ei.state.costs$state <- rownames(ei.state.costs) #adds column with state names
states <- rownames(ei.state.costs) #makes string of state names


## 2.4 modify stem calc and cost model from cost.loop.r
ei.base <- ei.db
ei.base <- cbind(ei.base[,1:2],ei.base[,cl]) #subset to remove columns not used in analysis

for(i in 1:length(cl)){
  ei.base[,cl[i]] <- ei.m3[,cl[i]]*ei.tm4[1,cl[i]] #number after tm[ is chosen scenario
}
ei.base$total <- rowSums(ei.base[,3:18], na.rm = T) #adds total stem count for the location across all land cover types
total.stems <- sum(ei.base$total) 

#Calculate stems in all scenarios
for(k in 2:length(ei.tm4$Scenario)){
  
  ei.x <- ei.db
  ei.x <- cbind(ei.x[,1:2],ei.x[,cl]) #subset to remove columns not used in analysis
  
  for(i in 1:length(cl)){
    ei.x[,cl[i]] <- ei.m3[,cl[i]]*ei.tm4[k,cl[i]] 
  }
  ei.x$total <- rowSums(ei.x[,3:18], na.rm = T)
  total.stems <- sum(ei.x$total)
  
  #Calculate increase in stems over baseline
  ei.diff <- (ei.x[,3:18]-ei.base[,3:18]) 
  ei.diff <- cbind(ei.base[,1:2],ei.diff) 
  
  max.pot.d <- max.pot[rep(1:nrow(max.pot),each=length(ei.diff$cnty_name)),]  
 
  ei.x1 <- ei.diff[,2:18] 
  ei.x1[cl] <- ei.x1[cl]/max.pot.d[cl]
  ei.x1$state_name <- as.factor(ei.x1$state_name)
  
  
  ei.x2 <- ei.x1 #setup ei.db to hold costs data
  ei.x2[,2:17] <- NA #remove stems data from ei.x2 so only costs data will be here
  
  #Distribute cost of practices by state
  ei.st.costs <- merge(ei.diff[,c(1:2)], costs, all = T, by.x = 'state_name', by.y = 'state' )
  ei.st.costs[,2] <- NULL
  
  ###### Here is the actual cost calculation ########################################
  for(i in 1:length(cl)){
    ei.x2[,cl[i]] <- ei.x1[,cl[i]]*ei.st.costs[,cl[i]]
  }
  
  #Summaries by sector
  ei.scenario.costs[k,1] <- sum(ei.x2[,2:17]) #Total Cost of Scenario
  ei.scenario.costs[k,2] <- sum(colSums(ei.x2[,agriculture]))
  ei.scenario.costs[k, 3] <- sum(colSums(ei.x2[,pasture]))
  ei.sector.cost <- colSums(ei.x2[,2:17])
  ei.scenario.costs[k,cl] <- ei.sector.cost[cl]
  
  k1 <- ei.state.costs
  for(m in 1:length(states)){
    ei.state.costs[which(ei.state.costs$state == states[m]),4:19] <- 
      colSums(ei.x2[which(ei.x2$state_name == states[m]),2:17])
    ei.state.costs[states[m],1] <- sum(ei.x2[which(ei.x2$state_name == states[m]),2:17])
    ei.state.costs[states[m],2] <- sum(colSums(ei.x2[which(ei.x2$state_name == states[m]),agriculture]))
    ei.state.costs[states[m],3] <- sum(colSums(ei.x2[which(ei.x2$state_name == states[m]),pasture]))
  
    nm <- paste('ei.state.costs',k, sep = ".")
    assign(nm, ei.state.costs)
  }
}

ei.scenario.costs[1,] <- 0 #Set baseline to zero costs
ei.scenario.costs$num <- seq(from = 0, to = 3, by =1 )

#####################################################

write.csv(ei.scenario.costs,file='export_ei.scenario.costs.csv')
write.csv(ei.st.costs,file='export_ei.st.costs.csv')
write.csv(ei.state.costs.2,file='export_ei.state.costs.2.csv')
write.csv(ei.state.costs.3,file='export_ei.state.costs.3.csv')
write.csv(ei.state.costs.4,file='export_ei.state.costs.4.csv')
write.csv(ei.state.costs.5,file='export_ei.state.costs.5.csv')
write.csv(ei.state.costs,file='export_ei.state.costs.csv')

####################################################

## This hasn't been integrated yet. The next step would be to rerun the code above with the revised max productivity data set from the code below. 

# multiply max potential productivity by 3
#assumption is that the max productivity of acres in the exchange will be 3 times higher than those not in the exchange
Ex_max.pot <- max.pot * 3

####################################################
