#Monarch restoration costs script 2
#
#This script calculates costs for all scenarios in Thogmartin et.al. 2017
#
#Use this with data from "All Hands on Deck" Thogmartin et. al. 2017
#All code here Copyright 2017, Kevin Bracy Knight and Environmental Defense Fund
#Last updated: 29 November 2017 by Kevin Bracy Knight

#Bring in Data
max.pot <- read.csv("max_potential_byclass.csv") #bring in costs
max.pot <- max.pot[2,] #keep only max potential productivity
max.pot <- max.pot[,-1] #remove row names
costs <- read.csv('costs_by_class.v2.csv')
cl <- names(db[c(3:11,16:23,28:35,37:40, 42)]) #get list of land cover classes for analysis

#Setup sectors

farm <- c("cl001", "cl002", "cl003", "cl004", "cl005", "cl007", "cl008" ,     "cl009",'cl014',	'cl015')
pasture <- c('cl052',	'cl076',	'cl077',	'cl078',	'cl079','cl098'	,'cl099')
roads <- c('cl110',	'cl120',	'cl140',	'cl174')
rails <- 'cl200'
power <- 'cl100'
urban <- c('cl021',	'cl022',	'cl023',	'cl024',	'cl025',	'cl026')

### Create repository for results

scenario.costs <- matrix(nrow=length(tm$Scenario),ncol = 37 )
colnames(scenario.costs) <- c('total','farm','pasture','roads','rails','power','urban', cl )
rownames(scenario.costs) <- tm$no
scenario.costs <- data.frame(scenario.costs)

state.costs <- matrix(ncol=ncol(scenario.costs), nrow = nrow(costs))
rownames(state.costs) <- costs$state
colnames(state.costs) <- colnames(scenario.costs)
state.costs <- data.frame(state.costs)
state.costs$state <- rownames(state.costs)
states <- rownames(state.costs)

#Step 1: Calculate base stems
base <- db
base <- cbind(base[,1:2],base[,cl]) #subset to remove columns not used in analysis

for(i in 1:length(cl)){
  base[,cl[i]] <- m3[,cl[i]]*tm[1,cl[i]] #number after tm[ is chosen scenario
}
base$total <- rowSums(base[,3:32], na.rm = T)
total.stems <- sum(base$total)


#Step 2: Calculate stems in all scenarios
# 
# 

for(k in 2:length(tm$Scenario)){
  
  x <- db
  x <- cbind(x[,1:2],x[,cl]) #subset to remove columns not used in analysis
  
  for(i in 1:length(cl)){
    x[,cl[i]] <- m3[,cl[i]]*tm[k,cl[i]] #number after tm[ is chosen scenario
  }
  x$total <- rowSums(x[,3:32], na.rm = T)
  total.stems <- sum(x$total)
  
  #Step 3: Calculate increase in stems over baseline
  # This should be part of the above loop
  diff <- (x[,3:32]-base[,3:32]) #subtract tested from baseline
  diff <- cbind(base[,1:2],diff) #add back in row names and counties
  
  max.pot.d <- max.pot[rep(1:nrow(max.pot),each=length(diff$cnty_name)),]  #repeat the max for number of rows in diff
  #this is to make the process much faster
  
  x1 <- diff[,2:32] #set aside the difference, now use x1
  #x1$state_name[which(x1$state_name == "Wisconsin")] <- "X"
  x1[cl] <- x1[cl]/max.pot.d[cl] #number of acres needed to be restored for class in county.
  x1$state_name <- as.factor(x1$state_name)
  
  
  x2 <- x1 #setup DB to hold costs data
  x2[,2:31] <- NA #remove stems data from x2 so only costs data will be here
  
  #Distribute cost of practices by state
  st.costs <- merge(diff[,c(1:2)], costs, all = T, by.x = 'state_name', by.y = 'state' )
  st.costs[,2] <- NULL
  
  #Here is the actual cost calculation
  for(i in 1:length(cl)){
    x2[,cl[i]] <- x1[,cl[i]]*st.costs[,cl[i]]
  }
  
  #Summaries by sector
  scenario.costs[k,1] <- sum(x2[,2:31]) #Total Cost of Scenario
  scenario.costs[k,2] <- sum(colSums(x2[,farm]))
  scenario.costs[k, 3] <- sum(colSums(x2[,pasture]))
  scenario.costs[k, 4] <- sum(colSums(x2[,roads]))
  scenario.costs[k, 5] <- sum((x2[,rails]))
  scenario.costs[k, 6] <- sum((x2[,power]))
  scenario.costs[k,7] <- sum(colSums(x2[,urban]))
  sector.cost <- colSums(x2[,2:31])
  scenario.costs[k,cl] <- sector.cost[cl]
  
  k1 <- state.costs
  for(m in 1:length(states)){
    state.costs[which(state.costs$state == states[m]),8:37] <- 
      colSums(x2[which(x2$state_name == states[m]),2:31])
    state.costs[states[m],1] <- sum(x2[which(x2$state_name == states[m]),2:31])
    state.costs[states[m],2] <- sum(colSums(x2[which(x2$state_name == states[m]),farm]))
    state.costs[states[m],3] <- sum(colSums(x2[which(x2$state_name == states[m]),pasture]))
    state.costs[states[m],4] <- sum(colSums(x2[which(x2$state_name == states[m]),roads]))
    
    state.costs[states[m],5] <- sum((x2[which(x2$state_name == states[m]),rails]))
                                    
    state.costs[states[m],6] <- sum((x2[which(x2$state_name == states[m]),power]))
    state.costs[states[m],7] <- sum(colSums(x2[which(x2$state_name == states[m]),urban]))
    nm <- paste('state.costs',k, sep = ".")
    assign(nm, state.costs)
  }
}

scenario.costs[1,] <- 0 #Set baseline to zero costs
scenario.costs$num <- seq(from = 0, to = 218, by =1 )




