# convert Landsat 8 top of atmosphere thermal band data to land surface temperature
Methods for retrieving atmospheric correction parameters from Barsi et al 's NASA webtool 
and calculating land surface temperature from top of atmosphere Landsat 8 thermal band data

Step 1: download Landsat 8 surface reflectance data, which also includes top of atmosphere brightness temperature bands 10 and 11,  for points of interest, from Google Earth Engine with the script available at https://github.com/jloconnell/Google_Earth_Engine/blob/master/landsat8_to_points.js

Step 2: Preprocess the landsat 8 data with the script XXX, which loads the data, filters to high quality cloud-free pixels and cacluates standard landsat 8 spectral indices (NDVI, etc)

Step 3: Uset the atmosphereic correction parameter retrival script to automate interaction with Julia Barsi's NASA web tool. This script is available at https://github.com/jloconnell/remote_sensing_with_R/blob/master/atmospheric_correction_landsat_suface_temp.r 

Step 4: Merge the landsat data with the atmospheric parameters retrieved in step 3. Then apply the function for calculating land surface temperature available at 

This function requires NDVI, an estimate of land cover based on NDVI, and an estimate of emissivity based on land cover. Emissivity for land cover types can be calculated either from ground-truth data, or by averaging emissivity information for the land cover type from ASTER's band 13 (the closest wavelength to Landsat 8's band 10). 
