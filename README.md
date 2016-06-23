
## sparklyr Demos for UseR! 2016

> **Note**: Portions of this code (especially the Shiny application) require running Spark 2.0. While sparklyr is perfectly capable of running on Spark 1.x, some more complex SQL queries weren't implemented until Spark 2.0 -- and such queries are being used here.

![screen shot of shiny app](https://github.com/trestletech/user2016-sparklyr/blob/master/images/screenshot.png?raw=true)

You can find the sparklyr package here: https://github.com/rstudio/sparklyr

### Prerequisite Data

The data used in these examples was downloaded from the [NYC OpenData portal](https://data.cityofnewyork.us/). The particular data set is the NYPD Motor Vehicle Collisions which was downloaded from: https://data.cityofnewyork.us/Public-Safety/NYPD-Motor-Vehicle-Collisions/h9gi-nx95

You'll need to make this dataset available to your Spark cluster before you can run these applications. This could be done over S3 or HDFS, but if you're just using a local cluster you can download it to your file system and reference the file via `file:///Users/rest/of/path.csv`.

### Shiny Application

To run the Shiny

`runApp("./shiny")`

### R Markdown


