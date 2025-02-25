#' Read & Clean data from a File Dowloaded from the Scopus Database
#'
#' This function reads and performs tidy data on a file downloaded
#' from the Scopus Database. For more info on how to download the file, please
#' read the tutorial of this package in https://github.com/jdieramon/hIndex
#'
#' @param
#' file a file downloaded from Scopus
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
#' This function takes the tidy data file created by the \code{clean} function
#' and generates the h-index over years (from the first year [h=0] until the
#' most recent year [h=x]).
#'
#' @param
#' file a tidy data frame with papers in rows and other info in columns
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
          hvals[1] = h #*LINEA NUEVA
          
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


#' Estimate the number of expected citations in a period of time
#'
#' This function estimated the number of expected citations in a period of time 
#' based on the time that takes each paper to get 1 citation.
#'
#' @param file a tidy data frame
#' @param term period of time in months
#' 
#' @usage
#' expected_citations(dat, 6)
#' 
#' @author Jose V. Die
#' @export
#' @import dplyr

expected_citations <- function(file, term) {
    # file 
    # term in months 
    get1cite(file) %>% 
        mutate(term = term, 
               ratio = term / avgMonth, 
               exp_cit = floor(ratio)) %>% 
        select(Year, Journal, avgMonth, exp_cit)
    
    
}


#' Simple dataset : year and h index
#' 
#' Core function used by \code{\link{h.model}}.
#'  
#' @param file a tidy data frame with papers in rows and other info in colums;
#' @param a starting year.
#' @param b end year. It is usually the current year.
#' @param h the h-index that corresponds to the starting year (by default=0).
#' @author Jose V. Die


df_h <- function(file,a,b,h) {
    
    if( a != as.numeric(colnames(dat[8])) ) stop('history starts in ',
                                                 as.numeric(colnames(dat[8])))
    fin = as.numeric(names(dat)[ncol(dat)])
    stop = ifelse(b > fin, fin, b)
    y = c(a:stop)
    hvals = geth(file, h, stop)
    hvals[1] = h #*LINEA NUEVA
    names(hvals) = y
    myh = data.frame(Year = y, H = hvals)
    
    myh
    
}

#' Model the h-index over time 
#' 
#' This function makes a linear regression model of the h-index value for a given 
#' author over the years. 
#' 
#' @param file a tidy data frame with papers in rows and other info in columns;
#' @param a starting year.
#' @param b end year. It is usually the current year.
#' @param h the h-index that corresponds to the starting year (by default=0).
#' @author Jose V. Die
#' @export

h.model <- function(file,a,b,h) {
    
    myh = df_h(file,a,b,h)
    model_h <- lm(H ~ Year, data = myh)
    summary(model_h)
    
}

#' Plot a linear regression model for the h-index over time 
#' 
#' This function takes the h-index values for a given author over the years
#' produced by the \code{df_h } function and plot a linear regression model.
#'
#' @param file a tidy data frame with papers in rows and other info in colums;
#' @param a starting year.
#' @param b end year. It is usually the current year.
#' @param h the h-index that corresponds to the starting year (by default=0).
#' @author Jose V. Die
#' @export
#' @import ggplot2
#' @import dplyr


model.plot <- function(file,a,b,h) {
    
    myh = df_h(file,a,b,h)
    
    myh %>% 
        ggplot(aes(x = Year, y = H)) +
        geom_point(color = "steelblue", alpha = .9) +
        ylab('h Index') + 
        geom_smooth(method = "lm", col = "coral", lwd = 0.2)
    
    
}





expected_citations <- function(file, term) {
    # file 
    # term in months 
    get1cite(file) %>% 
        mutate(term = term, 
               ratio = term / avgMonth, 
               exp_cit = floor(ratio)) %>% 
        select(Year, Journal, avgMonth, exp_cit)
    
    
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

