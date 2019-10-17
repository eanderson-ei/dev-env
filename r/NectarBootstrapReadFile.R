library(readxl)
library(reshape2)

# Read in and format nectar plant frequency data from the HQT Calculator.
pathname <- "C:/Users/Erik/Downloads/HQT Calculators TX Pilots/HQT Calculators TX Pilots/Shield Ranch/"
filename <- "Monarch HQT - Shield - Spring 2017.xlsx"
np.sheetname <- "5. Forb Availability"
np.range <- "B7:M1006"
np.col_types = c("text", "text", rep("numeric", 10))
np.col_names = c("AA", "Transect", "P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8", "P9", "P10")
np.data <- read_excel(paste(pathname, filename, sep=""), na = "n/a", sheet = np.sheetname, 
                 range = np.range, col_names = FALSE, col_types = np.col_types)
colnames(np.data)<- np.col_names
head(np.data)

# the max_samples variable will be used to NA-fill any missing data and cut extra data. All AAs must have 100
# and only 100 plots (increase to evaluate effect of pooling AA data)
max_samples <- 100

# Omit blank rows from the spreadsheet
np.data <- na.omit(np.data, "AA")
# Melt dataframe to get all plot data in one column
melted <- melt(np.data)
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
col_names2 <- paste("P", c(1:100), sep="")
colnames(df.np) <- col_names2
rownames(df.np) <- AA.names
head(df.np)

# Extract species richness data
ns.sheetname <- "2. Blooming Forb Species"
ns.range <- "B7:F1006"
ns.col_types = c(rep("text", 5))
ns.col_names = c("AA", "Scientific", "Abbr", "Common", "Notes")
ns.data <- read_excel(paste(pathname, filename, sep=""), na = "", sheet = ns.sheetname, 
                      range = ns.range, col_names = FALSE, col_types = ns.col_types)
colnames(ns.data)<- ns.col_names
head(ns.data)

# Save output in new folder named 'R' in original path. You must create the 'R' folder first.
outname <- paste(pathname, "R/", filename, "_NP.csv", sep="")
write.csv(df.np, outname)