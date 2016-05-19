clear

*cd "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"
cd "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"

*import excel using "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working\Census Places 2010.xlsx", firstrow sheet("places")
import excel using "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Geography\Census Places 2010.xlsx", firstrow sheet("places")
drop if STATE == ""
gen city = 0
replace city = 1 if strpos(PLACENAME, " city") != 0
gen     name = subinstr(PLACENAME, " town", "",.)
replace name = subinstr(PLACENAME, " city", "", .)

keep if city == 1

replace name = trim(name)
replace STATE = trim(STATE)

rename name	city_name
rename STATE state

*Use list from IPUMS

*joinby city_name state using cen_city_names, unmatched(master)

*Use full list of MSAs

joinby city_name state using cen_city_full, unmatched(master)

drop _merge

replace cc_status = 0 if cc_status == .

tostring PLACEFP, gen(place)

replace place = "0"  + place if length(place) == 4
replace place = "00" + place if length(place) == 3

duplicates drop place state, force 

save place_city.dta, replace 
