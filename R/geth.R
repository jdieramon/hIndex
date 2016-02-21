#' Get the h-index From Scopus Database
#'
#' This function assumes tidy data from Scopus (file) and generates the h-index
#' over years (from the first year [h=0] until the most recent year [h=x]).
#'
#' @param
#' file a tidy data frame with papers in row and other info in colums
#' where column 7 corresponds to the first year of h=0.
#' @author Jose V. Die
#' @details
#' This function calculates cumulative number of citations starting with the
#' first year of your publication (which is assumed in the function to be h=0)
#' @seealso \code{rowSums}
#' @export

geth <- function(file) {
          h <- 0
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
#' @param a starting year, so h=0 for that year.
#' @param b end year. It is usually the current year.
#' @author Jose V. Die
#' @export

h.plot <- function(file,a,b) {
          barplot(geth(file), ylab="h-index", names.arg=a:b,
                  col="steelblue")
}
