
library(sparklyr)
library(dplyr)

# Create the cluster connection and load data
sc <- spark_connect(master = "local", 
                    version = "2.0.0-preview", 
                    hadoop_version = "2.7")
nypd <- spark_read_csv(sc, 
         "nypd", 
         "file:///Users/jeff/Dropbox/Documents/RStudio/user2016/NYPD_Motor_Vehicle_Collisions.csv", 
         overwrite=TRUE)



### IDE integration



# Preview the table, doesn't download everything.
nypd

# Perform a dplyr operation
nypd %>% 
  filter(BOROUGH == "BRONX")

# Perform a SQL operation
penn <- nypd %>% 
  filter(ON_STREET_NAME == "PENNSYLVANIA AVENUE") %>% 
  filter(CONTRIBUTING_FACTOR_VEHICLE_1 != "") 

pennInjuries <- penn %>% 
  group_by(CONTRIBUTING_FACTOR_VEHICLE_1) %>% 
  summarize(injuries = mean(NUMBER_OF_PERSONS_INJURED)) %>% 
  arrange(desc(injuries))

pennInjuries
