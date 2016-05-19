********************************************
*Condo Preliminary
*M. Miller, 15S
********************************************

cd "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"

capture log close

clear
clear matrix
clear mata

set more off

set maxvar 30000

global data  = "C:\Users\Matthew\Desktop\ECON\Research\Urban\Papers\Condos\Data"
global hud   = "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Condos\HUD_data"
global wha   = "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Condos\Wharton_data"
global work  = "C:\Users\Matthew\Desktop\ECON\Research\Urban\Papers\Condos\Working"
global out   = "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Output"

**HUD
/*
insheet using "$hud\hud_dataset.txt"

save hud, replace

**Wharton Data

use wharton_tomerge, clear

keep type pressure loczoning mfudensrestr affordable mfusupply time1_mfu LZAI DRI SRI WRLURI metaread

save wh_condo, replace

**IPUMS

use "$data\ipums_condo"

drop if unitsstr < 3

joinby metaread using hud, unmatched(master)

drop _merge

joinby metaread using conversions_dataset_02, unmatched(master)

drop _merge

joinby metaread using wh_condo, unmatched(master)

drop _merge

save condo_build, replace

*/

use "$work\condo_build", replace

**Policy assoc with Condo (HUD variables)

*w is set of Wharton based potential instruments
*z is set of HUD/legislation based potential instruments

global z = "right_fr notice_convert app_assist_lowinc"
global w = "pressure loczoning mfudensrestr affordable mfusupply time1_mfu"
global x = "i.unitsstr i.builtyr bedrooms"

*Start full population all years

quietly log using "condo_work.log", replace

*All Years (1970-2010)

reg condo_all $z $x, cluster(metaread)
reg condo_all $z $x if ownershp == 1, cluster(metaread)
reg condo_all $z $x if unitsstr > 3, cluster(metaread)


quietly forvalues y = 1970(10)2000 {

disp `y'

reg condo_all $z $x if year == `y', cluster(metaread)
reg condo_all $z $x if year == `y' & ownershp == 1, cluster(metaread)
reg condo_all $z $x if year == `y' & unitsstr > 3, cluster(metaread)

}


**Central City

*All Years

reg condo_all $z $x if metro == 2, cluster(metaread)

*1980

reg condo_all $z $x if year == 1980 & metro == 2, cluster(metaread)

*2000

reg condo_all $z $x if year == 2000 & metro == 2, cluster(metaread)


**Regressions testing Wharton Indices
* Note, not sure of the timing for all of these regulations, for assigning
* across all years. All variables are categorical as well, need to re-code

corr $z $w LZAI WRLURI DRI SRI

*All Years (1970-2010)

reg condo_all pressure loczoning mfudensrestr affordable mfusupply time1_mfu $z $x, cluster(metaread)

**Factor analysis based indices less relevant

*reg condo_all LZAI DRI SRI $z $x, cluster(metaread)
*reg condo_all WRLURI $z $x, cluster(metaread)

reg condo_all $w $z $x if ownershp == 1, cluster(metaread)
reg condo_all $w $z $x if unitsstr > 3, cluster(metaread)
reg condo_all $w $z $x if metro == 2, cluster(metaread)

forvalues y = 1970(10)2000 {

disp `y'

reg condo_all $w $z $x if year == `y', cluster(metaread)
reg condo_all $w $z $x if year == `y' & ownershp == 1, cluster(metaread)
reg condo_all $w $z $x if year == `y' & unitsstr > 3, cluster(metaread)

}


reg condo_all $w $z $x if year == 1980 & metro == 2, cluster(metaread)
reg condo_all $w $z $x if year == 2000 & metro == 2, cluster(metaread)
