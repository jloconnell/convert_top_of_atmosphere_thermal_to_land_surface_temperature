# Convert Landsat 8 top of atmosphere thermal band data to land surface temperature
Methods to retrieve atmospheric correction parameters from Barsi et al.'s (2003, 2005) NASA webtool and calculate land surface temperature from top of atmosphere Landsat 8 thermal band data

For more information, see our paper:

Alber, M., & O’Connell, J. L. (2019). Elevation drives gradients in surface soil temperature within salt marshes. Geophysical Research Letters, In Review.

**Step 1**: download Landsat 8 surface reflectance data, which also includes top of atmosphere brightness temperature bands 10 and 11,  for points of interest, from Google Earth Engine with the script available at https://github.com/jloconnell/Google_Earth_Engine/blob/master/landsat8_to_points.js

**Step 2**: Preprocess the landsat 8 data with the script XXX, which loads the data, filters to high quality cloud-free pixels and cacluates standard landsat 8 spectral indices (NDVI, etc)

**Step 3**: Uset the atmosphereic correction parameter retrival script to automate interaction with Julia Barsi's NASA web tool. This script is available at https://github.com/jloconnell/remote_sensing_with_R/blob/master/atmospheric_correction_landsat_suface_temp.r 

For more about Barsi's webtool see: 

Barsi, J. A., Barker, J. L., & Schott, J. R. (2003). An Atmospheric Correction Parameter Calculator for a single thermal band earth-sensing instrument. In IGARSS 2003. 2003 IEEE International Geoscience and Remote Sensing Symposium. Proceedings (IEEE Cat. No.03CH37477) (Vol. 5, pp. 3014–3016 vol.5). https://doi.org/10.1109/IGARSS.2003.1294665

Barsi, J. A., Schott, J. R., Palluconi, F. D., & Hook, S. J. (2005). Validation of a web-based atmospheric correction tool for single thermal band instruments. In Earth Observing Systems X (Vol. 5882, p. 58820E). International Society for Optics and Photonics. https://doi.org/10.1117/12.619990

**Step 4**: Merge the landsat data with the atmospheric parameters retrieved in step 3. Then apply the function for calculating land surface temperature available at 

This function requires NDVI, an estimate of land cover based on NDVI cut-offs, and an estimate of emissivity for each land cover type. NDVI cut-offs that distinguish among land cover types need to estimated for the region of interest. For example, in coastal wetlands, NDVI values for will be lowered by perennially moist soils in areas that are not densely vegetated. Thus the cut-off that distinguishes water, soil, and vegetation will be different than in upland areas. Once the land cover type is estimated by NDVI, a look-up table is used to associate the land cover with emissivity. Emissivity for land cover types can be calculated either from ground-truth data, or by averaging emissivity information for the land cover type from ASTER's band 13 (the closest wavelength to Landsat 8's band 10). ASTER emissivity data are also freely available on Google Earth Engine.
