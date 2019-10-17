#Load required packages. Note you must import if you haven't already done so.
library(spsurvey)
library(rgdal)
library(xlsx)

# input parameters
wd = "..."
layerName = "..."
exportTable = "..."
  
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
Equaldsgn <- list(None=list(panel=c(PanelOne = 15), seltype = "Equal"))
Equalsites <- grts(design = Equaldsgn,
                   +                    DesignID = "EQUAL",
                   +                    type.frame = "area",
                   +                    src.frame = "shapefile",
                   +                    in.shape = "SampleFrame",
                   +                    att.frame = att,
                   +                    shapefile=FALSE)

#Print the initial six lines of the survey design
head(Equalsites@data)

#Print the survey design summary
summary(Equalsites)

#Export data
write.xlsx(Equalsites, "...Name.xlsx")

###Execute GRTS draw (*Stratified*)
Stratdsgn <- list("Mountain Loam"=list(panel=c(PanelOne=60),seltype = "Equal"),
                  +                 "Aspen Woodland"=list(panel=c(PanelOne=7),seltype="Equal"),
                  +                 "Mountain Swale"=list(panel=c(PanelOne=8), seltype = "Equal"),
                  +                 "Loamy Breaks"=list(panel=c(PanelOne=5),seltype="Equal"))
Stratsites <- grts(design=Stratdsgn,
                   +                    DesignID="Stratified",
                   +                    type.frame="area",
                   +                    src.frame = "sp.object",
                   +                    sp.object=shp,
                   +                    att.frame = att,
                   +                    stratum="Map_Unit_N",
                   +                    shapefile = FALSE)

#Print the initial six lines of the survey design
head(Stratsites@data)

#Print the survey design summary
summary(Stratsites)

#Export data
write.xlsx(Stratsites, exportTable)