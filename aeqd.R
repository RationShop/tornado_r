# project lat-lon values to azimuthal equidistant projection
# to be consistent with Brooks et al 2003 who use a 80-km grid

# http://r-sig-geo.2731867.n2.nabble.com/Re-projecting-rasters-projectRaster-td5777721.html

# http://stackoverflow.com/questions/17214469/r-crop-raster-data-and-set-axis-limits

# http://stackoverflow.com/questions/10763421/r-creating-a-map-of-selected-canadian-provinces-and-u-s-states

# from https://stat.ethz.ch/pipermail/r-sig-geo/2007-December/002939.html

# http://stackoverflow.com/questions/15634882/why-the-values-of-my-raster-map-change-when-i-project-it-to-a-new-crs-projectra

# http://www.nceas.ucsb.edu/scicomp/usecases/createrasterimagemosaic

library(raster)
library(maptools)
library(rgdal)
library(maps)

# usa raster in aeqd
lat_breaks <- seq(25, 50, 5)
lon_breaks <- seq(-125, -65, 5)
ll_mat <- expand.grid(lat = lat_breaks, lon = lon_breaks, KEEP.OUT.ATTRS = TRUE)
ll_mat$val <- sample(1:nrow(ll_mat), size = nrow(ll_mat), replace = FALSE)

ll_proj <- "+proj=longlat +datum=WGS84"
new_proj <- "+proj=aeqd +lat_0=40 +lon_0=-95 +units=m"

usa_points <- SpatialPointsDataFrame(coords = ll_mat[, c("lon", "lat")], 
                            data = ll_mat, 
                            proj = CRS(ll_proj))

# project lat-lons of points to aeqd 
usa_points <- spTransform(usa_points, CRS(new_proj))

# create raster in aeqd
cell_res <- 80000 # 80 km 
new_bounds <- apply(usa_points@coords, 2, range)
x_breaks <- seq(new_bounds[1, "lon"], new_bounds[2, "lon"], cell_res)
y_breaks <- seq(new_bounds[1, "lat"], new_bounds[2, "lat"], cell_res)

usa_rast <- raster(matrix(1:(length(x_breaks)*length(y_breaks)), nrow = length(y_breaks)), 
                   xmn = min(x_breaks), 
                   xmx = max(x_breaks), 
                   ymn = min(y_breaks),
                   ymx = max(y_breaks), 
                   crs = new_proj) 

# map of the lower 48 in aeqd
usa_map <- map("state", xlim = range(lon_breaks), ylim = range(lat_breaks), plot = FALSE)
usa_map <- map2SpatialLines(usa_map)
proj4string(usa_map) <- CRS(ll_proj)
usa_map <- spTransform(usa_map, CRS(new_proj))

# output
png("xyz.png")
plot(usa_rast, axes = FALSE, bty = "n", fg = "white")
plot(usa_map, add = TRUE)
contour(usa_rast, add = TRUE)
garbage <- dev.off()

