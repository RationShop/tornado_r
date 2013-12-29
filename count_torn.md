The Tornado Project: Counting Tornadoes
========================================================

A number of studies have analyzed the Tornado data available from the NOAA [Storm Prediction Center](http://www.spc.noaa.gov/gis/svrgis/). Below is an attempt to reproduce the statistics presented by the Storm Prediction Center and three other studies in the recent literature.

First, load the required libraries and read the data.


```r
source("lib_torn.R")

torn <- read_torn_data()
```


Reproduce stats from SPC. Tornadoes by year and month since 1950 and also number of fatalities and injuries. Compare below numbers with [stats from SPC](http://www.spc.noaa.gov/archive/tornadoes/ustdbmy.html). For most of the years and months, the numbers below exactly match those from SPC.


```r
out_spc <- rep_stats_SPC(torn)
lapply(out_spc, head)
```

```
## $event_stats
##   YEAR N_total N_unique Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
## 1 1950     206      201   7  20  21  15  61  28  23  13   3   2   4   4
## 2 1951     261      260   2  10   6  26  57  76  23  27   9   2  12  10
## 3 1952     246      240  12  27  43  37  34  34  27  16   1  NA   6   3
## 4 1953     443      422  14  16  40  47  94 111  32  24   5   6  12  21
## 5 1954     570      550   2  17  62 113 101 107  45  49  21  14   2  17
## 6 1955     606      593   3   4  43  99 148 153  49  33  15  23  20   3
## 
## $fat_stats
##   YEAR FATALITIES INJURIES
## 1 1950         70      659
## 2 1951         34      524
## 3 1952        230     1915
## 4 1953        523     5131
## 5 1954         36      715
## 6 1955        129      926
```

```r

lapply(out_spc, tail)
```

```
## $event_stats
##    YEAR N_total N_unique Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
## 58 2007    1117     1098  21  52 170 167 252 128  69  75  52  86   7  19
## 59 2008    1739     1692  84 147 129 189 462 292  95 101 111  21  15  46
## 60 2009    1182     1156   6  36 115 226 201 270 118  60   8  65   3  48
## 61 2010    1315     1280  30   1  33 139 305 321 146  55  57 108  53  32
## 62 2011    1777     1692  16  63  75 758 326 160 101  57  51  23  47  15
## 63 2012     957      940  79  57 155 206 121 111  37  38  39  37   7  53
## 
## $fat_stats
##    YEAR FATALITIES INJURIES
## 58 2007         81      617
## 59 2008        126     1703
## 60 2009         22      350
## 61 2010         45      701
## 62 2011        553     5483
## 63 2012         70      822
```


Reproduce stats from Boruff et al 2003. Compare below with Table 1 and 2 from Boruff et al. Although not an exact match, the numbers below are pretty close to those from Boruff et al.


```r
out_boruff <- rep_stats_Boruff(torn)
lapply(out_boruff, head)
```

```
## $event_stats
##   time_cat N_total N_unique
## 1    1950s    4791     4791
## 2    1960s    6801     6801
## 3    1970s    8568     8568
## 4    1980s    8185     8185
## 5    1990s   12132    12132
## 
## $fat_stats
##   time_cat FATALITIES INJURIES
## 1    1950s       1421    14423
## 2    1960s        942    17258
## 3    1970s        998    21621
## 4    1980s        522    11297
## 5    1990s        581    11756
```


Reproduce stats from Verbout et al 2006. Compare below with numbers from Figure 1 of Verbout et al 2006. Below numbers match well with those in Figure 1 of Verbout (visual comparison) and those described in the first paragraph of Page 88 of Verbout et al.


```r
out_verbout <- rep_stats_Verbout(torn)
head(out_verbout, 10)
```

```
##    YEAR events_all F1+ F2+ F3+ F4+
## 1  1950        201 182  99  31   7
## 2  1951        260 196 108  27   5
## 3  1952        240 204 124  52  18
## 4  1953        422 337 193  59  22
## 5  1954        550 439 233  46   7
## 6  1955        593 402 202  39  10
## 7  1956        504 368 198  51  13
## 8  1957        858 600 331  98  26
## 9  1958        564 383 185  40   5
## 10 1959        604 415 193  41   7
```

```r
tail(out_verbout, 10)
```

```
##    YEAR events_all F1+ F2+ F3+ F4+
## 54 2003       1374 483 128  35   8
## 55 2004       1817 601 131  28   5
## 56 2005       1263 448 105  21   1
## 57 2006       1103 417 125  32   2
## 58 2007       1098 424 125  32   5
## 59 2008       1692 708 210  59  10
## 60 2009       1156 454 106  22   2
## 61 2010       1280 511 170  45  13
## 62 2011       1692 897 280  84  23
## 63 2012        940 364 123  28   4
```


Reproduce stats from Simmons et al 2013. Compare below with Table 2 and Table 3 from Simmons et al 2013. Most likely, Simmons et al in Table 2 have made an error. I am not sure how the tornadoes were countd. Moreover, the "Max" values in Table 2 cannot be greater than the upper bounds on damage of each of the bins (see Table 1 of Simmons et al for damage bin intervals).


```r
out_simmons <- rep_stats_Simmons(torn)
options(scipen = 10)
lapply(out_simmons, head, 9)
```

```
## $event_stats
##   loss_cat     N    Median        Mean      Min       Max         SD
## 1     Bin1 10472    0.0000    0.000000   0.0000    0.0000   0.000000
## 2     Bin2     1    0.0004    0.000400   0.0004    0.0004         NA
## 3     Bin3   952    0.0020    0.001867   0.0005    0.0040   0.000958
## 4     Bin4  3672    0.0110    0.018315   0.0050    0.0480   0.010737
## 5     Bin5  3902    0.1000    0.145521   0.0500    0.4800   0.098500
## 6     Bin6  1533    1.0000    1.332635   0.5000    4.9500   0.973337
## 7     Bin7   365   10.0000   13.776142   5.0000   47.8000  10.138180
## 8     Bin8    76   94.0000  113.979842  50.0000  373.5550  74.363395
## 9     Bin9     7 1000.0000 1286.288571 500.0100 2800.1000 888.521656
## 
## $fscale_stats
##   FSCALE 1950-73 1974-99 2000-11 2012-
## 1      0    4196   12643    9745   577
## 2      1    5374    8587    4389   241
## 3      2    4181    3239    1270    98
## 4      3    1055     945     377    27
## 5      4     269     243      80     4
## 6      5      32      28       8     0
```


