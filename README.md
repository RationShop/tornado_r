The Tornado Project
=============

Goal
-----------
Bring consistency and transparency to the analyses of publicly available Tornado datasets using an R-based open source analysis.

Issues
-----------
Tornado data available from the NOAA [Storm Prediction Center](http://www.spc.noaa.gov/gis/svrgis/) and other government agencies around the world has been the focus of many studies (e.g., see below references). However, there are a number of issues with these studies:
* The data itself is changing - both in quantity (additional data added every season) and quality (quality control measures appear to have been applied in the recent past, particularly to the data prior to the 1990s). Hence, it is not possible to exactly, or sometimes even approximately, reproduce the results of these studies.
* Since the data size is annually changing, it makes more sense to have the analyses revised annually as well. 
* With the exception of a few (thanks to R user Prof. James Elsner and colleagues), none of the studies provide the code used in their analysis. Moreover, one of the recent studies (Simmons et al 2013) appears to have several errors.
* Data prior to 1950 in the United States appears to be available only on microfilm. Hopefully, through or due to this effort, some day this data becomes more widely available.

Specific Objectives:
-----------
1. Create an R package 
 * The package would come with raw and cleaned Tornado data
2. Functionality provided by the R package would include:
 * reproduction/replication of summary statistics presented by literature studies. 
 * adjustment of historical monetary losses for inflation and other factors, based on literature.
 * creation of stochastic and probabilistic models of Tornado hazard, based on literature.
3. Extend the above to Tornado data from other parts of the world.


References
-----------
* NOAA Storm Prediction Center (SPC)
  * Main page - http://www.spc.noaa.gov/gis/svrgis/
  * Summary statistics 1950-99 - http://www.spc.noaa.gov/archive/tornadoes/ustdbmy.html
  * Summary statistics 2000-present - http://www.spc.noaa.gov/climo/online/monthly/newm.html
* Simmons, Sutter & Pielke, 2013, "Normalized tornado damage in the United States: 1950 - 2011", Environmental Hazards, 12(2), pp. 132-147.
* Elsner, Murnane, Jagger & Widen, 2013, "A spatial point process model for violent tornado occurrence in the U.S. Great Plains", Mathematical Geosciences, 45(6), pp. 667-679. Code available at - http://rpubs.com/jelsner/4205
* Verbout, Brooks, Leslie, & Schultz, 2006, "Evolution of the U.S. Tornado Database: 1954-2003", Weather and Forecasting, pp. 86-93.
* Boruff, Easoz, Jones, Landry, Mitchem & Cutter, 2003, "Tornado hazards in the United States", Climate Research, 24, pp. 103-117.
* Brooks & Doswell, 2001, "Some aspects of the international climatology of tornadoes by damage classification", Atmospheric Research, 56, pp. 191-201.
* Grazulis, 1993, "A 110-Year Perspective of Significant Tornadoes", The Tornado: Its Structure, Dynamics, Prediction, and Hazards, Geophysical Monograph 79, pp. 467-474.

