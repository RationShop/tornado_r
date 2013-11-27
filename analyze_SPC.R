# analyze data from SPC to match statistics produced by SPC

library(plyr)

#-------------------------------------------------------------------------------
# read raw data
torn <- read.csv("data/1950-2012_torn.csv", header = FALSE, sep = ",", as.is = TRUE)

# add column names based on documentation
colnames(torn) <- c("OM", "YEAR", "MONTH", "DAY", "DATE", "TIME", "TIMEZONE", 
                    "STATE", "FIPS", "STATENUMBER", "FSCALE", "INJURIES", 
                    "FATALITIES", "LOSS", "CROPLOSS", "SLAT", "SLON", "ELAT", 
                    "ELON", "LENGTH", "WIDTH", "NS", "SN", "SG", "F1", "F2", 
                    "F3", "F4")

# stats required by year and month; convert to factors
torn$YEAR <- as.factor(torn$YEAR)
torn$MONTH <- as.factor(torn$MONTH)

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
torn$id <- paste(torn$YEAR, torn$OM, torn$NS, sep = "-")


#-------------------------------------------------------------------------------
# checks to ensure above id assignment process is valid

# function to summarize desired stats by year and month
spc_summary <- function(in_df) {
  
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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# compare with data from http://www.spc.noaa.gov/archive/tornadoes/ustdbmy.html
out_stats <- ddply(.data = torn, .variables = .(YEAR), .fun = spc_summary)
out_stats

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# compare with Boruff et al, 2003, Tornado Hazards in the US, Climate Research
torn_boruff <- subset(torn, YEAR %in% seq(1950, 1999))
torn_boruff <- droplevels(torn_boruff)
# some states excluded by Boruff et al
torn_boruff <- subset(torn_boruff, !(STATE %in% c("AK", "HI", "PR")))
# levels(as.factor(torn_boruff$STATE))

# decades used by Boruff et al.
time_breaks <- c(1950, 1960, 1970, 1980, 1990, 2000)
time_labels <- c("1950s", "1960s", "1970s", "1980s", "1990s")
# convert factor to numeric for numeric data
Fn_Factor_To_Numeric <- function(in_fac) {
  return (as.numeric(levels(in_fac))[in_fac])
}
torn_boruff$time_cat <- cut(Fn_Factor_To_Numeric(torn_boruff$YEAR), 
                            breaks = time_breaks, 
                            labels = time_labels,
                            include.lowest = TRUE,
                            right = FALSE)

out_stats <- ddply(.data = torn_boruff, .variables = .(time_cat), .fun = spc_summary)
out_stats
