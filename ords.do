********************************************
*Condo Regulation Build
*M. Miller, 15F
********************************************

*cd "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"
cd "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"

capture log close

clear
clear matrix
clear mata

set more off

set maxvar 30000

global data  "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos"
global state "L:\Research\Resurgence\GIS\Geography"

import excel using "$data\CondoOrds.xlsx", first
xx
*For now, just keep city name and local ordinance ranking (use state ones from before).

**Later on may want to incorporate the date variable.

keep Place LocalOrd Date

destring Date, gen(reg_year) force

drop Date

global v_N = 51

replace LocalOrd = 0 if _n < $v_N & LocalOrd == .

gen state_name = trim(subinstr(substr(Place, strpos(Place,",")+1, length(Place)-1), "\3", "", 1))
gen city_name  = trim(substr(Place, 1, strpos(Place, ",")-1))

replace state_name = "Indiana" if strpos(state_name, "Indiana") != 0

joinby state_name using "$state\state_xwalk.dta", unmatched(master)

drop _merge

rename official state

save ords, replace
