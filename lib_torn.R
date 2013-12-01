# library of functions

library(plyr)

read_torn_data <- function() {
  # read raw data
  torn <- read.csv("data/1950-2012_torn.csv", header = FALSE, sep = ",", as.is = TRUE)
  
  # add column names based on documentation
  colnames(torn) <- c("OM", "YEAR", "MONTH", "DAY", "DATE", "TIME", "TIMEZONE", 
                      "STATE", "FIPS", "STATENUMBER", "FSCALE", "INJURIES", 
                      "FATALITIES", "LOSS", "CROPLOSS", "SLAT", "SLON", "ELAT", 
                      "ELON", "LENGTH", "WIDTH", "NS", "SN", "SG", "F1", "F2", 
                      "F3", "F4")
  
  # a tornado spanning multiple counties is listed separately for each county
  # thus, a single tornado could appear multiple times
  # identify unique tornadoes based on YEAR, OM and NS
  # check for existence of tornadoes spanning multiple years (i.e, begin on 12/31 
  # and end on 1/1); need to check only those with NS > 1
  dec31 <- subset(torn, MONTH == 12 & DAY == 31 & NS != 1)
  jan01 <- subset(torn, MONTH == 1 & DAY == 1 & NS != 1)
  if (nrow(dec31) > 0 & nrow(jan01) > 0) {
    stop("check! unique id assignment may not be accurate!")
  }
  torn$id <- paste(torn$YEAR, torn$MONTH, torn$OM, torn$NS, sep = "-")
  
  return (torn)
}

# function to summarize counts of tornadoes desired stats by year and month
spc_summary_counts <- function(in_df) {
  
  # number of unique tornadoes per month
  mon_totals <- ddply(.data = in_df, 
                      .variables = .(MONTH),
                      .fun = function(x_df) length(unique(x_df$id)), 
                      .drop = FALSE)
  
  # output matrix
  out_mat <- c(nrow(in_df), length(unique(in_df$id)), mon_totals$V1)
  out_mat <- matrix(out_mat, nrow = 1)
  colnames(out_mat) <- c("N_total", "N_unique", month.abb)  
  
  return (out_mat)
}
