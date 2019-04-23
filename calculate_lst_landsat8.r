##calculate Land Surface Temperature from band 10 for landsat 8
##assumes the following columns exist in the dataframe passed to the function and that ndvi was created from surface reflectance:
##       ndvi, b10, trans, Iu, Id (the last three are from Barsi's web-tool)
##assumes that the following land covers are of interest: water, soil, vegetation
##water.cut, soil.cut, and veg.cut are the NDVI cut-offs that separate these land cover classes
##water.em, soil.em and veg.em are the estimated land cover emissivities for the area of interest.
## emissivity can be estimated with ground-truth data or from ASTER (https://lpdaac.usgs.gov/products/ag100v003/)
## ASTER data are also availabe in Google Earth Engine with the image id "NASA/ASTER_GED/AG100_003"
calc_lst<- function(lsat, water.cut=0.05, soil.cut=0.15,  veg.cut=0.45, water.em= 0.991, soil.em=0.969, veg.em=0.98){
  
  ####calculate the proportion of vegetation in the pixel:  ####
  ##see Avdan, U., & Jovanovska, G. (2016). Algorithm for automated mapping of land surface temperature 
  ##        using LANDSAT 8 satellite data. Journal of Sensors, 2016, 1–8. https://doi.org/10.1155/2016/1480307
  ##and: Yu et al. (2014). Land surface temperature retrieval from Landsat 8 TIRS—Comparison between 
  ##        radiative transfer equation-based method, split window algorithm and single channel method. 
  ##        Remote Sensing, 6(10), 9829–9852. https://doi.org/10.3390/rs6109829
  ## note that these papers suggest 0.5 for veg.cut (e.g., ndvi>0.5 is vegetation) 
  ##   and 0.2 for soil.cut in upland habitats; In wetlands, spectral reflectance is dampened by watery backgrounds. 
  ##   The default cut offs and associated emissivities in the function defintion were the ones we observed 
  ##   at our salt marsh site on Sapelo Island
  
  ##proportion of vegetation, which can be used to weight the emmissivity calc of mixed soil and vegetation pixels
  pv<- ((lsat$ndvi-soil.cut)/(veg.cut-soil.cut))^2
  ##clean up pv, to represent a ratio from 0 to 1
  ##this recoding just says that, if pv as indicated by ndvi is greater than my veg cut-off, 
  ##I know this pixel is 100% vegetation, similarly, if it's below my soil cut-off, I know this 100% soil
  pv<-ifelse(pv>1, 1, pv)
  pv<-ifelse(pv<0, 0, pv)
  
  ##start building a data frame that can hold our calculations
  out<-data.frame(pv=pv)
  
  ##assign emissivities based on land cover type (assumed from ndvi and the cover type ndvi cut offs )
  ##begin by assigning all pixels the emissivity of water in aster band 13
  out$emiss<- water.em
  ##now selectively change the emissivity of pixels that are not water, again with info from ASTER
  ##here the emissivity to assign is based on land cover type, which is decided by NDVI cut-offs (eg, land covers have different NDVI)
  ## emiss of pure veg, in aster product+constant for surface roughness
  out$emiss<-ifelse(lsat$ndvi>=veg.cut, veg.em+0.005, out$emiss) 
  ## emiss of marsh soil in aster
  out$emiss<-ifelse(lsat$ndvi<=soil.cut&lsat$ndvi>= water.cut, soil.em, out$emiss)
  ##for mixed soil and vegetation pixels, weight the emissivity by the proportion of each (pv is proportion vegetation)
  out$emiss<-ifelse(lsat$ndvi<veg.cut&lsat$ndvi> soil.cut, soil.em*(1-out$pv)+veg.em*out$pv+0.005, out$emiss) 
  
  
  ##Calculate Land Surface Temperature from:
  ##  emissivity, top of atmosphere band 10 radiance, and atmospheric correction parameters
  
  ##all the constants we need
  ##for equation from Yu et al. 2014 Remote Sensing 6: 9829–52.
  c1<-14387.6869
  c2<-1.19104356*10^8
  k1<-774.8853; k2<-1321.0789
  e<-2.7182818284590452353602874713527
  ##this is wavelength of band 10 in landsat 8
  lmda<-10.895
  
  
  ##convert from brightness temp (e.g., what's returned from the Earth Engine Landsat 8 surface reflectance product), back to TOA radiance
  out$rtoa<-k1/(e^(k2/lsat$b10)-1) ### brightness temp = k2/(ln(k1/rtoa)+1), rearrange to rtoa =
  
  ##covert toa radiance to surface temp, using equation from Yu et al. 2014 Remote Sensing 6: 9829–52.
  ##This uses the emissivity we estimated above, the atmosphere parameters and toa radiance
  y<-(lmda^5/(lsat$trans*out$emiss)) * (out$rtoa - lsat$Iu - lsat$trans*(1-out$emiss)*lsat$Id)
  lst<-c1/ (lmda* log((c2/y)+1))
  
  ##convert lst from Kelvin to Celsius
  lst<-lst-273.15
  return(lst)
}
