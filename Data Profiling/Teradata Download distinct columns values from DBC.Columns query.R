
# INSERT PASSWORD HERE#
# Teradata connection guide #http://developer.teradata.com/connectivity/articles/how-to-use-the-teradata-jdbc-driver-with-r
# Download Teradata bJDBC driver from here: http://downloads.teradata.com/download/connectivity/jdbc-driver

##--------------------------------------
tdpwd <- 'Password'
tdlogin <- 'User'
tdServer<- 'Server'
tdQuery <- "
SELECT Distinct DatabaseName, TableName
FROM DBC.Columns
where DatabaseName='Database'
order by DatabaseName, TableName"
outputFolder <- "F:\\Database\\"
tdJdbcDriver <- "C:\\TeraJDBC\\terajdbc4.jar"
tdJdbcConfig <- "C:\\TeraJDBC\\tdgssconfig.jar"
## -----------------------------------------------------------


library("RJDBC")
library("rJava")
library("stringr")
source("FileSavingUtilities.R")

pasted <- paste(tdJdbcDriver, tdJdbcConfig, sep =";")


drv = JDBC("com.teradata.jdbc.TeraDriver",pasted)
conn <- dbConnect(drv, paste("jdbc:teradata://", tdServer, sep=""), tdlogin, tdpwd)
res <- dbGetQuery(conn,tdQuery) 
operateee <- function(x) {
  select <- paste("Select top 100 * from ",  x$DatabaseName, ".", x$TableName, sep = "")
  message(select)
  newRes <- dbGetQuery(conn, select)
  WriteCsv(newRes, outputFolder, x$TableName)
  select
}
by(res, 1:nrow(res), operateee)
message("Finished!")
