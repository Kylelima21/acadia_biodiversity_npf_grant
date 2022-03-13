#!/usr/bin/env Rscript --vanilla

#------------------------------------------------#
####           Packages Required              ####
#------------------------------------------------#
require(utils)
require(tidyverse)
require(dplyr)
require(data.table)
require(rgdal)
require(sf)

select <- dplyr::select



#------------------------------------------------#
####              Read in Data                ####
#------------------------------------------------#

#Read in the full iNaturalist dataset
inat.all <- data.table::fread('data/inaturalist_alldata_20220312.csv', quote="")
#Read in general Acadia region dataset
inat.acad <- read.csv('data/inaturalist_acaddata_20220312.csv', header = TRUE)

#Read in NPS Boundary shapefile to use as a filter for the total iNaturalist dataset
nps.bounds = readOGR("data/nps_boundary.shp", verbose = FALSE)

#Read in the 30km buffer around Acadia NP
acadbuffer <- read_sf('data/acadbufferzone.shp')

##Commented out because we no longer need to run this code
##It is stored in google drive and can be downloaded using the next line of working code

# #Get just the Acadia NP polygons
# acad.bounds <- nps.bounds[nps.bounds@data$UNIT_NAME=="Acadia National Park", ]
# #Write out the file
# writeOGR(obj=acad.bounds, dsn="outputs/", layer="acad.bounds", driver="ESRI Shapefile") # this is in geographical projection
# #I then imported this into Google Earth Engine, wrote a script to create a 30km buffer, and exported that file



#------------------------------------------------#
####         Full Data Manipulation           ####
#------------------------------------------------#

##First remove a bunch of columns and filter to last 20 years to lessen the workload
inat.all <- inat.all %>% 
  select(kingdom, phylum, class, order, family, genus, species, decimalLatitude, decimalLongitude, year) %>% 
  filter(year != 2000 & year != 2001 & year != 2022)


##Filter full dataset to records inside national parks
#Create a spatial column 
coordinates(inat.all) <- ~ decimalLongitude + decimalLatitude
proj4string(inat.all) <- proj4string(nps.bounds)


#This is where the actual points live??
# polygondata <- nps.bounds@polygons
# test <- polygondata[[1]]
# test2 <- test@Polygons
# coords <- test2[[1]]@coords






#------------------------------------------------#
####         Acadia Data Manipulation         ####
#------------------------------------------------#

#First remove a bunch of columns and filter to last 20 years to lessen the workload
inat.acad <- inat.acad %>% 
  select(kingdom, phylum, class, order, family, genus, species, decimalLatitude, decimalLongitude, year) %>% 
  filter(year != 2000 & year != 2001 & year != 2022)


#Create a sf column using the lat long from inat records
pnts_sf_all <- st_as_sf(inat.acad, coords = c('decimalLongitude', 'decimalLatitude'), crs = st_crs(acadbuffer))

#Determine which records fall within the acadia buffer zone shp file
inat.acad.area <- pnts_sf_all %>% 
  mutate(
    intersection = as.integer(st_intersects(geometry, acadbuffer)),
    area = if_else(is.na(intersection), '', acadbuffer$UNIT_NAME[intersection])) 

#Filter by those records inside polygon
inat.acad.area <- filter(inat.acad.area, intersection==1)


###Get number of observations
##All = 33714
length(inat.acad.area$kingdom)
##By kingdom
#Plantae = 13756
length(inat.acad.area$kingdom[inat.acad.area$kingdom == "Plantae"])
#Animalia = 17387
length(inat.acad.area$kingdom[inat.acad.area$kingdom == "Animalia"])
#Fungi = 2060
length(inat.acad.area$kingdom[inat.acad.area$kingdom == "Fungi"])
#Chromista = 473
length(inat.acad.area$kingdom[inat.acad.area$kingdom == "Chromista"])
#Protozoa = 38
length(inat.acad.area$kingdom[inat.acad.area$kingdom == "Protozoa"])

acadia.totals <- data.frame(group = c('All groups','Plantae','Animalia','Fungi','Chromista','Protozoa'),
                            number.obs = c(paste(length(inat.acad.area$kingdom)), paste(length(inat.acad.area$kingdom[inat.acad.area$kingdom == "Plantae"])),
                                           paste(length(inat.acad.area$kingdom[inat.acad.area$kingdom == "Animalia"])), paste(length(inat.acad.area$kingdom[inat.acad.area$kingdom == "Fungi"])),
                                           paste(length(inat.acad.area$kingdom[inat.acad.area$kingdom == "Chromista"])), paste(length(inat.acad.area$kingdom[inat.acad.area$kingdom == "Protozoa"])))
)



#------------------------------------------------#
####        Write out processed files         ####
#------------------------------------------------#

#Create filedate to print the date the file is exported in the file name
filedate <- print(format(Sys.Date(), "%Y%m%d"))

#Drive output URL
drive.output <- 'https://drive.google.com/drive/u/4/folders/1Iu0lkoy4FO2RzKXMxRTrZu35G4wGM-8c'

#Write out final data for inat obs in all national parks


#Write out final data for inat obs in and around acadia
#write_csv(acadia.totals, paste('outputs/acadia_inattotals_', filedate, '.csv', sep=''))
#drive_upload('outputs/acadia_inattotals_20220313.csv', path = as_id(drive.output))








