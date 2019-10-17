# IMPORTANT ! SPECIFY FILE PATHS FOR INPUT AND OUTPUT IN STEPS 1.1, 1.10, 2.1 AND 2.6

## This script contains two distinct scripts to calculate minimum detectable change (delta) and number of 
## samples required to detect statistically-significant differences from specified thresholds for each map unit.
## Before running script 2, you must alter the output of script 1 in Excel and upload the new file.

## Script 1
## This script calculates minimum detectable change (delta) for each variable in each map unit. Input data is 
## required from worksheet "2.5 Review Transect Data" in the Nevada Credit System - Credit Project Calculator 
## v1.2 or 1.21. Copy this data into a new workbook and format headers for import to R. Use the following header 
## names: MUID, MUNAME, TRID, EVAL, PRECIP, MEADOW, SAGESP, DISTSAGE, SAGECC, SAGEHT, SHRUBCC, FORBCC, FORBRICH, 
## GRASSCC, IAGCC. 'SAGECC' MUST be in the ninth column (column I in Excel) and 'IAGCC' MUST be in the fifteenth 
## column (column O in Excel).

# Load packages
library(reshape2)    # Used to melt dataframes (step 1.3)
library(plyr)    # Used to count number of samples per map unit (step 1.6)
library(xlsx)    # Used to export data to Excel format (step 1.10)

# (1.1) Import Dataset 
# !SPECIFY FILE PATH!
DATA <- read.csv("...")

# (1.2) Calculate standard deviation and mean of each variable for each map unit
DATA_sd <- aggregate (DATA, by = list(DATA$MUID), FUN = sd, na.rm = TRUE)
DATA_mean <- aggregate (DATA, by = list(DATA$MUID), FUN = mean, na.rm = TRUE)    #Warnings will occur for any non-numeric data but will not affect outcome

# (1.3) Melt "DATA_mean" and "DATA_sd" and vectorize before combining into a single dataframe
means <- melt(DATA_mean[10:16], value.name = "mean")
mean <- means$mean
sds <- melt(DATA_sd[10:16], value.name = "sd")
sd <- sds$sd
MUID <- rep(DATA_mean$Group.1, times = length(10:16))
variable <- mean$variable

# (1.4) Combine "MUID", "variable", "sd", and "mean" into a single dataframe
df <- data.frame(MUID, variable, mean, sd)

# (1.5) Calculate number of samples per map unit, rename columns
samples <- count(DATA, "MUID")
samples <- rename(samples, c("freq" = "n"))

# (1.6) Merge "samples" with "df"
df <- merge(df, samples, by = "MUID")

# (1.7) Add column to "df" to collect delta values and recommended samples
df$delta <- NA

# (1.8) Check that dataframe was prepared correctly
head(df)

# (1.9) Execute power test to calculate Delta
for (i in 1:nrow(df)){
  n <- df$n[i]
  sd <- df$sd[i]
  pwr <- try(power.t.test(n = n, delta = NULL, sd = sd, sig.level = 0.20, power = 0.80, type = c("one.sample"), alternative = c("two.sided")))
  if (inherits(pwr, "try-error")){
    df$delta[i] <- NA
  } else {df$delta[i] <- pwr$delta
  }
}

# (1.10) Export data
# !SPECIFY FILE PATH!
write.xlsx(df, "...") 

# Script 2
## This script calculates the number of samples required to detect statistically signficant changes
## from specified management thresholds. Management thresholds must be pre-determined and specified for each 
## variable in each map unit (for any variables where thresholds are desired). Open the exported data frame 
## created above, create a new column called "mgmt", and specify a managment threshold for each variable. If  
## management thresholds are not known, we recommend selecting the minimum funcitonal value for any variables whose 
## score is less than 100%, and the maximum functional value for any varibles whose score is greater than 100%. 
## Use the variable score associated with the Dominant Seasonal Habitat Type. Leave blanks for any variables where
## management thresholds are not relevant.

# (2.1) Load packages
library(xlsx)    # Used to export data to Excel format (step 2.6)

# (2.2) Import Dataset 
# !SPECIFY FILE PATH!
df2 <- read.csv("...")

# (2.3) Add column to "df2" to collect recommended sample requirements
df2$rec_n <- NA

# (2.4) Check dataframe was prepared correctly
head(df2)

# (2.5) Execute power test to calculate recommended sample requirements
for (i in 1: nrow(df2)){
  delta <- df2$mgmt[i]
  sd <- df2$sd[i]
  pwr <- try(power.t.test(n = NULL, delta = delta, sd = sd, sig.level = 0.2, power = 0.8, type = c("one.sample"), alternative = c("one.sided")))
  if (inherits(pwr, "try-error")){
    df2$rec_n[i] <- NA
  } else {df2$rec_n[i] <- pwr$n
  }
}

# (2.6) Export data
# !SPECIFY FILE PATH!
write.xlsx(df2, "...") 