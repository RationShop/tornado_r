# analyze data from SPC to match statistics produced by SPC

source("lib_torn.R")

torn <- read_torn_data()

# stats required by year and month; convert to factors
torn$YEAR <- as.factor(torn$YEAR)
torn$MONTH <- as.factor(torn$MONTH)

# compare with data from http://www.spc.noaa.gov/archive/tornadoes/ustdbmy.html
out_stats <- ddply(.data = torn, .variables = .(YEAR), .fun = spc_summary_counts)
out_stats

torn_fat <- aggregate(cbind(FATALITIES, INJURIES) ~ id, data = torn, FUN = max)
torn_fat$YEAR <- as.numeric(substr(torn_fat$id, 1, 4))

aggregate(cbind(FATALITIES, INJURIES) ~ YEAR, data = torn_fat, FUN = sum)

1421 + 942 + 998 + 522 + 581
