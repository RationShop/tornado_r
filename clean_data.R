# read and clean tornado data

# read raw data
torn <- read.csv("data/1950-2012_torn.csv", header = FALSE, sep = ",", as.is = TRUE)
# add column names based on documentation
colnames(torn) <- c("OM", "YEAR", "MONTH", "DAY", "DATE", "TIME", "TIMEZONE", 
                    "STATE", "FIPS", "STATENUMBER", "FSCALE", "INJURIES", 
                    "FATALITIES", "LOSS", "CROPLOSS", "SLAT", "SLON", "ELAT", 
                    "ELON", "LENGTH", "WIDTH", "NS", "SN", "SG", "F1", "F2", 
                    "F3", "F4")


# create unique id based on YEAR, OM and NS
# check existence of tornadoes which span multiple years (from 12/31 into 1/1)
# need to check only those with NS > 1
dec31 <- subset(torn, MONTH == 12 & DAY == 31 & NS != 1)
jan01 <- subset(torn, MONTH == 1 & DAY == 1 & NS != 1)

torn$id <- paste(torn$YEAR, torn$OM, torn$NS, sep = "-")

# split data similar to Simmons et al 2013
# data from 1950 - 1995
torn_old <- subset(torn, YEAR <= 1995)
# data from 1996 - 2011
torn_new <- subset(torn, YEAR >= 1996 & YEAR <= 2011)

counts_loss_old <- by(torn_old, 
                      INDICES = torn_old$LOSS, 
                      FUN = function (x) length(unique(x$id)))
counts_loss_old <- as.data.frame(as.table(counts_loss_old), stringsAsFactors = FALSE)
colnames(counts_loss_old) <- c("Loss_Category", "Count")

torn_old_8 <- subset(torn_old, LOSS == 8)


# data used by Simmons et al 2013
torn_simm <- subset(torn, YEAR >= 1950 & YEAR <= 2011)
by(torn_simm, INDICES = torn_simm$FSCALE, FUN = function (x) length(unique(x$id)))
torn_simm <- subset(torn, YEAR >= 1950 & YEAR <= 1973)
by(torn_simm, INDICES = torn_simm$FSCALE, FUN = function (x) length(unique(x$id)))
torn_simm <- subset(torn, YEAR >= 1974 & YEAR <= 1999)
by(torn_simm, INDICES = torn_simm$FSCALE, FUN = function (x) length(unique(x$id)))
torn_simm <- subset(torn, YEAR >= 2000 & YEAR <= 2011)
by(torn_simm, INDICES = torn_simm$FSCALE, FUN = function (x) length(unique(x$id)))

