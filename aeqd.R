# project lat-lon values to azimuthal equidistant projection
# to be consistent with Brooks et al 2003 who use a 80-km grid
# and then plot this grid along with state boundaries

# some useful links
# http://r-sig-geo.2731867.n2.nabble.com/Re-projecting-rasters-projectRaster-td5777721.html
# http://stackoverflow.com/questions/17214469/r-crop-raster-data-and-set-axis-limits
# http://stackoverflow.com/questions/10763421/r-creating-a-map-of-selected-canadian-provinces-and-u-s-states
# https://stat.ethz.ch/pipermail/r-sig-geo/2007-December/002939.html
# http://stackoverflow.com/questions/15634882/why-the-values-of-my-raster-map-change-when-i-project-it-to-a-new-crs-projectra
# http://www.nceas.ucsb.edu/scicomp/usecases/createrasterimagemosaic
# http://stackoverflow.com/questions/11891908/how-to-overlay-global-map-on-filled-contour-in-r-language

library(raster)
library(maptools)
library(rgdal)
library(maps)

# lat-lon bounds of the lower 48 states
lat_seq <- c(20, 50)
lon_seq <- c(-125, -65)
ll_df <- expand.grid(lat = lat_seq, lon = lon_seq, KEEP.OUT.ATTRS = TRUE)

# lat-lon and azimuthal equidistant projection info
ll_proj <- "+proj=longlat +datum=WGS84"
ae_proj <- "+proj=aeqd +lat_0=35 +lon_0=-95 +units=m"

# Function to project from geographic to aeqd. Input is a data frame and the name of the columns associated with lon and lat, and the input and output projection info for CRS.
Fn_Get_Projected_Locs <- function(in_df, lon_col, lat_col, in_proj, out_proj) {
  # create spatial data frame using sp library
  out_locs <- SpatialPointsDataFrame(coords = in_df[, c(lon_col, lat_col)], 
                                     data = in_df, 
                                     proj = CRS(in_proj))
  
  # project lat-lons to aeqd, using rgdal's sptransform
  out_locs <- spTransform(out_locs, CRS(out_proj))
  
  return (out_locs)
}

# Use above to identify the bounds of the 80-km grid and the coordinates.
ae_locs <- Fn_Get_Projected_Locs(ll_df, "lon", "lat", ll_proj, ae_proj)

# set the 80-km grid resolution and dimensions in aeqd
aegrid_res <- 80000 # raster resolution in meters 

aegrid_bounds <- apply(ae_locs@coords, 2, range)

aegrid_xcoords <- seq(aegrid_bounds[1, "lon"], aegrid_bounds[2, "lon"], aegrid_res)
aegrid_ycoords <- seq(aegrid_bounds[1, "lat"], aegrid_bounds[2, "lat"], aegrid_res)

aeX <- length(aegrid_xcoords)
aeY <- length(aegrid_ycoords)

# Function to compute the euclidean distance between 2 points
Fn_Compute_Distance <- function(y1, x1, y2, x2) {
  return (sqrt((y1 - y2)^2 + (x1 - x2)^2))
}

# matrices used in distance calcs
xindx_mat <- matrix(rep(c(1:aeX), aeY), nrow = aeY, byrow = TRUE)
yindx_mat <- matrix(rep(c(1:aeY), aeX), nrow = aeY, byrow = FALSE)

aegrid_res_km <- aegrid_res / 1000 # grid resolution in km

# calculate distance matrix
dist_mat <- aegrid_res_km * Fn_Compute_Distance(yindx_mat, xindx_mat, 1, 1)
# flip the matrix from S-N to N-S to counteract "raster" package behavior
dist_mat <- dist_mat[c(nrow(dist_mat):1), ]

usa_rast <- raster(dist_mat, 
                   xmn = min(aegrid_xcoords), 
                   xmx = max(aegrid_xcoords), 
                   ymn = min(aegrid_ycoords),
                   ymx = max(aegrid_ycoords), 
                   crs = ae_proj) 

# map of the lower 48 in aeqd
usa_map <- map("state", xlim = range(lon_seq), ylim = range(lat_seq), plot = FALSE)
usa_map <- map2SpatialLines(usa_map)
proj4string(usa_map) <- CRS(ll_proj)
usa_map <- spTransform(usa_map, CRS(ae_proj))


# output
png("aeqd_raster.png", width = ncol(usa_rast)*10, height = nrow(usa_rast)*10)
plot(usa_rast, axes = FALSE)
plot(usa_map, add = TRUE)
contour(usa_rast, add = TRUE, axes = FALSE)
garbage <- dev.off()

