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

**State level regulations

import excel using "$data\CondominiumLaws2016_03_02.xlsx", first sheet("States")

keep State Year* Rank*

rename State state_name
rename Year  st_reg_year1
rename Year2 st_reg_year2
rename Year3 st_reg_year3

rename Rank  st_rank1
rename Rank2 st_rank2
rename Rank3 st_rank3

**Temp drop

drop if state_name == "Missouri" & st_reg_year1 == .

joinby state_name using "$state\state_xwalk.dta", unmatched(master)
drop _merge 

rename official state

save ords_st, replace
clear

**City level regulations

import excel using "$data\CondominiumLaws2016_03_02.xlsx", first sheet("Cities")

keep Place - Rank4

split Place, parse(",")

rename Place1 city_name
rename Place2 state_name

replace city_name  = trim(city_name)
replace state_name = trim(state_name)

*joinby state_name using ords_st, unmatched(master)
*drop _merge
joinby state_name using "$state\state_xwalk.dta", unmatched(master)
drop _merge

rename official state

gsort -Pop

gen city_rank = _n

save ords_full, replace

keep Place Pop Date1 Rank1

forvalues y = 1970(10)2010 {

gen regd`y' = 0
gen regm`y' = 0
 
replace regd`y' = 1     if Date1 < `y' & Rank1 > 0
replace regm`y' = Rank1 if Date1 < `y'

}
 
reshape clear
reshape i Place Pop
reshape j year
reshape xij regd regm
reshape long

split Place, gen(geo) parse(",")

replace geo1 = trim(geo1)
replace geo2 = trim(geo2)

rename geo1 city
rename geo2 state

export excel using "condos_fortableau.xls", replace first(var)

clear



/*

xx

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
