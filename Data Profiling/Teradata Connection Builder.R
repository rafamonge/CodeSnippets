library("RJDBC")
library("rJava")

tdJdbcDriver <- "C:\\TeraJDBC\\terajdbc4.jar"
tdJdbcConfig <- "C:\\TeraJDBC\\tdgssconfig.jar"
tdpwd <- 'Password'
tdlogin <- 'Username'
tdServer<- 'Server'

GetTeradataJDBCConnection <- function(tdJdbcDriver = "C:\\TeraJDBC\\terajdbc4.jar"
                                      , tdJdbcConfig = "C:\\TeraJDBC\\tdgssconfig.jar"
                                      , tdlogin , tdpwd, tdServer){
  pasted <- paste(tdJdbcDriver, tdJdbcConfig, sep =";")
  drv = JDBC("com.teradata.jdbc.TeraDriver",pasted)
  conn <- dbConnect(drv, paste("jdbc:teradata://", tdServer, sep=""), tdlogin, tdpwd)  
}

