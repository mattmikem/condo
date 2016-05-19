********************************************
*Build Boundary .dta file
*M. Miller, 15F
********************************************

cd "L:\Research\Resurgence\Working Files\Boundary"

capture log close

clear
clear matrix
clear mata

set more off

set maxvar 30000

**Set macro variables

global min_d = 200
global max_d = 3000
global step  = 200
global N     = 100

forvalues c = 0/$N {

forvalues d = $min_d($step)$max_d {

shp2dta using "boundary_tracts_`d'_`c'.shp", database(bt_`d'_`c') coordinates(bt_xy_`c') replace

disp "Round: `c' - `d'" 

use bt_`d'_`c', clear

keep GEOID STATEFP _ID 
gen bound_`d' = 1
gen ua = `c'

if `c' == 0 {
save bound_`d', replace
}

else {

append using bound_`d'
save bound_`d', replace

}

}

}

**Check tracts count increasing in `d'

local ntract = 0

forvalues d = $min_d($step)$max_d {
use bound_`d', clear
quietly sum _ID
disp r(N)
if `ntract' > r(N) {
disp "TRACT COUNT FUNKY! DOUBLE CHECK"
xx
}
local ntract = r(N)
}
disp "TRACT COUNT BUENO!"

**Merge into one large file

use bound_$max_d, clear

global max_m1 = $max_d - $step

forvalues d = $min_d($step)$max_m1 {
joinby GEOID using bound_`d', unmatched(master)
drop _merge

}

order STATE _ID GEO ua (bound_$min_d - bound_$max_m1) bound_$max_d
destring GEOID, gen(geo2010)
keep geo2010 bound*

save bound, replace


