library(readxl)
library(reshape2)

# Read in and format nectar plant frequency data from the HQT Calculator.
pathname <- "C:/Users/Erik/Downloads/HQT Calculators TX Pilots/HQT Calculators TX Pilots/Shield Ranch/"
filename <- "Monarch HQT - Shield - Spring 2017.xlsx"
mw.sheetname <- "6. Milkweed Availability"
mw.range <- "B7:G5003"
mw.col_types = c("text", "numeric", "text", rep("numeric", 3))
mw.col_names = c("AA", "Transect", "GENSPE", "Subplot", "Plants", "Stems")
mw.data <- read_excel(paste(pathname, filename, sep=""), na = "n/a", sheet = mw.sheetname, 
                 range = mw.range, col_names = FALSE, col_types = mw.col_types)
colnames(mw.data)<- mw.col_names
head(mw.data)

# the max_samples variable will be used to NA-fill any missing data and cut extra data. All AAs must have 100
# and only 100 plots (increase to evaluate effect of pooling AA data)
max_samples <- 100

# Omit blank rows from the spreadsheet
mw.data <- na.omit(mw.data, "AA")

# Add helper column "T10" with number of plot in sequence 1:100
mw.data$T10 <- mw.data$Transect*10-10+mw.data$Subplot
head(mw.data)

# List unique Assessment Area names. Double brackets returns a list vs. a df. Why? IDK
AA.names <- unique(mw.data[["AA"]])
AA.names
length(AA.names)

# Create a dataframe for storing 100 plots for each AA. 
m <- matrix(data = NA, nrow = 0, ncol = max_samples)
df.mw <- as.data.frame(m)

for (AA in AA.names){
  # Zero-fill any subplots with no data and save into datafrane for each AA
  plots <- vector() #vector to save data
  index <- 1 #counter to advance down one table row each time plot data is taken
  for (j in 1: max_samples){
    #zero-fills back end once all plots are taken
    if(is.na(mw.data$T10[which(mw.data$AA==AA)][index])){
      plots<- c(plots, 0)
      #if subplot number is right, grab data
    } else if (mw.data$T10[which(mw.data$AA==AA)][index]==j){
      plots <- c(plots, (mw.data$Stems[index]))
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

# Extract milkweed species lists
genspe <- matrix(data = NA, nrow = 0, ncol = )
for (AA in AA.names){
  sp <- mw.data$GENSPE[which(mw.data$AA==AA)]
  sp
  genspe <- c(genspe, sp)
  genspe
}
genspe
