# 

source("lib_torn.R")

torn <- read_torn_data()

# analyze data from SPC to match statistics produced by SPC
out_spc <- rep_stats_SPC(torn)

# 
out_boruff <- rep_stats_Boruff(torn)

