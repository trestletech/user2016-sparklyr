
## sparklyr Demos for UseR! 2016

> **Note**: Portions of this code (especially the Shiny application) require running Spark 2.0. While sparklyr is perfectly capable of running on Spark 1.x, some more complex SQL queries weren't implemented until Spark 2.0 -- and such queries are being used here.

[The slides](https://github.com/trestletech/user2016-sparklyr/raw/master/sparklyr-user2016.pdf) and [demo](https://github.com/trestletech/user2016-sparklyr/blob/master/demo.R) from the talk at UseR! 2016 are available in the above file listing.

![screen shot of shiny app](https://github.com/trestletech/user2016-sparklyr/blob/master/images/screenshot.png?raw=true)

You can find the sparklyr package here: https://github.com/rstudio/sparklyr

### Prerequisite Data

The data used in these examples was downloaded from the [NYC OpenData portal](https://data.cityofnewyork.us/). The particular data set is the NYPD Motor Vehicle Collisions which was downloaded from: https://data.cityofnewyork.us/Public-Safety/NYPD-Motor-Vehicle-Collisions/h9gi-nx95

You'll need to make this dataset available to your Spark cluster before you can run these applications. This could be done over S3 or HDFS, but if you're just using a local cluster you can download it to your file system and reference the file via `file:///Users/rest/of/path.csv`.

The rest of the code is going to assume that this table has been loaded into your Spark cluster under the name of `nypd`. The easiest way to load the CSV is to use the `spark_read_csv()` function. As an example, to setup a local cluster and read in this data set, you could run:

```
sc <- spark_connect(master = "local", version = "2.0.0-preview", hadoop_version = "2.7")
spark_read_csv(sc, "nypd", "file:///Users/myname/Downloads/NYPD_Motor_Vehicle_Collisions.csv", overwrite=TRUE)
```

That command would load the dataset into your Spark cluster and make it available to other applications via `tbl(sc, "nypd")`.

### Shiny Application

The Shiny application is in the `./shiny` directory. You can simply run the commands below to run it, assuming you have the necessary packages installed.

```
library(shiny)
runApp("./shiny")
```

### R Markdown

The R Markdown example will create its own Spark context and re-copy the data in to that cluster. This is done because R Markdown documents are usually compiled in a separate process.

The easiest way to compile in the RStudio IDE is just to open the `./boroughs.Rmd` document and click `Knit`. It will take a minute or two to create the cluster, copy the data in, build the ML model, and run the rest of the code.
