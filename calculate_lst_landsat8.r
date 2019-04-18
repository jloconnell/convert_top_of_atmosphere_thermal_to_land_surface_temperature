##calculate Land Surface Temperature from band 10 for landsat 8
##assumes the following columns exit in the dataframe passed to the function:
##       ndvi, b10, trans, Iu, Id
calc_lst<- function(lsat, water.cut=0.05, soil.cut=0.15, veg.cut=0.4){
  ##proportion of vegetation for emmissivity calc
  ##Here, don't evaluate min and max ndvi by date, but use the class boundaries for veg and soil id'd below                                          
  pv<- ((lsat$ndvi-soil.cut)/(veg.cut-0))^2
  out<-data.frame(pv=pv)
  out$em10<- 0.991 ##em of water in aster band 13
  out$em10<-ifelse(lsat$ndvi>=veg.cut, 0.976+0.005, out$em10) ## em of pure veg, in aster product+constant for surface roughness
  out$em10<-ifelse(lsat$ndvi<=soil.cut&lsat$ndvi>= water.cut, 0.969, out$em10) ## em of soil in aster
  out$em10<-ifelse(lsat$ndvi<veg.cut&lsat$ndvi> soil.cut, 0.969*(1-out$pv)+0.976*out$pv+0.005, out$em10) ## em of soil-veg mix
  
  c1<-14387.6869
  c2<-1.19104356*10^8
  lmda<-10.895
  k1<-774.8853; k2<-1321.0789
  e<-2.7182818284590452353602874713527
  
  ##convert from brightness temp (in surface reflectance product), back to TOA radiance
  out$rtoa<-k1/(e^(k2/lsat$b10)-1) ### brightness temp = k2/(ln(k1/rtoa)+1), rearrange to rtoa =
  
  y<-(lmda^5/(lsat$trans*out$em10)) * (out$rtoa - lsat$Iu - lsat$trans*(1-out$em10)*lsat$Id)
  ##covert toa radiance to surface temp, using equation from Yu et al. 2014 Remote Sensing 6: 9829–52.
  lst<-c1/ (lmda* log((c2/y)+1))
  
  ##convert from Kelvin to Celsius
  lst<-lst-273.15
  return(lst)
}
