####
# This script was developed for Environmental Incentives
# Technical Specialist Exercise
# By Jenna Stewart
####

#### Enter data below
# initiate variables for standard oil well
# insert the distance of impact from indirect effects
impact_distance = 600
# insert the initial quality at point of impact
init_quality = 50
# insert the final quality at the final impact distance
final_quality = 100 
# insert the step (dx) to calculate integrals
step = 10
# distance for the plot to extend
plot_distance = 1000 

#### You do not need to change anything below this line
# variables used for calculations
# initiate an empty vector
qualities=vector()

# set up the distance vector
distances = seq(0,plot_distance,step)

# calculate the habitat quality vector
for(i in 1:length(distances)){
  qualities[i] = ifelse(distances[i]<=impact_distance, 
                        (final_quality-init_quality)/(impact_distance/step)*(i-1) + init_quality,
                        100)
}

# calculate the habitat quality lost vector
qualities_lost = 100-qualities

# make the plot
par(mar=c(5,5,4,4))
plot(distances,qualities_lost,xlab="Distance from Well (m)",ylab="Habitat Quality Lost (%)",
     type="l",cex.axis=1.5,cex.lab=1.75)
points(distances,qualities_lost)

# calculate how many acres are lost
area_meters = pi * distances^2 # calculate area in m^2
area_acres = area_meters * 0.000247105 # convert to acres

# initialize the area increments
increment_acres_lost = 0

# calculate acres lost per area increment 

# calculate the area for each step (dx)
for(i in 2:length(area_acres)){
  increment_acres_lost[i] = area_acres[i]-area_acres[i-1]
}

# calculate the habitat lost for each area
total_acres_lost = increment_acres_lost * qualities_lost/100

# sum the values to get a final estimate of acres lost
total = round(sum(total_acres_lost[1:length(total_acres_lost)]),1)

# print the final value
print(paste("Standard Oil Well:",total,"Functional Acres Lost"))
