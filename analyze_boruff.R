# compare with Boruff et al, 2003, Tornado Hazards in the US, Climate Research

source("lib_torn.R")

torn <- read_torn_data()

torn <- subset(torn, YEAR %in% seq(1950, 1999))
torn <- droplevels(torn)
# some states excluded by Boruff et al
torn <- subset(torn, !(STATE %in% c("AK", "HI", "PR")))
# levels(as.factor(torn$STATE))

# stats required by year and month; convert to factors
torn$YEAR <- as.factor(torn$YEAR)
torn$MONTH <- as.factor(torn$MONTH)

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
aggregate(cbind(FATALITIES, INJURIES) ~ time_cat, data = torn_fat, FUN = sum)

ddply(.data = torn_fat, .variables = .(time_cat), .fun = spc_summary_counts)
