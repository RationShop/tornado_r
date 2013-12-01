# attempt to reproduce Simmons et al 2013 results

source("lib_torn.R")

# data used by Simmons et al, from 1996-2011
torn <- subset(torn, YEAR >= 1996 & YEAR <= 2011)

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
simm_summary <- function(in_df, exclude_repeats = FALSE) {
  
  # depending on SN being 0 or 1, see documentation
  # http://www.spc.noaa.gov/wcm/SPC_severe_database_description.pdf
  if (exclude_repeats) {
    in_df <- subset(in_df, SN == 1)
    in_df <- droplevels(in_df)
  }
  
  data.frame(N = nrow(in_df),
             Median = median(in_df$tot_loss) / 10^6,
             Mean = mean(in_df$tot_loss) / 10^6,
             Min = min(in_df$tot_loss) / 10^6,
             Max = max(in_df$tot_loss) / 10^6,
             SD = sd(in_df$tot_loss) / 10^6,
             stringsAsFactors = FALSE)
}

out_stats <- do.call("rbind", by(torn, 
                                 INDICES = torn$loss_cat, 
                                 FUN = simm_summary))
out_stats


out_stats <- do.call("rbind", by(torn, 
                                 INDICES = torn$loss_cat, 
                                 FUN = simm_summary,
                                 exclude_repeats = TRUE))
out_stats


# data used by Simmons et al 2013, for 1950-2011
torn <- subset(torn, YEAR >= 1950 & YEAR <= 2011)
by(torn, INDICES = torn$FSCALE, FUN = function (x) length(unique(x$id)))
torn <- subset(torn, YEAR >= 1950 & YEAR <= 1973)
by(torn, INDICES = torn$FSCALE, FUN = function (x) length(unique(x$id)))
torn <- subset(torn, YEAR >= 1974 & YEAR <= 1999)
by(torn, INDICES = torn$FSCALE, FUN = function (x) length(unique(x$id)))
torn <- subset(torn, YEAR >= 2000 & YEAR <= 2011)
by(torn, INDICES = torn$FSCALE, FUN = function (x) length(unique(x$id)))

