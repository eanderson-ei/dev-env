#Load required packages. Note you must import if you haven't already done so.
# install.packages("spsurvey") #if necessary

library(spsurvey)
library(rgdal)
library(xlsx)

# input parameters
wd = "E:/ArcGIS/Monarch HQT/ShieldRanch"
layerName = "AA_E"
exportTable = "AA_E.xlsx"
  
#Set working directory
setwd(wd)

#Read the shapefile that will serve as the sample frame and plot to confirm accuracy
shape <- readOGR(dsn = getwd(), layer = layerName)
plot(shape)

#Prepare data for GRTS draw
sp2shape(sp.obj = shape, shpfilename = "SampleFrame")
att <- read.dbf("SampleFrame")
set.seed(4447864)
shp <- read.shape("SampleFrame") #read.shp or read.shape?

#Execute GRTS draw (*Simple Random*)
Equaldsgn <- list(None=list(panel=c(Panel = 10), seltype = "Equal"))
Equalsites <- grts(design = Equaldsgn,
                   DesignID = "EQUAL",
                   type.frame = "area",
                   src.frame = "shapefile",
                   in.shape = "SampleFrame",
                   att.frame = att,
                   shapefile=FALSE)

#Print the initial six lines of the survey design
head(Equalsites@data)

#Print the survey design summary
summary(Equalsites)

#Export data
write.xlsx(Equalsites, exportTable)

