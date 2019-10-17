library(raster)
setwd("D:/ArcGIS/Idaho/Mitigation Program/HQT_Inputs_20180608/TIFFs")

P_LocalScaleClip = raster("P_LocalScoreClip1.tif")
P_LocalScaleTransform = raster("P_LocalScoreTransformed1.tif")
O_Local_Weighted_Score = raster("O_Local_Weighted_Score1.tif")
P_LocalScaleMultAnthro = raster("P_LocalScoreMultAnthro1.tif")
LocalScoreDifference = raster("LocalScoreDifference1.tif")
O_LocalScoreClip = raster("O_LocalScoreClip1.tif")

par(mfrow=c(2,2))
hist(O_LocalScoreClip, maxpixels = 10000)
hist(O_Local_Weighted_Score, maxpixels = 10000)
hist(P_LocalScaleClip, maxpixels = 10000)
hist(P_LocalScaleTransform, maxpixels = 10000)

par(mfrow=c(1,2))
hist(O_Local_Weighted_Score, maxpixels = 10000)
hist(P_LocalScaleMultAnthro, maxpixels = 10000)

par(mfrow=c(1,1))
hist(LocalScoreDifference, maxpixels = 10000)
