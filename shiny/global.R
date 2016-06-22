
library(sparklyr)
library(dplyr)

# Setup Spark cluster
#https://data.cityofnewyork.us/Public-Safety/NYPD-Motor-Vehicle-Collisions/h9gi-nx95
#sc <- spark_connect(master = "local", version = "1.6.1", hadoop_version = "1")
# nypd <- spark_read_csv(sc, "nypd", "file:///Users/jeff/Downloads/NYPD_Motor_Vehicle_Collisions.csv", overwrite=TRUE)
nypd <- tbl(sc, "nypd")

rmt <- nypd  %>% 
  filter(!is.na(LATITUDE), !is.na(LONGITUDE), LATITUDE != 0, LONGITUDE != 0) %>% 
  mutate(latbin = round(LATITUDE, 2), longbin = round(LONGITUDE, 2))

# cny <- cleanNY %>% select(latbin, longbin, CONTRIBUTING_FACTOR_VEHICLE_1) %>% collect()
# :( Until #32 is fixed...
#cleanNY <- rmt
cleanNY <- rmt %>% select(longbin, latbin, CONTRIBUTING_FACTOR_VEHICLE_1) %>% sample_n(50000) %>% collect()


reasonTbl <- cleanNY %>% 
  select(CONTRIBUTING_FACTOR_VEHICLE_1)  %>% 
  filter(CONTRIBUTING_FACTOR_VEHICLE_1 != "", CONTRIBUTING_FACTOR_VEHICLE_1 != "Unspecified")  %>% 
  rename(reason=CONTRIBUTING_FACTOR_VEHICLE_1) %>% 
  group_by(reason) %>% 
  tally() %>% 
  arrange(desc(n)) %>% 
  filter(n > 1) %>% # We need at least two points to compare on the map.
  collect() %>% 
  mutate(pretty = paste0(reason, " (", n, ")"))

