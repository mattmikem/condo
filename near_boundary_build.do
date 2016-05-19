********************************************
*Build (near) Boundary .dta file
*M. Miller, 16W
********************************************

cd "L:\Research\Resurgence\GIS\Working Files\Output\Test"

global bound "L:\Research\Resurgence\Working Files\Near Boundary"

capture log close

clear
clear matrix
clear mata

set more off

set maxvar 30000

global N = 100

forvalues c = 0/$N {

shp2dta using "ua_lehd_acs_`c'.shp", database("$bound\bt_`c'.dta") coordinates("$bound\bt_xy_`c'.dta") replace

disp "Round: `c'" 

use "$bound\bt_`c'.dta", clear

keep GEOID STATEFP NEAR_DIST 
*gen bound_`d' = 1
gen ua = `c'

if `c' == 0 {
save "$bound\bound.dta", replace
}

else {

append using "$bound\bound.dta"
save "$bound\bound.dta", replace

}

}

drop if NEAR_DIST == -1

rename GEOID geo2010
rename NEAR_DIST bound_dist

destring geo2010, replace
**Need to clean a bit based on unanticipatd city-state combinations.

bysort geo2010: gen id = _N

sort geo2010 bound_dist

duplicates drop geo2010, force

keep geo2010 bound_dist

save "$bound\bound.dta", replace

