#' Get the h-index From the Scopus Database
#'
#' This function assumes tidy data from Scopus (file) and generates the h-index
#' over years (from the first year [h=0] until the most recent year [h=x]).
#'
#' @param
#' file a tidy data frame with papers in row and other info in colums
#' where column 7 corresponds to the starting year.
#' @param
#' h an integer number with the h-index for the starting year.
#' @author Jose V. Die
#' @details
#' This function calculates cumulative number of citations starting with the
#' first year of your publication (which is assumed in the function to be h=0)
#' @seealso \code{rowSums}
#' @export

geth <- function(file,h=0) {
          h <- h
          vals <- numeric(1)
          cont <- 1
          for(i in 9:ncol(file)) {
                    ind <- which(rowSums(file[,8:i]) > h)
                    potential.h <- length(rowSums(file[ind,8:i]))
                    if(potential.h > h) {
                              for(j in potential.h:h) {
                                        if((sum(rowSums(file[ind,8:i]) >=j) >=j)==TRUE) {
                                                  h=j
                                                  break                                       }
                              }
                    }
                    cont <- cont + 1
                    vals[cont] <- h
          }
          vals
}



#' Plot the h-trajectory
#'
#' This function takes the h-index values for a given author over the years produced
#' by the \code{geth} function and plots them up.
#'
#' @param file a tidy data frame with papers in rows and other info in colums;
#' @param a starting year.
#' @param b end year. It is usually the current year.
#' @param h the h-index that corresponds to the starting year (by default=0).
#' @author Jose V. Die
#' @export

h.plot <- function(file,a,b,h) {
          barplot(geth(file,h), ylab="h-index", names.arg=a:b,
                  col="steelblue")
}
