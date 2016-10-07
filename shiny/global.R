
library(dplyr)
library(sparklyr)

# Setup Spark cluster
#https://data.cityofnewyork.us/Public-Safety/NYPD-Motor-Vehicle-Collisions/h9gi-nx95
#> min(dts2) [1] "2012-07-01 UTC"
#> max(dts2) [1] "2016-06-18 UTC"
sc <- spark_connect(master = "local", version = "2.0.1", hadoop_version = "2.7")
# nypd <- spark_read_csv(sc, "nypd", "file:///Users/jeff/Dropbox/Documents/RStudio/user2016/NYPD_Motor_Vehicle_Collisions.csv", overwrite=TRUE)
nypd <- tbl(sc, "nypd")

rmt <- nypd  %>% 
  filter(!is.na(LATITUDE), !is.na(LONGITUDE), LATITUDE != 0, LONGITUDE != 0) %>% 
  mutate(latbin = round(LATITUDE, 2), longbin = round(LONGITUDE, 2))

cleanNY <- rmt
# Needed on Spark < 2.0
#cleanNY <- rmt %>% select(longbin, latbin, CONTRIBUTING_FACTOR_VEHICLE_1) %>% sample_n(50000) %>% collect()


reasonTbl <- cleanNY %>% 
  select(CONTRIBUTING_FACTOR_VEHICLE_1)  %>% 
  filter(CONTRIBUTING_FACTOR_VEHICLE_1 != "", CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified")  %>% 
  rename(reason=CONTRIBUTING_FACTOR_VEHICLE_1) %>% 
  group_by(reason) %>% 
  tally() %>% 
  arrange(desc(n)) %>% 
  filter(n > 1) %>% # We need at least two points to compare on the map.
  collect() %>% 
  mutate(pretty = paste0(reason, " (", format(n, big.mark=",", trim=TRUE), ")"))

