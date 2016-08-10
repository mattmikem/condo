****************************************************
*DD/IV Framework for Analysis in City Center
*Looking at Birth Cohorts
*M. Miller, 16X
*****************************************************

cd "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"

capture log close

clear
clear matrix
clear mata

set more off

set maxvar 30000

global data  = "L:\Research\Condos\Data"
global work  = "L:\Research\Condos\Working Data"
global out   = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Output\07-18-2016"
global pro   = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Programs"
global cc    = "L:\Research\Resurgence\Working Files"

global thr_u = 100
global thr_l = 0
global N = $thr_u
quietly do "$pro\for_dd_iv_build.do"

***OBS LEVEL STABLE

use "$cc\city_centers.dta"

destring geo2010, replace

keep ua_code geo2010 cc_*

sort geo2010 ua_code

duplicates drop geo2010, force

save cc, replace

use "$work\condo_full.dta"

joinby geo2010 using cc, unmatched(master)

gen ed_inc = educ_b/lminc

drop if ed_inc > 0.085 | (educ_b == 1 & minc == 0)

collapse (mean) age*, by(year cc_1)

*egen bc_1945mi = rowtotal(bc_1905 bc_1915 bc_1925 bc_1935 bc_1945)
*egen bc_1965mi = rowtotal(bc_1955 bc_1965)
*egen bc_1985mi = rowtotal(bc_1975 bc_1985)
*egen bc_2005mi = rowtotal(bc_1995 bc_2005)

graph bar age25_35 age35_65 age65pl if cc_1 == 1, over(year) stack
  
