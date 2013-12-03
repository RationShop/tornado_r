# estimate stats from literature on tornado analysis

source("lib_torn.R")

torn <- read_torn_data()

# reproduce stats produced by SPC
out_spc <- rep_stats_SPC(torn)

# reproduce stats produced by Boruff et al. 2003
out_boruff <- rep_stats_Boruff(torn)

# reproduce stats produced by Simmons et al 2013
out_simmons <- rep_stats_Simmons(torn)

# reproduce stats produced by Verbout et al 2006
out_verbout <- rep_stats_Verbout(torn)
