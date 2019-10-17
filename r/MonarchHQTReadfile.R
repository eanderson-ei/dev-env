# This script reads in data from a Monarch HQT Calculator (v.1 - v1.1) and formats it in preparation
# for calculating bootstrap confidence intervals (see NectarBootstrap.R and MWBootstrap.R). Output
# is a table of milkweed data (df.mw) and nectar plant data (df.np, df.ns).Provide the path name and 
# file name to the pathname and filename variables, respectively.
library(readxl)
library(reshape2)

# Provide the location of the HQT Calculator on the drive
pathname <- "C:/Users/Erik/Downloads/HQT Calculators TX Pilots/HQT Calculators TX Pilots/Shield Ranch/Combined"
filename <- "Monarch HQT - South Central Credit Project Calculator v1.1_Shield Ranch Baseline - Combined2.xlsx"

# the max_samples variable will be used to NA-fill any missing data and cut extra data. All AAs must 
# have 100 and only 100 plots (increase to evaluate effect of pooling AA data)
max_samples <- 402

### Milkweed Data Reader
#Defined ranges for data within the workbook
mw.sheetname <- "6. Milkweed Availability"
mw.range <- "B7:G5003"
mw.col_types = c("text", "numeric", "text", rep("numeric", 3))
mw.col_names = c("AA", "Transect", "GENSPE", "Subplot", "Plants", "Stems")
mw.data <- read_excel(paste(pathname, "/", filename, sep=""), na = "n/a", sheet = mw.sheetname, 
                      range = mw.range, col_names = FALSE, col_types = mw.col_types)
colnames(mw.data)<- mw.col_names
head(mw.data)

# Omit blank rows from the spreadsheet
mw.data <- na.omit(mw.data, "AA")

# Add helper column "T10" with number of plot in sequence 1:100
mw.data$T10 <- mw.data$Transect*10-10+mw.data$Subplot
mw.data <- mw.data[order(mw.data$T10),]
head(mw.data)

# List unique Assessment Area names. Double brackets returns a list vs. a df. Why? IDK
AA.names <- unique(mw.data[["AA"]])
AA.names
length(AA.names)

# Create a dataframe for storing 100 plots for each AA. 
m <- matrix(data = NA, nrow = 0, ncol = max_samples)
df.mw <- as.data.frame(m)

for (AA in AA.names){
  # Zero-fill any subplots with no data and save into dataframe for each AA
  plots <- vector() #vector to save data
  index <- 1 #counter to advance down one table row each time plot data is taken
  for (j in 1: max_samples){
    #zero-fills back end once all plots are taken
    if(is.na(mw.data$T10[which(mw.data$AA==AA)][index])){
      plots<- c(plots, 0)
      #if subplot number is right, grab data
    } else if (mw.data$T10[which(mw.data$AA==AA)][index]==j){
      plots <- c(plots, (mw.data$Stems[which(mw.data$AA==AA)][index]))
      index <- index +1
      #else add a zero and move to next position
    } else{
      plots <- c(plots, 0)
    }
  }
  df.mw <- rbind(df.mw, plots)
}

# Update column and row names of dataframe
col_names2 <- paste("P", c(1:max_samples), sep="")
colnames(df.mw) <- col_names2
rownames(df.mw) <- AA.names
head(df.mw)

### Nectar Plant Data Reader
np.sheetname <- "5. Forb Availability"
np.range <- "B7:M1006"
np.col_types = c("text", rep("numeric", 11))
np.col_names = c("AA", "Transect", "P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8", "P9", "P10")
np.data <- read_excel(paste(pathname, "/", filename, sep=""), na = "n/a", sheet = np.sheetname, 
                      range = np.range, col_names = FALSE, col_types = np.col_types)
colnames(np.data)<- np.col_names
head(np.data)

# Omit blank rows from the spreadsheet
#np.data <- na.omit(np.data, "AA")
# Melt dataframe to get all plot data in one column
melted <- melt(np.data, id.vars = "AA", measure.vars = paste("P", c(1:10), sep = ""))
melted <- na.omit(melted, "value")
head(melted)

# List unique Assessment Area names (expected in the first column). Double brackets returns a list vs. a df. Why? IDK
AA.names <- unique(melted[["AA"]])
AA.names
length(AA.names)

# Create a dataframe for storing 100 plots for each AA. 
m <- matrix(data = NA, nrow = 0, ncol = max_samples)
df.np <- as.data.frame(m)

# Extract from melted dataframe the data for each plot. Repeat for all AAs and bind to dataframe
for (i in AA.names){
  AA <- melted[["value"]][which(melted["AA"]==i & !is.na(melted["value"]))]
  length(AA) <- max_samples
  df.np <- rbind(df.np, AA)
}

# Update column and row names of dataframe
col_names2 <- paste("P", c(1:max_samples), sep="")
colnames(df.np) <- col_names2
rownames(df.np) <- AA.names
head(df.np)

# Extract species richness data
ns.sheetname <- "2. Blooming Forb Species"
ns.range <- "B7:F1006"
ns.col_types = c(rep("text", 5))
ns.col_names = c("AA", "Scientific", "Abbr", "Common", "Notes")
df.ns <- read_excel(paste(pathname, "/", filename, sep=""), na = "", sheet = ns.sheetname, 
                      range = ns.range, col_names = FALSE, col_types = ns.col_types)
colnames(df.ns)<- ns.col_names
head(df.ns)

