********************************************
*Condo Prediction (1980, 90, 2000, 2006-2010)
*M. Miller, 15S
********************************************

*cd "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"
cd "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"

capture log close

clear
clear matrix
clear mata

set more off

set maxvar 30000

*global data  = "C:\Users\Matthew\Desktop\ECON\Research\Urban\Papers\Condos\Data"
global data  = "L:\Research\Condos\Data"
*global hud   = "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Condos\HUD_data"
*global wha   = "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Condos\Wharton_data"
*global work  = "C:\Users\Matthew\Desktop\ECON\Research\Urban\Papers\Condos\Working"
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

drop if metro == 0

**Generate (rel) complete set of variables for collapse

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

gen     central_city = 0
replace central_city = 1 if metro == 2

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

**Collapse to Consistent PUMA

gen     count = 1

drop if year == 1990

**If 1, do NCDB averaging

local ncdb = 0

if `ncdb' == 1 {
replace year = 2010 if year > 2000 & year < 2010
}

drop if year > 2000 & year < 2010

collapse (sum) count condo_all units1 - story4 (mean) trantime [w=emp], by(year conspuma)

save conspuma, replace

*/

use conspuma, clear

gen condo_pct = condo_all/count

#delimit ;
global x_p = "central_city own trantime munit1a munit2_4 munit5_10 munit10_50 munit50pl  
              mbed1 mbed2 mbed3 mbed4pl 
			  hu_age10_20 hu_age20_30 hu_age30_40 hu_age40pl";
#delimit cr
			  
foreach v of varlist units1 - own {

replace `v' = `v'/count

}


tsset conspuma year, delta(10)

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
label var central_city "Central City"
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
label var l_central_city "Central City (2000)"
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
label var l2_central_city "Central City (1980)"
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
label var l3_central_city "Central City (1980)"
label var l3_own          "\% Units Owned (1980)"
label var l3_trantime     "Commute Time (Mean) (1980)"

**Summary Statistics

eststo: estpost tabstat condo_pct $x_p, by(year) statistics(mean sd) columns(statistics)
esttab est* using "$out\summ.tex", replace main(mean) one aux(sd) nostar unstack nonote label title("Summary Statistics") nonumber obslast addn("Mean (Standard Deviation).")
clear matrix

*Procedure is (somewhat) tempermental

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
esttab est* using "$out\cross_sec.csv", 
replace label title("Cross-Section (Intra-year) - [Dep Var = Condo Percentage]") 
order($x_p)  
mlabel("1980 (-)" "2000 (-)" "2010 (-)" "Pooled (-)" "Pooled (Full)") 
r2 ar2 se brackets addn("(+) indicates forward stepwise, (-) indicates backward stepwise.");
esttab est* using "$out\cross_sec.tex", 
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
legend(label(1 "Linear") label(2 "Tobit")) name(pred_error, replace)
xline(`sd')
note("Vertical line at one standard deviation in condo pct.")
graphregion(color(white)) bgcolor(white);
#delimit cr

graph export "$out\pred_error.png", replace name(pred_error)

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

append using "$work\ncdb_condo.dta"

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
legend(label(1 "Linear") label(2 "Tobit")) name(pred70, replace)

graphregion(color(white)) bgcolor(white);
#delimit cr

#delimit ;
kdensity chat_ols_1980 if year == 1980 & source == "NCDB", 
addplot(kdensity chat_tobit_1980 if year == 1980 & source == "NCDB") 
title("Predicted 2010 Condo Rate by Census Tract: 1980 Base Year")
subtitle("Linear Regression versus Tobit") 
legend(label(1 "Linear") label(2 "Tobit")) name(pred80, replace)
graphregion(color(white)) bgcolor(white);
#delimit cr

#delimit ;
kdensity condo_pct if year == 2010 & source == "IPUMS", 
title("Actual Condo Rate by CONSPUMA")
subtitle("2010") 
name(act10, replace)
graphregion(color(white)) bgcolor(white);
#delimit cr

save "$work\condo_temp.dta", replace

keep if year == 2010 

gen geo = "CONSPUMA"

keep geo condo_pct conspuma

save conspuma_pct, replace

use "$work\condo_temp.dta", clear

gen     ctob_count = .
*replace ctob_count = chat_tobit_1970*tothu if year == 1970 & source == "NCDB"
replace ctob_count = chat_tobit_1980*tothu if year == 1980 & source == "NCDB"

keep state place cbsa ctob_count tothu year source
keep if year == 1980 & source == "NCDB"

collapse (sum) ctob_count tothu, by(cbsa)

gen condo_pct = ctob_count/tothu

gen geo = "CBSA"

append using conspuma_pct

ksmirnov condo_pct, by(geo)

#delimit ;
kdensity condo_pct if geo == "CONSPUMA", addplot(kdensity condo_pct if geo == "CBSA")
title("Predicted and Actual Condo Rate Density")
subtitle("2010") 
legend(label(1 "Actual (IPUMS)") label(2 "Predicted (NBCD)"))
name(pred10, replace)
note("IPUMS geography is CONSPUMA; NBCD geography is CBSA.")
graphregion(color(white)) bgcolor(white);
#delimit cr

graph export "$out\pred70.png", name(pred70) replace
graph export "$out\pred80.png", name(pred80) replace
graph export "$out\act10.png", name(act10) replace
graph export "$out\pred10.png", name(pred10) replace

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





