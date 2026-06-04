#' Read and clean data downloaded from Scopus
#'
#' Reads a CSV file exported from the Scopus database and performs
#' basic cleaning and formatting operations.
#'
#' The function reformats column names and removes unnecessary rows
#' and columns generated during the Scopus export process.
#'
#' @param fileName Character string indicating the path to a CSV file
#'   downloaded from Scopus.
#'
#' @return A tidy data frame containing publication metadata and
#' yearly citation counts.
#'
#' @author Jose V. Die
#'
#' @importFrom utils read.csv head
#' 
#' @export

clean_scopus <- function(fileName) {
  
  dat <- read.csv(fileName)
  
  colnames(dat) <- c(
    as.character(unlist(dat[6, 1:7])),
    dat[5, 8:ncol(dat)]
  )
  
  dat <- dat[, 1:(ncol(dat) - 3)]
  dat <- dat[, -8]
  dat <- dat[-c(1:6), ]
  
  citation_cols <- get_citation_cols(dat)
  
  dat[, citation_cols] <- lapply(
    dat[, citation_cols, drop = FALSE],
    as.numeric
  )
  
  dat
}


#' Compute h-index trajectory over time
#'
#' Computes the evolution of the h-index across years using citation
#' data exported from Scopus.
#'
#' @param data A tidy data frame created by \code{clean_scopus()}.
#' @param start_year Optional starting year for the analysis.
#'   Defaults to the earliest citation year available.
#' @param end_year Optional ending year for the analysis.
#'   Defaults to the latest citation year available.
#' @param h Initial h-index value (default = 0).
#'
#' @return A data frame with two columns:
#' \describe{
#'   \item{Year}{Citation year}
#'   \item{H}{Computed h-index}
#' }
#'
#' @details
#' The function computes cumulative citations over time and evaluates
#' the h-index iteratively for each year.
#'
#' @author Jose V. Die
#'
#' @export
h_index <- function(data,
                    start_year = NULL,
                    end_year = NULL,
                    h = 0) {
  
  citation_cols <- get_citation_cols(data)
  
  years <- as.numeric(names(data)[citation_cols])
  
  if (is.null(start_year)) {
    start_year <- min(years)
  }
  
  if (is.null(end_year)) {
    end_year <- max(years)
  }
  
  valid_cols <- citation_cols[
    years >= start_year &
      years <= end_year
  ]
  
  valid_years <- years[
    years >= start_year &
      years <= end_year
  ]
  
  hvals <- compute_h(data, valid_cols, h)
  
  # mantener origen histórico
  hvals[1] <- h
  
  build_h_df(valid_years, hvals)
}


#' Plot h-index trajectory over time
#'
#' Visualizes the evolution of the h-index across years.
#'
#' @param data A tidy data frame created by \code{clean_scopus()}.
#' @param start_year Optional starting year for the analysis.
#' @param end_year Optional ending year for the analysis.
#' @param h Initial h-index value (default = 0).
#'
#' @return A ggplot object representing the h-index trajectory.
#'
#' @author Jose V. Die
#'
#' @import ggplot2
#'
#' @export

plot_h <- function(data,
                   start_year = NULL,
                   end_year = NULL,
                   h = 0) {
  
  myh <- h_index(
    data,
    start_year,
    end_year,
    h
  )
  
  ggplot(myh, aes(Year, H)) +
    geom_point(color = "steelblue", alpha = 0.7) +
    geom_line(color = "steelblue") +
    ylab("h Index")
}


#' Fit a linear model to h-index evolution
#'
#' Fits a linear regression model describing the relationship
#' between h-index and year.
#'
#' @param data A tidy data frame created by \code{clean_scopus()}.
#' @param start_year Optional starting year for the analysis.
#' @param end_year Optional ending year for the analysis.
#' @param h Initial h-index value (default = 0).
#'
#' @return An object of class \code{lm}.
#'
#' @details
#' The fitted model assumes linear growth of the h-index over time.
#'
#' @author Jose V. Die
#'
#' @importFrom stats lm
#' 
#' @export
fit_h_model <- function(data,
                        start_year = NULL,
                        end_year = NULL,
                        h = 0) {
  
  myh <- h_index(
    data,
    start_year,
    end_year,
    h
  )
  
  lm(H ~ Year, data = myh)
}



#' Plot linear model of h-index evolution
#'
#' Plots the observed h-index trajectory together with
#' a fitted linear regression model.
#'
#' @param data A tidy data frame created by \code{clean_scopus()}.
#' @param start_year Optional starting year for the analysis.
#' @param end_year Optional ending year for the analysis.
#' @param h Initial h-index value (default = 0).
#'
#' @return A ggplot object containing observed values and fitted trend.
#'
#' @author Jose V. Die
#'
#' @import ggplot2
#'
#' @export
plot_h_model <- function(data,
                         start_year = NULL,
                         end_year = NULL,
                         h = 0) {
  
  myh <- h_index(
    data,
    start_year,
    end_year,
    h
  )
  
  ggplot(myh, aes(Year, H)) +
    geom_point(color = "steelblue") +
    geom_smooth(
      method = "lm",
      color = "coral",
      linewidth = 0.5
    )
}


#' Estimate citation speed for publications
#'
#' Estimates the average number of months required for a publication
#' to receive one citation.
#'
#' @param data A tidy data frame created by \code{clean_scopus()}.
#' @param n Number of rows to return (default = 10).
#'
#' @return A tidy data frame containing publication year,
#' journal name, and estimated months per citation.
#'
#' @author Jose V. Die
#'
#' @import dplyr
#'
#' @export

citation_speed <- function(data, n = 10) {
  
  citation_cols <- get_citation_cols(data)
  
  now <- as.numeric(format(Sys.Date(), "%Y"))
  
  data %>%
    mutate(
      citations = rowSums(
        sapply(
          across(all_of(citation_cols)),
          as.numeric
        ),
        na.rm = TRUE
      ),
      years = now -
        as.numeric(`Publication Year`)
    ) %>%
    filter(years > 0, citations > 0) %>%
    mutate(
      months_per_citation =
        round(years * 12 / citations, 2)
    ) %>%
    arrange(months_per_citation) %>%
    rename(
      year = `Publication Year`,
      journal = `Journal Title`
    ) %>%
    select(
      year,
      journal,
      months_per_citation
    ) %>%
    head(n)
}


#' Estimate future citations over a time period
#'
#' Estimates the expected number of citations over a specified
#' time window based on historical citation speed.
#'
#' @param data A tidy data frame created by \code{clean_scopus()}.
#' @param term Numeric value indicating the prediction period in months.
#'
#' @return A tidy data frame containing estimated future citations.
#'
#' @details
#' Citation projections are based on a simple linear approximation:
#'
#' \deqn{
#' expected\_citations =
#' \left\lfloor
#' \frac{term}{months\_per\_citation}
#' \right\rfloor
#' }
#'
#' @author Jose V. Die
#'
#' @seealso \code{citation_speed}
#'
#' @import dplyr
#'
#' @export

predict_citations <- function(data, term = 12, n = 10) {
  
  citation_speed(data, n=n) %>%
    mutate(
      expected_citations =
        floor(term / months_per_citation)
    )
}




#' Detect citation columns in a Scopus dataset
#'
#' Internal helper function used to identify yearly citation columns
#' in a cleaned Scopus dataset.
#'
#' Citation columns are assumed to have numeric names corresponding
#' to publication years (e.g. 2018, 2019, 2020).
#'
#' @param data A tidy data frame created by \code{clean_scopus()}.
#'
#' @return An integer vector containing the indices of citation columns.
#'
#' @author Jose V. Die
#'
#' @keywords internal

get_citation_cols <- function(data) {
  
  is_year_col <- suppressWarnings(
    !is.na(as.numeric(names(data)))
  )
  
  which(is_year_col)
}


#' Compute cumulative h-index values
#'
#' Internal helper function used to iteratively compute the h-index
#' trajectory from yearly citation data.
#'
#' @param data A tidy data frame created by \code{clean_scopus()}.
#' @param citation_cols Integer vector containing citation column indices.
#' @param h Initial h-index value (default = 0).
#'
#' @return A numeric vector containing h-index values over time.
#'
#' @details
#' The function computes cumulative citations year by year and
#' updates the h-index iteratively.
#'
#' @author Jose V. Die
#'
#' @keywords internal
compute_h <- function(data, citation_cols, h = 0) {
  
  hvals <- numeric(length(citation_cols))
  
  for (k in seq_along(citation_cols)) {
    
    i <- citation_cols[k]
    
    cites <- rowSums(
      sapply(
        data[, citation_cols[1]:i, drop = FALSE],
        as.numeric
      ),
      na.rm = TRUE
    )
    
    potential.h <- sum(cites > h)
    
    if (potential.h > h) {
      
      for (j in potential.h:h) {
        
        if (sum(cites >= j) >= j) {
          h <- j
          break
        }
      }
    }
    
    hvals[k] <- h
  }
  
  hvals
}

#' Build h-index trajectory data frame
#'
#' Internal helper function used to generate a tidy data frame
#' containing h-index values across years.
#'
#' @param years Numeric vector of years.
#' @param hvals Numeric vector of h-index values.
#'
#' @return A data frame with two columns:
#' \describe{
#'   \item{Year}{Citation year}
#'   \item{H}{Computed h-index}
#' }
#'
#' @author Jose V. Die
#'
#' @keywords internal

build_h_df <- function(years, hvals) {
  
  data.frame(
    Year = years,
    H = hvals
  )
}
