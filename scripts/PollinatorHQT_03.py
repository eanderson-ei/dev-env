import os
import rasterio
import numpy as np
import pandas as pd
from scipy import signal
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm

#identify working directory, lulc tiff, and table of lulc and species values
wd = r'E:\ArcGIS\Pollinator HQT\test'
in_path = r'E:\ArcGIS\Pollinator HQT\scratch\LULC_test.tif'
table = r"C:/Users/Erik/Downloads/Pollinator HQT - Data Tables.xlsx"

#list nesting substrates and seasons to be evaluated; must match table columns
nest_types = ['ground', 'wood', 'stem', 'cavity']
seasons = ['f1', 'f2', 'f3']

#define cell size of input tiff
cell_size = 30

#the decay_cut value is the quantile at which the foraging distance-decay
#curve is truncated in the caluclation
decay_cut = .99

#define the output data type for saving rasters
dtype = rasterio.float64

##MOVE DOWN AFTER MAIN IS DEFINED

def kerncalc(beta, cell_size, decay_cut):
    radius = -(beta/cell_size) * np.log(1-decay_cut)
    matrix_rows = int(round(radius) * 2 + 1)
    matrix_columns = int(round(radius) * 2 + 1)
    kernel = np.zeros((matrix_rows, matrix_columns))
    center_row = (matrix_rows - 1) / 2
    center_column = (matrix_columns - 1) / 2
    for r in range(matrix_rows):
        for c in range(matrix_columns):
            kernel[r,c] = np.sqrt((r - center_row)**2 + (c - center_column)**2)
    reachable = kernel < radius
    kernel = np.exp(-kernel/(beta/cell_size))
    kernel = kernel/sum(sum(kernel)) * reachable
    print ("kernel dim is " + str(matrix_rows) + "x" + str(matrix_columns)
    + " " + str(cell_size) + "m pixels; " + "radius = " + str(round(radius,2))
    + " pixels")    
    return kernel 

def foragecalc(tiff, kernel):
    c = signal.convolve(tiff, kernel, mode = 'same', method = 'fft')  
    return c

   

#read in data tables for lulc and species, convert to dictionary
species = pd.read_excel(table, "species")
lulc = pd.read_excel(table, "lulc")
speciesDict = species.to_dict() #key is index, starting at 0
lulcDict = lulc.set_index('lulc').to_dict() #key is lulc code

#read in raster and save as 'array', save type and profile for use later 
with rasterio.open(in_path) as src:
    src_types = {i: dtype for i, dtype in zip(src.indexes, src.dtypes)}
    src_profile = src.profile
    src_profile.update(dtype = dtype)
#    height = src.shape[0]
#    width = src.shape[1]
#    count = 1
#    dtype = src_types[1]
#    crs = src.crs
    array = src.read(1).astype(dtype)

#calculate site-scale nesting suitability
for nest in nest_types:
    nest_score = np.vectorize(lulcDict[nest].get)(array)
    with rasterio.open(os.path.join(wd, "lulc_" + nest + ".tif"), 'w', 
                       **src_profile) as out:
        out.write(nest_score.astype(dtype), 1)
            
#calculate site-scale floral resources
for k in seasons:
    forage_score = np.vectorize(lulcDict[k].get)(array)
    with rasterio.open(os.path.join(wd, "lulc_" + k + ".tif"), 'w',
                       **src_profile) as out:
        out.write(forage_score.astype(dtype), 1)
        
#calculate pollinator-specific nesting and forageing suitability for p 
#pollinators
for p in range(len(speciesDict['species'])):
    p_name = speciesDict['species'][p]
    print(p_name)
    #calculate nesting suitability
    #set up a list of arrays to store the nesting scores for n nesting 
    #substrates
    nest_arrays = []
    
    #iterate through the nesting types, getting the suitability score from 
    #the dictionary, opening the .tif where the nest scores are stored,
    #reading that into an array, and multiplying each value by the suitability
    #score using an anonymous 'lambda' function. 
    for nest in nest_types:
        nest_suit = speciesDict[nest][p]
        with rasterio.open(os.path.join(wd, "lulc_" + nest + ".tif")) as src:
            array = src.read(1)
        nest_score = np.vectorize(lambda x: x * nest_suit)(array)
        nest_arrays.append(nest_score)
    
    #select the maximum value for each overlapping cell and save output
    #in a unique file for each species
    max_nest_score = np.maximum.reduce(nest_arrays)
    
    #show the nest score
    print('visualizing nest score')
    plt.imshow(max_nest_score)
    plt.show()
    
    with rasterio.open(os.path.join(wd, p_name + "_nest.tif"),
                       'w', **src_profile) as out:
        out.write(max_nest_score.astype(dtype), 1)   
    
    #calculate seasonal site-scale forage for p pollinators
    #(see #calculate nesting suitability)
    forage_arrays=[]
    for k in seasons:
        season_suit = speciesDict[k][p]/100
        with rasterio.open(os.path.join(wd, "lulc_" + k + ".tif")) as src:
            array = src.read(1)
        forage_score = season_suit * array
        forage_arrays.append(forage_score)
    weighted_forage_score = np.add.reduce(forage_arrays)
    with rasterio.open(os.path.join(wd, p_name + "_wforage.tif"), 
                       'w', **src_profile) as out:
        out.write(weighted_forage_score.astype(dtype), 1)
        
    #calculate foraging suitability
    #calculate kernel based on foraging distance
    alpha = speciesDict['alpha'][p]
    kernel = kerncalc(alpha, cell_size, decay_cut)
    
    #Plot the kernel
    fig = plt.figure()
    ax = fig.gca(projection = '3d')
    X = np.arange(0,kernel.shape[0])
    Y = np.arange(0,kernel.shape[1])
    X,Y = np.meshgrid(X, Y)
    Z = kernel
    ax.plot_surface(X,Y,Z, cmap = cm.bwr, linewidth = 0, 
                       antialiased = False)
    plt.show()
    
    #calculate foraging availability using the kernel
    forage_avail = foragecalc(weighted_forage_score, kernel)
    
    #plot output
    print("visualizing forage availability")
    plt.imshow(forage_avail)
    plt.show()
    
    
    #save output
    with rasterio.open(os.path.join(wd, p_name + "_forageAvail.tif"), 
                       'w', **src_profile) as out:
        out.write(forage_avail.astype(dtype), 1)
    
    #calculate overall pollinator suitability for p pollinators 
    #multiply max_nest_score by weighted_forage_score
    p_suitability = max_nest_score/100 * forage_avail/100
    
    #save output
    with rasterio.open(os.path.join(wd, p_name + "_suitability.tif"), 
                       'w', **src_profile) as out:
        out.write(p_suitability.astype(dtype), 1)
    
    print('visualizing suitability')
    plt.imshow(p_suitability)
    plt.show()
    print("---------------------------------------------------------")
