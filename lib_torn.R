# library of functions

library(plyr)

read_torn_data <- function() {
  # read raw data
  torn <- read.csv("data/1950-2012_torn.csv", 
                   header = FALSE, 
                   sep = ",", 
                   as.is = TRUE)
  
  # add column names, similar to documentation and 
  # same as those used by Elsner et al - 
  colnames(torn) <- c("OM", "YEAR", "MONTH", "DAY", "DATE", "TIME", "TIMEZONE", 
                      "STATE", "FIPS", "STATENUMBER", "FSCALE", "INJURIES", 
                      "FATALITIES", "LOSS", "CROPLOSS", "SLAT", "SLON", "ELAT", 
                      "ELON", "LENGTH", "WIDTH", "NS", "SN", "SG", "F1", "F2", 
                      "F3", "F4")
  
  # a tornado spanning multiple counties is listed separately for each county
  # thus, a single tornado could appear multiple times
  # identify unique tornadoes based on YEAR, OM and NS
  # check for existence of tornadoes spanning multiple years (i.e, those which
  # begin on 12/31 and end on 1/1); need to check only those with NS > 1
  dec31 <- subset(torn, MONTH == 12 & DAY == 31 & NS != 1)
  jan01 <- subset(torn, MONTH == 1 & DAY == 1 & NS != 1)
  if (nrow(dec31) > 0 & nrow(jan01) > 0) {
    stop("check! unique id assignment may not be accurate!")
  }
  torn$id <- paste(torn$YEAR, torn$MONTH, torn$OM, torn$NS, sep = "-")
  
  # convert month to factor for use in summary stats
  torn$MONTH <- as.factor(torn$MONTH)
  
  return (torn)
}

# function to summarize counts of unique number of tornadoes by year and month
count_unique_tornadoes <- function(in_df) {
  
  require(plyr)
  
  # some months dont have data; assign NAs to those months
  mon_totals <- expand.grid(MONTH = seq(1,12), Count = NA, stringsAsFactors = FALSE)
  
  # number of unique tornadoes per month
  mon_torn <- ddply(.data = in_df, 
                    .variables = .(MONTH),
                    .fun = function(x_df) length(unique(x_df$id)), 
                    .drop = FALSE)
  
  mon_totals <- merge(mon_totals, mon_torn, by = "MONTH", all = TRUE)
  
  # output matrix
  out_mat <- c(nrow(in_df), length(unique(in_df$id)), mon_totals$V1)
  out_mat <- matrix(out_mat, nrow = 1)
  colnames(out_mat) <- c("N_total", "N_unique", month.abb)  
  
  return (out_mat)
}


# function to reproduce stats produced by SPC
rep_stats_SPC <- function(torn) {
  require(plyr)
  
  stopifnot(exists("torn"))
  
  # compare with http://www.spc.noaa.gov/archive/tornadoes/ustdbmy.html
  event_stats <- ddply(.data = torn, 
                       .variables = .(YEAR), 
                       .fun = count_unique_tornadoes)

  # compare with http://www.spc.noaa.gov/archive/tornadoes/ustdbmy.html
  # tornado segments could each have different fatalities and injuries
  # the data row corresp to the overall event has the max fatalities/injuries
  torn_fat <- aggregate(cbind(FATALITIES, INJURIES) ~ id, data = torn, FUN = max)
  torn_fat$YEAR <- as.numeric(substr(torn_fat$id, 1, 4))
  
  # aggregate by year and month
  fat_stats <- aggregate(cbind(FATALITIES, INJURIES) ~ YEAR, 
                         data = torn_fat, 
                         FUN = sum)
  
  return (list(event_stats = event_stats, fat_stats = fat_stats))
}

# function to reproduce stats produced by Boruff et al 2003
rep_stats_Boruff <- function(torn) {
  require(plyr)
  
  stopifnot(exists("torn"))
  
  # time period used by Boruff et al
  torn <- subset(torn, YEAR %in% seq(1950, 1999))
  # some states excluded by Boruff et al
  torn <- subset(torn, !(STATE %in% c("AK", "HI", "PR")))
  
  # summary on injuries and fatalities
  torn_fat <- aggregate(cbind(FATALITIES, INJURIES) ~ id, data = torn, FUN = max)
  torn_fat$YEAR <- as.numeric(substr(torn_fat$id, 1, 4))
  torn_fat$MONTH <- as.numeric(substr(torn_fat$id, 6, 6))
  
  # decades used by Boruff et al.
  time_breaks <- c(1950, 1960, 1970, 1980, 1990, 2000, 2010, 2020)
  time_labels <- c("1950s", "1960s", "1970s", "1980s", "1990s", "2000s","2010s")
  
  torn_fat$time_cat <- cut(torn_fat$YEAR, 
                           breaks = time_breaks, 
                           labels = time_labels,
                           include.lowest = TRUE,
                           right = FALSE)
  
  fat_stats <- aggregate(cbind(FATALITIES, INJURIES) ~ time_cat, 
                         data = torn_fat, 
                         FUN = sum)
  
  # summary on counts of tornadoes
  event_stats <- ddply(.data = torn_fat, 
                       .variables = .(time_cat), 
                       .fun = count_unique_tornadoes)
  
  return (list(event_stats = event_stats, fat_stats = fat_stats))
}

