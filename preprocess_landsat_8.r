##load libraries 
library(tidyverse); library(R.utils)

##read in landsat files and create useful data columns from the extra fields in the Earth Engine output
##this code assumes you used the landsat8_to_points.js script available at https://github.com/jloconnell/Google_Earth_Engine/blob/master/landsat8_to_points.js
##Use this script in Google Earth Engine to return a .csv file of landsat 8 surface reflectance band data for point locations of interest
##This script will then:
##     process that data to cloud-free pixels, 
##     label the pixels as wet or dry with landsat's pixel quality band, 
##     create date, time and location fields 
##     scale the data to their native scales
##     filter nonsense values, 
##     clean the data by removing columns that are no longer needed

lsat<-read_csv("/path/to/file/landsat_file_name.csv")

##Landsat observation date and time
lsat$time<-substr(lsat$date,12,19)
lsat$hr<-as.numeric(substr(lsat$time,1,2))
lsat$min<-as.numeric(substr(lsat$time,4,5))
lsat$sec<-as.numeric(substr(lsat$time,7,8))
lsat$date<-as.Date(substr(lsat$date,1,10))
lsat$year<-as.numeric(format(lsat$date, "%Y"))
lsat$doy<-as.numeric(format(lsat$date, "%j"))
lsat$mo<-as.numeric(format(lsat$date, "%m"))

##filter cloudy pixels if there are any and create the landsat wet flag, all from pixel_qa
##see https://lsat.usgs.gov/lsat-surface-reflectance-quality-assessment
lsat$pixel_qa<-intToBin(lsat$pixel_qa)
##which pixels to keep: "000010" from the right means no fill, yes clear, no water, no cloud shadow, "000100" is the same but with water
lsat$qa_good<-ifelse(str_sub(lsat$pixel_qa,-6,-1) %in% c("000010", "000100"),T,F) 
lsat$radsat_qa<-intToBin(lsat$radsat_qa)
## "000100" is water with no clouds
lsat$wet<-ifelse(str_sub(lsat$pixel_qa,-6,-1)=="000100",T,F) 
##Another pixel quality field, not as reliable as pixel_qa
lsat$sr_aerosol<-intToBin(lsat$sr_aerosol) 

##if needed subset to just good pixels
lsat<-lsat[lsat$qa_good==T,]

##create location columns from .geo
x<-strsplit(lsat$".geo", "\\[")
x<-sapply(x, "[[", 2)
x<-strsplit(x, "\\]")
x<-sapply(x, "[[", 1)
x<-strsplit(x, ",")
lsat$long<-as.numeric(sapply(x, "[[", 1))
lsat$lat<-as.numeric(sapply(x, "[[", 2))

##apply the right scaling factor to band data
## 0.0001 converts bands 1-7 to spectral reflectance (0-1)
## 0.1 the top of atmosphere brightness temp in thermal bands to Kelvin
lsat$b1<-lsat$B1*0.0001
lsat$b2<-lsat$B2*0.0001
lsat$b3<-lsat$B3*0.0001
lsat$b4<-lsat$B4*0.0001
lsat$b5<-lsat$B5*0.0001
lsat$b6<-lsat$B6*0.0001
lsat$b7<-lsat$B7*0.0001
lsat$b10<-lsat$B10*0.1
lsat$b11<-lsat$B11*0.1

##remove columns we don't need now
lsat<-dplyr::select(lsat, -c(B1,B2,B3,B4,B5,B6,B7,B10,B11, `system:index`,.geo, radsat_qa, sr_aerosol, pixel_qa, qa_good))
head(lsat)

##remove bad band data, negative values happen in scene corners sometimes 
##and negative spectral reflectance is nonsense
lsat$b1<-ifelse(lsat$b1<0,NA, lsat$b1)
lsat$b2<-ifelse(lsat$b2<0,NA, lsat$b2)
lsat$b3<-ifelse(lsat$b3<0,NA, lsat$b3)
lsat$b4<-ifelse(lsat$b4<0,NA, lsat$b4)
lsat$b5<-ifelse(lsat$b5<0,NA, lsat$b5)
lsat$b6<-ifelse(lsat$b6<0,NA, lsat$b6)
lsat$b7<-ifelse(lsat$b7<0,NA, lsat$b7)

##reduce the data to only observations with realistic spectral information
lsat<-lsat[is.na(lsat$b1)==F,]; lsat<-lsat[is.na(lsat$b7)==F,]; lsat<-lsat[is.na(lsat$b5)==F,];lsat<-lsat[is.na(lsat$b6)==F,]

