#http://adv-r.had.co.nz/OO-essentials.html


Account <- setRefClass("Account",
                       fields = list(Password = "character", User="character",Database = "character", Connection="ANY",Write="function"),
                       methods = list(
                         withdraw = function(x) {
                           Password <<- Password - x
                         }
                       )
)

#' Takes a filename and an extension and combines them together. If the extension is already in the filename, it returns the original filename
#'
#' Creates a plot of the crayon colors in \code{\link{brocolors}}
#'
#' @param filename method to order colors (\code{"hsv"} or \code{"cluster"})
#' @param extension character expansion for the text
#'
#' @return filename with extension
#'
#' @examples
#' PrepareFileNameWithExtension("hola.csv", ".csv") -> "hola.csv"
#' PrepareFileNameWithExtension("hola", ".csv") -> "hola.csv"
#'
#' @export
PrepareFileNameWithExtension <- function(filename, extension){
  if(!str_detect(filename, extension)){
    filename <- str_c(filename, extension)
  }
  filename
}


WriteCsv <- function(dataframe, folder, filename,...){
  tryCatch(
  {
    newFileName <- PrepareFileNameWithExtension(filename, ".csv")
    message(newFileName)
    myPath <- file.path(folder,newFileName)
    message(myPath)
    if (!file.exists(myPath)){
      write.csv(dataframe, file = myPath,...)
    }
    else{
      message("File already present")
    }
    
  }
  ,error = function(e){print(e)}
  )
}

