# Convert Landsat 8 top of atmosphere thermal band data to land surface temperature
These are scripts that calculate land surface temperature, as we did in our paper:

Alber, M., & O’Connell, J. L. (2019). Elevation drives gradients in surface soil temperature within salt marshes. Geophysical Research Letters, In Review.

These methods retrieve atmospheric correction parameters from Barsi et al.'s (2003, 2005) NASA webtool and calculate land surface temperature from top of atmosphere Landsat 8 thermal band data. Currently, one should only use Landsat 8's band 10 for thermal data, because noise from stray light reduces the utility of Landsat 8's band 11 (see Cook et al. 2014).

Cook, M., Schott, J. R., Mandel, J., & Raqueno, N. (2014). Development of an operational calibration methodology for the Landsat thermal data archive and initial testing of the atmospheric compensation component of a Land Surface Temperature (LST) product from the archive. Remote Sensing, 6(11), 11244–11266. https://doi.org/10.3390/rs61111244

**Step 1**: download Landsat 8 surface reflectance data, which also includes top of atmosphere brightness temperature bands 10 and 11,  for points of interest, from Google Earth Engine with the script available at https://github.com/jloconnell/Google_Earth_Engine/blob/master/landsat8_to_points.js

**Step 2**: Preprocess the landsat 8 data with the script:

https://github.com/jloconnell/convert_top_of_atmosphere_thermal_to_land_surface_temperature/blob/master/preprocess_landsat_8.r

This script loads the data, filters to high quality cloud-free pixels and creates date and location fields from standard Google Earth Engine output

**Step 3**: Cacluate standard landsat 8 spectral indices (NDVI, etc). If desired, use the function available at: 

https://github.com/jloconnell/remote_sensing_with_R/blob/master/landsat8_vegetation_indices.r

**Step 4**: Uset the atmosphereic correction parameter retrival script to automate interaction with Julia Barsi's NASA web tool. This script is available at https://github.com/jloconnell/remote_sensing_with_R/blob/master/atmospheric_correction_landsat_suface_temp.r 

This script will create a .csv file with for each landsat observation date and coarse lat/long location with the needed atmospheric parameters for calculate_lst_landsat8.r function in step 5.

For more about Barsi's webtool see: 

Barsi, J. A., Barker, J. L., & Schott, J. R. (2003). An Atmospheric Correction Parameter Calculator for a single thermal band earth-sensing instrument. In IGARSS 2003. 2003 IEEE International Geoscience and Remote Sensing Symposium. Proceedings (IEEE Cat. No.03CH37477) (Vol. 5, pp. 3014–3016 vol.5). https://doi.org/10.1109/IGARSS.2003.1294665

Barsi, J. A., Schott, J. R., Palluconi, F. D., & Hook, S. J. (2005). Validation of a web-based atmospheric correction tool for single thermal band instruments. In Earth Observing Systems X (Vol. 5882, p. 58820E). International Society for Optics and Photonics. https://doi.org/10.1117/12.619990

**Step 5**: Merge the landsat data with the atmospheric parameters retrieved in step 4. Then apply the function for calculating land surface temperature available at:
https://github.com/jloconnell/convert_top_of_atmosphere_thermal_to_land_surface_temperature/blob/master/calculate_lst_landsat8.r

This function requires the atmospheric transmission parameters from step 4, NDVI, an estimate of land cover based on NDVI cut-offs, and an estimate of emissivity for each land cover type. NDVI cut-offs that distinguish among land cover types need to estimated for the region of interest. For example, in coastal wetlands, NDVI values will be depressed by perennially moist soils in areas that are not densely vegetated (water is a good absorber of light, and thus water and moist soils will have lower spectral reflectance the dry soils and vegetation). Thus the cut-off that distinguishes water, soil, and vegetation will be different in wetlands than in upland areas. Similarly, cut-offs may vary seasonally, where NDVI cut-offs that separate vegetation from other land types will be lower in winter than summer. If the winter cut-off is sufficient for separating soil and vegetation, a good general practice is to use the winter cut-off year round. This is because bare soils should have similar NDVI year-round (e.g., spectral reflectance of bare soils typically don't change seasonally), whereas the difference between NDVI in soil and vegetation will increase as vegetation develops. Once the land cover type is estimated from NDVI, a series of ifelse statements that essentially create a landcover look-up table are used to associate the land cover with emissivity. Emissivity for land cover types can be calculated either from ground-truth data, or by averaging emissivity information for the land cover type from ASTER's band 13 (the closest wavelength to Landsat 8's band 10) (https://lpdaac.usgs.gov/products/ag100v003/). ASTER emissivity data are also freely available on Google Earth Engine with the image id "NASA/ASTER_GED/AG100_003".
