#' Read & Clean data from a File Dowloaded from the Scopus Database
#'
#' This function reads and performs tidy data on a file dowloaded
#' from the Scopus Database. For more info on how to dowload the file, please
#' read the tutorial of this package in https://github.com/jdieramon/hIndex
#' @param
#' fileName a file downloaded from Scopus
#' @author Jose V. Die
#' @export

clean <- function(fileName) {
    dat <- read.csv(fileName)
    colnames(dat) = c(as.character(unlist(dat[6,1:7])),dat[5,8:ncol(dat)])
    dat = dat[ , 1:(ncol(dat)-3)]
    dat=dat[,-8]
    dat = dat[-c(1:6),]
    dat
}


#' Get the h-index From the Scopus Database
#'
#' This function takes the tidy data file created by the \code{clead} function
#' and generates the h-index over years (from the first year [h=0] until the
#' most recent year [h=x]).
#'
#' @param
#' file a tidy data frame with papers in rows and other info in colums
#' @param
#' h an integer number with the h-index for the starting year.
#' @author Jose V. Die
#' @details
#' This function calculates cumulative number of citations starting with the
#' first year of your publication (which is assumed in the function to be h=0)
#' @seealso \code{rowSums}
#' @export

geth <- function(file, h=0, stop) {

          stop = which(names(file) == as.character(stop))

          h <- h
          vals <- numeric(1)
          cont <- 1
          for(i in 9:stop) {
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
#' This function takes the h-index values for a given author over the years
#' produced by the \code{geth} function and plots them up.
#'
#' @param file a tidy data frame with papers in rows and other info in colums;
#' @param a starting year.
#' @param b end year. It is usually the current year.
#' @param h the h-index that corresponds to the starting year (by default=0).
#' @author Jose V. Die
#' @export
#' @import ggplot2
#' @import dplyr

h.plot <- function(file,a,b,h) {

          if( a != as.numeric(colnames(dat[8])) ) stop('history starts in ',
                                                       as.numeric(colnames(dat[8])))

          fin = as.numeric(names(dat)[ncol(dat)])
          stop = ifelse(b > fin, fin, b)

          y = c(a:stop)

          hvals = geth(file, h, stop)
          
          names(hvals) = y
          print(hvals)

          myh = data.frame(Year = y, H = hvals)

          myh %>%
                    ggplot(aes(x = Year, y = H)) +
                    geom_point(color = "steelblue", alpha = .7) +
                    geom_line(color = "steelblue") +
                    scale_x_discrete(limits = a:stop) +
                    ylab('h Index')


}

#' Format the file and estimate the time (in months) that takes to get 1 citation
#'
#' @param file a tidy data frame
#' @return a tidy data frame that will be used by \code{plot1cite}
#' @author Jose V. Die
#' @export
#' @import dplyr

get1cite <- function(file,n=10) {
          tmp <-  as.Date(Sys.Date(), '%Y/%m/%d')
          now = as.numeric(format(tmp, '%Y'))
          time = now - as.numeric(as.character(file[,1]))

          dat = mutate(file, Cites = apply(file[,8:ncol(file)], 1, sum)) %>%
                    arrange(desc(Cites)) %>%
                    mutate(Years= now - as.numeric(as.character(`Publication Year`))) %>%
                    filter(Years>0) %>%
                    mutate(avgMonth=round(Years*12/Cites,2)) %>%
                    arrange(avgMonth) %>%
                    rename('Year' = `Publication Year`, 'Journal' = `Journal Title`) %>%
                    select(Year, Journal, avgMonth)

          head(dat, n)
}


#' Plot the time that takes to get 1 citation for a set of publications
#'
#' This function takes the file produced by the \code{format1cite} and plots
#' it up.
#'
#' @param file a tidy data frame produced by \code{format1cite}
#' @author Jose V. Die

plot1cite <- function(file){
          dat <- format1cite(file)
          ncolor = sum(as.vector(table(cut(dat$sC, breaks=c(0:12))))>0)
          cols <- rev(brewer.pal(ncolor, "Blues")) #"BuGn"
          ntone = as.vector(table(cut(dat$sC, breaks=c(0:12))))[as.vector(table(cut(dat$sC, breaks=c(0:12))))>0]
          tones=rep(cols, ntone)
          names=dat$`Publication Year`
          xx <- barplot(dat$sC, col=tones, ylab = "Months",
                        main = "Getting 1 citation", xlab="Publication Id.",
                        ylim=c(1,12), cex.names = 0.8, las=1)
          text(x = xx, y = dat$sC, label = names, pos = 3, cex = 0.8, col = "steelblue")
}

