#!/usr/bin/env Rscript --vanilla

#------------------------------------------------#
####           Packages Required              ####
#------------------------------------------------#
require(downloader)
require(googledrive)



#------------------------------------------------#
####              Gather Data                 ####
#------------------------------------------------#

#All NPS boundaries downloaded from the IRMA data store by URL
download('https://irma.nps.gov/DataStore/DownloadFile/668434', dest="data/nps_bound.zip") 
unzip("data/nps_bound.zip", exdir = "data/")


###Google Drive data
#IMPORTANT
#Type "1" in command line if to reactivate KL's API token from Google Drive,
# or enter 0 to obtain your own token linked to your account

##Download iNaturalist data sets stored in google drive, originally downloaded manually from GBIF.org
#Full dataset
drive_download('https://drive.google.com/file/d/1QUwxJi_H3BIHhUP5UN9XpCioWsTHYoEU/view?usp=sharing', path = 'data/inaturalist_alldata_20220312.csv')
#Acadia only
drive_download('https://drive.google.com/file/d/1LlaQh23b7eRW-TAvL21bi2N7K5ZiArJj/view?usp=sharing', path = 'data/inaturalist_acaddata_20220312.csv')

#Download the acadia buffer shapefile (and associated files)
drive_download('https://drive.google.com/file/d/1X9W4NO6CzTHqLP2aeZTO5PiMLC92bx_h/view?usp=sharing', path = 'data/acadbufferzone.zip', overwrite = FALSE)
unzip("data/acadbufferzone.zip", exdir = "data/")
