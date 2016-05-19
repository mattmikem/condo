********************************************
*Condo Prediction (1980, 90, 2000, 2006-2010)
*M. Miller, 15S
********************************************

cd "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"

capture log close

clear
clear matrix
clear mata

set more off

set maxvar 30000

global data  = "L:\Research\Condos\Data"
*global hud   = "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Condos\HUD_data"
*global wha   = "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Condos\Wharton_data"
global work  = "L:\Research\Condos\Working Data"
*global ncdb  = "C:\Users\Matthew\Dropbox\Research\Urban\Working Data"
global out   = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Output"

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
/*
use "$data\ipums_condo", replace

drop if year == 1990

drop if year > 2000 & year < 2010

keep if metro == 2 | metro == 3

drop if metro < 2
drop if metarea == 0

decode metarea, gen(msa_name)

gen     central_city = substr(msa_name, 1, strpos(msa_name, ",")-1)
replace central_city = substr(msa_name, 1, strpos(msa_name, "-")-1) if strpos(msa_name, "-") != 0 & strpos(msa_name, "-") < strpos(msa_name, ",")

gen cc_status = 1
gen state = substr(msa_name, strpos(msa_name, ",")+1, 3)

replace central_city = "New York" if state == "New"
replace central_city = "Greenville" if state == "Gre"

replace state = "NY" if state == "New"
replace state = "SC" if state == "Gre"

keep central_city state cc_status msa_name 

duplicates drop

replace state = trim(state)
replace central_city = trim(central_city)

save cen_city_names, replace

*/

**Generate (rel) complete set of variables for collapse

use "$data\ipums_condo.dta", clear

drop if year == 1990

drop if year > 2000 & year < 2010

keep if metro == 2 | metro == 3

drop if metro < 2
drop if metarea == 0

**Units

tab unitsstr, gen(units)

generate units2pl  = 0
replace  units2pl  = 1 if unitsstr > 4
generate units3pl  = 0
replace  units3pl  = 1 if unitsstr > 5
generate units5pl  = 0
replace  units5pl  = 1 if unitsstr > 6
generate units10pl = 0
replace  units10pl = 1 if unitsstr > 7
generate units20pl = 0
replace  units20pl = 1 if unitsstr > 8
generate units50pl = 0
replace  units50pl = 1 if unitsstr > 9

**Units (Main, manual bin generation)

generate munit1d    = 0
replace  munit1d    = 1 if unitsstr < 4
generate munit1a    = 0
replace  munit1a    = 1 if unitsstr == 5
generate munit2_4   = 0
replace  munit2_4   = 1 if unitsstr > 5 & unitsstr < 7
generate munit5_10  = 0
replace  munit5_10  = 1 if unitsstr == 7
generate munit10_50 = 0 
replace  munit10_50 = 1 if unitsstr > 7 & unitsstr < 9
generate munit50pl  = units50pl

**Bedrooms

tab bedrooms, gen(beds)

gen bed1pl = 0
replace bed1pl = 1 if bedrooms > 1
gen bed2pl = 0
replace bed2pl = 1 if bedrooms > 2
gen bed3pl = 0
replace bed3pl = 1 if bedrooms > 3
gen bed4pl = 0
replace bed4pl = 1 if bedrooms > 4
gen bed5pl = 0
replace bed5pl = 1 if bedrooms > 5
gen bed6pl = 0
replace bed6pl = 1 if bedrooms > 6

**Beds (Main, manual bin generation)

generate mbed0   = beds1
generate mbed1   = beds2
generate mbed2   = beds3
generate mbed3   = beds4
generate mbed4pl = 0
replace  mbed4pl = 1 if bedrooms > 3 
 
**Metro 

*(many obs without central/principal city status known)

**Age of Unit

gen     hu_age10 = 0
replace hu_age10 = 1 if year == 1980 & builtyr < 4
replace hu_age10 = 1 if year == 2000 & (builtyr2 == 7 | builtyr2 == 8)
replace hu_age10 = 1 if year == 2010 & builtyr2 > 8

gen     hu_age10_20 = 0 
replace hu_age10_20 = 1 if year == 1980 & builtyr == 4 
replace hu_age10_20 = 1 if year == 2000 & builtyr2 == 6 
replace hu_age10_20 = 1 if year == 2010 & (builtyr2 == 7)  

gen     hu_age20_30 = 0
replace hu_age20_30 = 1 if year == 1980 & builtyr  == 5
replace hu_age20_30 = 1 if year == 2000 & builtyr2 == 5
replace hu_age20_30 = 1 if year == 2010 & builtyr2 == 6

gen     hu_age30_40 = 0
replace hu_age30_40 = 1 if year == 1980 & builtyr  == 6
replace hu_age30_40 = 1 if year == 2000 & builtyr2 == 4
replace hu_age30_40 = 1 if year == 2010 & builtyr2 == 5
 
gen     hu_age40pl  = 0
replace hu_age40pl  = 1 if year == 1980 & builtyr  == 7 
replace hu_age40pl  = 1 if year == 2000 & builtyr2 < 3 
replace hu_age40pl  = 1 if year == 2010 & builtyr2 < 4  
 
**Occupancy

gen     own = 0
replace own = 1 if ownershp == 1

**Stories

tab stories, gen(story)
 
**Employment for weighting

gen     emp = 0
replace emp = 1 if empstat == 1

**Income

gen minc = hhincome

**Educ 

gen     educ_b = 0
replace educ_b = 1 if educ > 9

**Age

gen     age35_65 = 0
replace age35_65 = 1 if age > 34 & age < 66
replace age35_65 = . if age == .


gen     age65pl = 0
replace age65pl = 1  if age > 65
replace age65pl = .  if age == .

**Marriage

replace marry = 1 if marst < 4

**Collapse to Consistent PUMA

gen     count = 1

gen     ad_count = 0
replace ad_count = 1 if age > 15

**If 1, do NCDB averaging

local ncdb = 0

if `ncdb' == 1 {
replace year = 2010 if year > 2000 & year < 2010
}



collapse (sum) count ad_count condo_all units1 - story4 emp white marry educ_b age35_65 age65pl (mean) minc trantime, by(year metarea metro)

save msa, replace

*/

use msa, clear

gen condo_pct = condo_all/count
gen cc_status = 0
replace cc_status = 1 if metro == 2

#delimit ;
global x_p = "cc_status own trantime munit1a munit2_4 munit5_10 munit10_50 munit50pl  
              mbed1 mbed2 mbed3 mbed4pl 
			  hu_age10_20 hu_age20_30 hu_age30_40 hu_age40pl";
#delimit cr
	
replace educ_b   = educ_b/ad_count
replace emp      = emp/ad_count
gen marshr       = marry/ad_count
replace age35_65 = age35_65/count
replace age65pl  = age65pl/count
gen shrwht       = white/count
		
foreach v of varlist units1 - own {

replace `v' = `v'/count

}

tostring metarea metro, replace force
gen metcc = metarea+metro

destring metcc, replace

xtset metcc year, delta(10)

foreach v of varlist $x_p {

gen l_`v'  = L.`v'  if year == 2010
gen l2_`v' = L2.`v' if year == 2000
gen l3_`v' = L3.`v' if year == 2010

}


**Labels

label var condo_pct    "Condo Rate"
*label var munit1d      "1 Unit (detached) or Other"
label var munit1a      "1 Unit (attached)"
label var munit2_4     "2 - 4 Units"
label var munit5_10    "5 - 10 Units"
label var munit10_50   "10 - 50 Units"
label var munit50pl    "50+ Units"
*label var mbed0        "Studio/Zero Bedrooms"
label var mbed1        "One Bedroom"
label var mbed2        "Two Bedrooms"
label var mbed3        "Three Bedrooms"
label var mbed4pl      "4+ Bedrooms"
*label var hu_age10     "House Age $<$ 10 yrs"
label var hu_age10_20  "House Age 10 - 20 yrs"
label var hu_age20_30  "House Age 20 - 30 yrs"
label var hu_age30_40  "House Age 30 - 40 yrs"
label var hu_age40pl   "House Age 40+ yrs"
label var cc_status    "Central City"
label var own          "\% Units Owned"
label var trantime     "Commute Time (Mean)"
*label var l_munit1d      "1 Unit (detached) (2000)"
label var l_munit1a      "1 Unit (attached) (2000)"
label var l_munit2_4     "2 - 4 Units (2000)"
label var l_munit5_10    "5 - 10 Units (2000)"
label var l_munit10_50   "10 - 50 Units (2000)"
label var l_munit50pl    "50+ Units (2000)"
*label var l_mbed0        "Studio/Zero Bedrooms (2000)"
label var l_mbed1        "One Bedroom (2000)"
label var l_mbed2        "Two Bedrooms (2000)"
label var l_mbed3        "Three Bedrooms (2000)"
label var l_mbed4pl      "4+ Bedrooms (2000)"
*label var l_hu_age10     "House Age $<$ 10 yrs (2000)"
label var l_hu_age10_20  "House Age 10 - 20 yrs (2000)"
label var l_hu_age20_30  "House Age 20 - 30 yrs (2000)"
label var l_hu_age30_40  "House Age 30 - 40 yrs (2000)"
label var l_hu_age40pl   "House Age 40+ yrs (2000)"
label var l_cc_status "Central City (2000)"
label var l_own          "\% Units Owned (2000)"
label var l_trantime     "Commute Time (Mean) (2000)"
*label var l2_munit1d      "1 Unit (detached) (1980)"
label var l2_munit1a      "1 Unit (attached) (1980)"
label var l2_munit2_4     "2 - 4 Units (1980)"
label var l2_munit5_10    "5 - 10 Units (1980)"
label var l2_munit10_50   "10 - 50 Units (1980)"
label var l2_munit50pl    "50+ Units (1980)"
*label var l2_mbed0        "Studio/Zero Bedrooms (1980)"
label var l2_mbed1        "One Bedroom (1980)"
label var l2_mbed2        "Two Bedrooms (1980)"
label var l2_mbed3        "Three Bedrooms (1980)"
label var l2_mbed4pl      "4+ Bedrooms (1980)"
*label var l2_hu_age10     "House Age $<$ 10 yrs (1980)"
label var l2_hu_age10_20  "House Age 10 - 20 yrs (1980)"
label var l2_hu_age20_30  "House Age 20 - 30 yrs (1980)"
label var l2_hu_age30_40  "House Age 30 - 40 yrs (1980)"
label var l2_hu_age40pl   "House Age 40+ yrs (1980)"
label var l2_cc_status "Central City (1980)"
label var l2_own          "\% Units Owned (1980)"
label var l2_trantime     "Commute Time (Mean) (1980)"
*label var l3_munit1d      "1 Unit (detached) (1980)"
label var l3_munit1a      "1 Unit (attached) (1980)"
label var l3_munit2_4     "2 - 4 Units (1980)"
label var l3_munit5_10    "5 - 10 Units (1980)"
label var l3_munit10_50   "10 - 50 Units (1980)"
label var l3_munit50pl    "50+ Units (1980)"
*label var l3_mbed0        "Studio/Zero Bedrooms (1980)"
label var l3_mbed1        "One Bedroom (1980)"
label var l3_mbed2        "Two Bedrooms (1980)"
label var l3_mbed3        "Three Bedrooms (1980)"
label var l3_mbed4pl      "4+ Bedrooms (1980)"
*label var l3_hu_age10     "House Age $<$ 10 yrs (1980)"
label var l3_hu_age10_20  "House Age 10 - 20 yrs (1980)"
label var l3_hu_age20_30  "House Age 20 - 30 yrs (1980)"
label var l3_hu_age30_40  "House Age 30 - 40 yrs (1980)"
label var l3_hu_age40pl   "House Age 40+ yrs (1980)"
label var l3_cc_status "Central City (1980)"
label var l3_own          "\% Units Owned (1980)"
label var l3_trantime     "Commute Time (Mean) (1980)"

**Summary Statistics

eststo: estpost tabstat condo_pct $x_p, by(year) statistics(mean sd) columns(statistics)
esttab est* using "$out\summ_msa.tex", replace main(mean) one aux(sd) nostar unstack nonote label title("Summary Statistics") nonumber obslast addn("Mean (Standard Deviation).")
clear matrix

*Procedure is (somewhat) tempermental
/*
**Set 1 : Cross-Section

*stepwise, pe(.1): reg condo_pct $x_p if year == 1980, r
*eststo
stepwise, pr(.1): reg condo_pct $x_p if year == 1980, r
eststo
predict condo_hat
*stepwise, pe(.1): reg condo_pct $x_p if year == 2000, r
*eststo
stepwise, pr(.1): reg condo_pct $x_p if year == 2000, r
eststo
*stepwise, pe(.1): reg condo_pct $x_p if year == 2010, r
*eststo
stepwise, pr(.1): reg condo_pct $x_p if year == 2010, r
eststo
*stepwise, pe(.1): reg condo_pct $x_p, r
*eststo
stepwise, pr(.1): reg condo_pct $x_p, r
eststo
eststo: reg condo_pct $x_p if year == 2000, r

#delimit ;
esttab est* using "$out\cross_sec_msa.csv", 
replace label title("Cross-Section (Intra-year) - [Dep Var = Condo Percentage]") 
order($x_p)  
mlabel("1980 (-)" "2000 (-)" "2010 (-)" "Pooled (-)" "Pooled (Full)") 
r2 ar2 se brackets addn("(+) indicates forward stepwise, (-) indicates backward stepwise.");
esttab est* using "$out\cross_sec_msa.tex", 
replace label title("Cross-Section (Intra-year) - [Dep Var = Condo Percentage]") 
order($x_p)
mlabel("1980 (-)" "2000 (-)" "2010 (-)" "Pooled (-)" "Pooled (Full)")
r2 ar2 se brackets addn("(+) indicates forward stepwise, (-) indicates backward stepwise. Stopping critera $\alpha = 0.1$ ");;
# delimit cr

clear matrix

stepwise, pr(.1): tobit condo_pct $x_p if year == 1980, ll(0) ul(1)
predict condo_tobit, ystar(0,1)

gen resid1 = (condo_hat - condo_pct)
gen resid2 = (condo_tobit - condo_pct)

label var resid1 "Prediction Error %"

sum condo_pct if year == 2010

local sd = -1*r(sd)

#delimit ;
kdensity resid1 if year == 2010, 
addplot(kdensity resid2 if year == 2010) 
title("Prediction Errors: 1980 to Predict 2010")
subtitle("Linear Regression versus Tobit") 
legend(label(1 "Linear") label(2 "Tobit")) name(pred_error_msa, replace)
xline(`sd')
note("Vertical line at one standard deviation in condo pct.")
graphregion(color(white)) bgcolor(white);
#delimit cr

graph export "$out\pred_error_msa.png", replace name(pred_error_msa)

**Add prediction graph of some sort

**Set 2 (lagged)

#delimit ;
global lx_p  = "central_city l_own l_trantime  l_munit1a l_munit2_4 l_munit5_10 l_munit10_50 l_munit50pl  l_mbed1 l_mbed2 l_mbed3 l_mbed4pl  l_hu_age10_20 l_hu_age20_30 l_hu_age30_40 l_hu_age40pl";
global l2x_p = "central_city l2_own l2_trantime  l2_munit1a l2_munit2_4 l2_munit5_10 l2_munit10_50 l2_munit50pl  l2_mbed1 l2_mbed2 l2_mbed3 l2_mbed4pl  l2_hu_age10_20 l2_hu_age20_30 l2_hu_age30_40 l2_hu_age40pl";
global l3x_p = "central_city l3_own l3_trantime  l3_munit1a l3_munit2_4 l3_munit5_10 l3_munit10_50 l3_munit50pl  l3_mbed1 l3_mbed2 l3_mbed3 l3_mbed4pl  l3_hu_age10_20 l3_hu_age20_30 l3_hu_age30_40 l3_hu_age40pl";
#delimit cr 

**2000 (lag 1980)

stepwise, pe(.1): reg condo_pct $l2x_p if year == 2000, r
eststo
stepwise, pr(.1): reg condo_pct $l2x_p if year == 2000, r
eststo
eststo: reg condo_pct $l2x_p if year == 2000, r
estnice "$l2x_p" 2000 20 "Lag"

**2010 (lag 1980)

stepwise, pe(.1): reg condo_pct $l3x_p if year == 2010, r
eststo
stepwise, pr(.1): reg condo_pct $l3x_p if year == 2010, r
eststo
predict condolag_hat 
eststo: reg condo_pct $l3x_p if year == 2010, r
estnice "$l3x_p" 2010 30 "Lag"

**2010 (lag 2000)

stepwise, pe(.1): reg condo_pct $lx_p if year == 2010, r
eststo
stepwise, pr(.1): reg condo_pct $lx_p if year == 2010, r
eststo
eststo: reg condo_pct $lx_p if year == 2010, r
estnice "$lx_p" 2010 10 "Lag"

**Set 3: Deltas

**Condo % Delta

generate d1condo_pct = 0
generate d2condo_pct = 0
generate d3condo_pct = 0
replace  d1condo_pct = condo_pct - L1.condo_pct if year == 2010
replace  d2condo_pct = condo_pct - L2.condo_pct if year == 2000
replace  d3condo_pct = condo_pct - L3.condo_pct if year == 2010

**2000 (lag 1980)

stepwise, pe(.1): reg d2condo_pct $l2x_p if year == 2000, r
eststo
stepwise, pr(.1): reg d2condo_pct $l2x_p if year == 2000, r
eststo
eststo: reg d2condo_pct $l2x_p if year == 2000, r
estnice "$l2x_p" 2000 20 "Delta"

**2010 (lag 1980)

stepwise, pe(.1): reg d3condo_pct $l3x_p if year == 2010, r
eststo
stepwise, pr(.1): reg d3condo_pct $l3x_p if year == 2010, r
eststo
eststo: reg d3condo_pct $l3x_p if year == 2010, r
estnice "$l3x_p" 2010 30 "Delta"

**2010 (lag 2000)

stepwise, pe(.1): reg d1condo_pct $lx_p if year == 2010, r
eststo
stepwise, pr(.1): reg d1condo_pct $lx_p if year == 2010, r
eststo
eststo: reg d1condo_pct $lx_p if year == 2010, r
estnice "$lx_p" 2010 10 "Delta"

**Round Two with Tobit specs**

*Graphs

*twoway (scatter condo_hat    condo_pct) (lfit condo_hat condo_pct) (function y = x, lpattern(dash) range(condo_pct)) if year == 2010, name(pred_1, replace)
*twoway (scatter condolag_hat condo_pct) (lfit condolag_hat condo_pct)(function y = x, lpattern(dash) range(condo_pct)) if year == 2010, name(pred_2, replace)


*probit condo_pct $x_p if year == 1980
*predict condo_prob
*twoway scatter condo_prob condo_pct if year == 2010

/*
logit condo_pct units2pl bed3pl central_city hu_age40pl own trantime

predict condo_hat

gen pred_error = condo_hat - condo_pct

hist pred_error if year == 1980
hist pred_error if year == 2000
hist pred_error if year == 2010

sort year conspuma

twoway (scatter condo_hat condo_pct if year == 1980) (scatter condo_hat condo_pct if year == 2010)

*/
*/
************************************************************
**Predictions using initial conditions in NCDB 1970-1980.
************************************************************

*Redefine for NCDB predictions

**Units (Main, manual bin generation)

*generate munit1d    = 0
*replace  munit1d    = 1 if unitsstr < 4
*generate munit1a    = 0
*replace  munit1a    = 1 if unitsstr == 5
*generate munit2_4   = 0
*replace  munit2_4   = 1 if unitsstr > 5 & unitsstr < 7
*generate munit5_10  = 0
*replace  munit5_10  = 1 if unitsstr == 7
*generate munit10_50 = 0 
*replace  munit10_50 = 1 if unitsstr > 7 & unitsstr < 9
generate munit5pl   = units5pl

**No 30-40 range for 1970 (earliest category is pre-1939)

replace hu_age30_40 = hu_age30_40 + hu_age40pl if year == 1970

gen source = "IPUMS"

gen l3_munit5pl = L3.munit5pl if year == 2010

*append using "$work\ncdb_condo_old.dta"
append using "$work\ncdb_condo.dta"

*replace own = ownocc if source == "NCDB"

drop if year == 1	

**Using 1970 as base year (no housing age 40+ in 1970)

#delimit ;
global x_p   = "own munit1a munit2_4 munit5pl mbed1 mbed2 mbed3 mbed4pl hu_age10_20 hu_age20_30 hu_age30_40";
global l3x_p = "l3_own l3_munit1a l3_munit2_4 l3_munit5pl l3_mbed1 l3_mbed2 l3_mbed3 l3_mbed4pl  l3_hu_age10_20 l3_hu_age20_30 l3_hu_age30_40";
#delimit cr 

foreach v of varlist $x_p {

replace l3_`v' = `v' if year == 1970 & source == "NCDB"


}

stepwise, pr(.1): reg   condo_pct $l3x_p if year == 2010 & source == "IPUMS", r
predict chat_ols_1970 if year == 1970 & source == "NCDB"
stepwise, pr(.1): tobit condo_pct   $l3x_p if year == 2010 & source == "IPUMS", ll(0) ul(1)
predict chat_tobit_1970 if year == 1970 & source == "NCDB", ystar(0,1)

**Using 1980 as base year (includes housing age 40+)

#delimit ;
global x_p   = "own munit1a munit2_4 munit5pl mbed1 mbed2 mbed3 mbed4pl hu_age10_20 hu_age20_30 hu_age30_40 hu_age40pl";
global l3x_p = "l3_own l3_munit1a l3_munit2_4 l3_munit5pl l3_mbed1 l3_mbed2 l3_mbed3 l3_mbed4pl  l3_hu_age10_20 l3_hu_age20_30 l3_hu_age30_40 l3_hu_age40pl";
#delimit cr 

foreach v of varlist $x_p {

replace l3_`v' = `v' if year == 1980 & source == "NCDB"

}

stepwise, pr(.1): reg   condo_pct $l3x_p if year == 2010 & source == "IPUMS", r
predict chat_ols_1980 if year == 1980 & source == "NCDB"
stepwise, pr(.1): tobit condo_pct   $l3x_p if year == 2010 & source == "IPUMS", ll(0) ul(1)
predict chat_tobit_1980 if year == 1980 & source == "NCDB", ystar(0,1)


#delimit ;
kdensity chat_ols_1970 if year == 1970 & source == "NCDB", 
addplot(kdensity chat_tobit_1970 if year == 1970 & source == "NCDB") 
title("Predicted 2010 Condo Rate by Tract: 1970 Base Year")
subtitle("Linear Regression versus Tobit") 
legend(label(1 "Linear") label(2 "Tobit")) name(pred70_msa, replace)

graphregion(color(white)) bgcolor(white);
#delimit cr

#delimit ;
kdensity chat_ols_1980 if year == 1980 & source == "NCDB", 
addplot(kdensity chat_tobit_1980 if year == 1980 & source == "NCDB") 
title("Predicted 2010 Condo Rate by Census Tract: 1980 Base Year")
subtitle("Linear Regression versus Tobit") 
legend(label(1 "Linear") label(2 "Tobit")) name(pred80_msa, replace)
graphregion(color(white)) bgcolor(white);
#delimit cr

#delimit ;
kdensity condo_pct if year == 2010 & source == "IPUMS", 
title("Actual Condo Rate by MSA (dist. CC)")
subtitle("2010") 
name(act10, replace)
graphregion(color(white)) bgcolor(white);
#delimit cr

save "$work\condo_temp_msa.dta", replace
/*
keep if year == 2010 & source == "IPUMS"

gen geo = "MSA"

keep geo condo_pct metarea metro

save msa_pct, replace

use "$work\condo_temp_msa.dta", clear

gen     ctob_count = .
*replace ctob_count = chat_tobit_1970*tothu if year == 1970 & source == "NCDB"
replace ctob_count = chat_tobit_1980*tothu if year == 1980 & source == "NCDB"

keep state cc_status cbsa ctob_count tothu year source
keep if year == 1980 & source == "NCDB"

collapse (sum) ctob_count tothu, by(cbsa cc_status)

gen condo_pct = ctob_count/tothu

gen geo = "CBSA-CC"

keep if cbsa != ""

append using msa_pct

ksmirnov condo_pct, by(geo)

#delimit ;
kdensity condo_pct if geo == "MSA", addplot(kdensity condo_pct if geo == "CBSA-CC")
title("Predicted and Actual Condo Rate Density")
subtitle("2010") 
legend(label(1 "Actual (IPUMS)") label(2 "Predicted (NBCD)"))
name(pred10_msa, replace)
note("IPUMS geography is MSA; NBCD geography is CBSA. Both distinguish central city from outside central-city.")
graphregion(color(white)) bgcolor(white);
#delimit cr

*graph export "$out\pred70_msa.png", name(pred70_msa) replace
*graph export "$out\pred80_msa.png", name(pred80_msa) replace
*graph export "$out\act10_msa.png", name(act10_msa) replace
graph export "$out\pred10_msa.png", name(pred10_msa) replace

**Rank

use "$work\condo_temp_msa.dta", clear

gen     ctob_count = .
*replace ctob_count = chat_tobit_1970*tothu if year == 1970 & source == "NCDB"
replace ctob_count = chat_tobit_1980*tothu if year == 1980 & source == "NCDB"

keep state cc_status city_name cbsa ctob_count tothu year source
keep if year == 1980 & source == "NCDB" & cc_status == 1

collapse (sum) ctob_count tothu, by(city_name state)

gen condo_pct = ctob_count/tothu

gsort -condo_pct

order city_name state condo_pct

texsave city_name state condo_pct using "$out\rank_condo.tex", replace

**Regressions on Outcomes**

use "$work\condo_temp_msa.dta", clear

keep geo2010 source chat_tobit_1980
keep if source == "NCDB"

rename chat_tobit_1980 chat_tobit

drop if chat_tobit == .

duplicates drop

save chat, replace

use "$work\condo_temp_msa.dta", clear

*drop _merge

joinby geo2010 source using chat, unmatched(master)

gen lminc = ln(minc)

label var lminc "Ln Mean Income"
label var marshr "Share Married"
label var educ_b "Bachelor Degree"
label var munit5pl "5+ Units"
label var emp "Employed"
label var shrwht "Share White"
label var age35_65 "Age 35 - 65"
label var age65pl "Age 65+"

label var condo_pct "Condo Pct (actual)"
label var chat_tobit "Condo Pct (pred)"

**Add metro FE

encode cbsa, gen(cbsa_num)

xtset cbsa_num

global yy = "lminc emp educ_b marshr shrwht age35_65 age65pl"

foreach v of varlist $yy {

eststo: reg   `v' condo_pct  cc_status $x_p if source == "IPUMS" & year == 2010, r 

}

esttab using "$out\chat_ipums.tex", replace label title("Condo Associations with Outcomes (IPUMS by MSA)") order(condo_pct) r2 nocons
clear matrix

global yy = "lminc emp educ_b marshr shrwht age35_65 age65pl"

*xtreg lminc chat_tobit cc_status $x_p if source == "NCDB"  & year == 2010, fe vce(robust)

foreach v of varlist $yy {

eststo: reg   `v' chat_tobit cc_status $x_p if source == "NCDB"  & year == 2010, vce(cluster cbsa)
eststo: xtreg `v' chat_tobit cc_status $x_p if source == "NCDB"  & year == 2010, fe vce(robust)

*esttab using "$out\chat_`v'.tex", replace label title("Condo Associations with Outcomes (NBCD)") r2 order(chat_tobit) note("(1) is OLS, (2) includes metro FE, both include metro-level clustered se.")
clear matrix

}

**Include legislation

rename state prime_st

joinby prime_st using st_conv

gen rtp_chat = rtp_cat*chat_tobit
gen notice_chat = notice_cat*chat_tobit

label var rtp_chat "RTP $\times$ Condo Pct (pred)"
label var notice_chat "Notice $\times$ Condo Pct (pred)"
label var rtp_cat "RTP"
label var notice_cat "Notice"

foreach v of varlist $yy {

eststo: reg   `v' chat_tobit cc_status $x_p if source == "NCDB"  & year == 2010, vce(cluster cbsa)
eststo: xtreg `v' chat_tobit cc_status $x_p if source == "NCDB"  & year == 2010, fe vce(robust)
eststo: reg   `v' chat_tobit rtp_cat notice_cat rtp_chat notice_chat cc_status $x_p if source == "NCDB"  & year == 2010, vce(cluster cbsa)
eststo: xtreg `v' chat_tobit rtp_cat notice_cat rtp_chat notice_chat cc_status $x_p if source == "NCDB"  & year == 2010, fe vce(robust)

#delimit ;
esttab using "$out\chat_`v'_reg.tex", replace label 
title("Condo Associations with Outcomes (NBCD)") order(chat_tobit) keep(chat_tobit notice_cat rtp_cat rtp_chat notice_chat) r2
note("(1) is OLS, (2) includes metro FE, (3) and (4) are the same but includes interactions with tenant rights legislation at state level.");
#delimit cr
clear matrix

}


xx

/*
use "$work\condo_temp.dta", clear

gen     ctob_count = .
*replace ctob_count = chat_tobit_1970*tothu if year == 1970 & source == "NCDB"
replace ctob_count = chat_tobit_1980*tothu if year == 1980 & source == "NCDB"

keep state place cbsa ctob_count tothu year source
keep if year == 1980 & source == "NCDB"

collapse (sum) ctob_count tothu, by(place)

joinby 
xx


*Beta_hat is the set of estimates from level-lag regressions; delta_hat is set of estimates from delta-lag regressions





