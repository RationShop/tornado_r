# library of functions

library(plyr)

read_torn_data <- function() {
  # read raw data
  torn <- read.csv("data/1950-2012_torn.csv", 
                   header = FALSE, 
                   sep = ",", 
                   as.is = TRUE)
  
  # add column names, similar to documentation and 
  # same as those used by Elsner et al - http://rpubs.com/jelsner/4205
  # "A spatial point process model for violent tornado ...", 2013
  colnames(torn) <- c("OM", "YEAR", "MONTH", "DAY", "DATE", "TIME", "TIMEZONE", 
                      "STATE", "FIPS", "STATENUMBER", "FSCALE", "INJURIES", 
                      "FATALITIES", "LOSS", "CROPLOSS", "SLAT", "SLON", "ELAT", 
                      "ELON", "LENGTH", "WIDTH", "NS", "SN", "SG", "F1", "F2", 
                      "F3", "F4")
  
  # tornadoes spanning multiple counties are listed separately for each county
  # thus, a single tornado could appear multiple times
  # identify unique tornadoes - assume YEAR, OM and NS could uniquely identify
  # a tornado; 
  # check for the above assumption
  # tornadoes spanning multiple years (i.e, those which begin on 12/31 and 
  # end on 1/1); need to check only those with NS > 1
  dec31 <- subset(torn, MONTH == 12 & DAY == 31 & NS != 1)
  jan01 <- subset(torn, MONTH == 1 & DAY == 1 & NS != 1)
  if (nrow(dec31) > 0 & nrow(jan01) > 0) {
    stop("check! unique id assignment may not be accurate!")
  }
  torn$id <- paste(torn$YEAR, torn$MONTH, torn$OM, torn$NS, sep = "-")
  
#   # convert month to factor for use in summary stats
#   torn$MONTH <- as.factor(torn$MONTH)
  
  return (torn)
}

# function to summarize counts of unique number of tornadoes by year and month
count_unique_tornadoes <- function(in_df) {
  
  require(plyr)
  
  # some months dont have data; assign NAs to those months
  mon_totals <- expand.grid(MONTH = seq(1, 12), stringsAsFactors = FALSE)
  
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

# function to reproduce stats produced by Simmons et al 2013
rep_stats_Simmons <- function(torn) {
  
  require(plyr)
  
  stopifnot(exists("torn"))

  # remove SN = 0 since these are for the overall event when multiple
  # segments are present, see documentation
  # http://www.spc.noaa.gov/wcm/SPC_severe_database_description.pdf
  torn <- subset(torn, SN != 0)
  torn <- droplevels(torn)
  
  # time periods used by Simmons et al
  time_breaks <- c(1950, 1974, 2000, 2012, 2020)
  time_labels <- c("1950-73", "1974-99", "2000-11", "2012-")
  
  torn$time_cat <- cut(torn$YEAR, 
                       breaks = time_breaks, 
                       labels = time_labels,
                       include.lowest = TRUE,
                       right = FALSE)
  
  # summary stats used by Simmons et al - Table 3, damage by F-scale category
  # assign -9 F-scale to 0  
  torn$FSCALE[torn$FSCALE == -9] <- 0
  fscale_stats <- ddply(torn[, c("FSCALE", "time_cat")], .(FSCALE), table)
  
  # loss in dollars, current values
  # combine loss and croploss
  torn$tot_loss <- (torn$LOSS + torn$CROPLOSS) * 10^6
  
  # categorize loss using 1950-1995 bins (0 to 9)
  loss_breaks <- c(0, 5 * 10^(1:9))
  loss_labels <- paste0("Bin", (1:9))
  torn$loss_cat <- cut(torn$tot_loss, 
                       breaks = loss_breaks, 
                       labels = loss_labels,
                       include.lowest = TRUE,
                       right = FALSE)
  
  # summary stats used by Simmons et al. for each loss category bin
  simmons_events_summary <- function(in_df) {
        
    data.frame(N = nrow(in_df),
               Median = median(in_df$tot_loss) / 10^6,
               Mean = mean(in_df$tot_loss) / 10^6,
               Min = min(in_df$tot_loss) / 10^6,
               Max = max(in_df$tot_loss) / 10^6,
               SD = sd(in_df$tot_loss) / 10^6,
               stringsAsFactors = FALSE)
  }

  torn <- subset(torn, YEAR >= 1996 & YEAR <= 2011)
  event_stats <- ddply(.data = torn, 
                       .variables = .(loss_cat), 
                       .fun = simmons_events_summary)

#   # time periods used by Simmons et al
#   torn <- subset(torn, YEAR >= 1950 & YEAR <= 2011)
#   by(torn, INDICES = torn$FSCALE, FUN = function (x) length(unique(x$id)))
  
  return (list(event_stats = event_stats, fscale_stats = fscale_stats))
}

