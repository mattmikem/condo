*********************************************
*Build for DD/IV 
*M. Miller, 16W
*********************************************

cd "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"

capture log close

clear
clear matrix
clear mata

set more off

set maxvar 30000

global data  = "L:\Research\Condos\Data"
global work  = "L:\Research\Condos\Working Data"
global bound = "L:\Research\Resurgence\Working Files\Near Boundary"
*	global out   = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Output\03-02-2016"

use "$work\condo_pred.dta", clear

**Need to review this procedure, still a little suspect.

*lars condo_pct $l3_x_p, a(lasso) g

joinby state city_name using ords_full, unmatched(master)

gen top_city = 0
replace top_city = 1 if _merge == 3 & city_rank < $thr_u & city_rank > $thr_l 

drop _merge

joinby state using ords_st, unmatched(master)

drop _merge

save "$work\temp.dta", replace

**Re-applies ordinance to CBSA level (not just CC!)

keep Rank* Date* cbsa top_city city_name state

keep if top_city == 1

duplicates drop

joinby city_name using hse_city, unmatched(master)

gen msa_w_ord = 0

forvalues i = 1/4 {

replace msa_w_ord = 1 if Rank`i' > 0 & Rank`i' != . & Date`i' < 2010

}

*duplicates drop cbsa msa_w_ord, force

gsort cbsa -msa_w_ord

*duplicates drop cbsa, force

collapse (mean) sup_el (max) msa_w_ord, by(cbsa) 

*bysort Rank1: sum sup_el

keep cbsa msa_w_ord sup_el

save ord_cbsa, replace

use "$work\temp.dta", replace

**This keeps only tracts in CBSA where JS pulled condo regulation!

joinby cbsa using ord_cbsa

joinby geo2010 using "$bound\bound.dta", unmatched(master)
drop _merge

**CPI Adjustment

replace minc = minc/0.178 if year == 1970
replace minc = minc/0.38  if year == 1980
gen lminc = ln(minc)

label var lminc "Ln Mean Income"
label var marshr "Share Married"
label var educ_b "Bachelor Degree"
label var munit5pl "5+ Units"
label var emp "Employed"
label var shrwht "Share White"
label var age20_25 "Age 20 - 25"
label var age25_35 "Age 25 - 35"
label var age35_45 "Age 35 - 45"
label var age45_55 "Age 45 - 55"
label var age55_65 "Age 55 - 65"
label var age65pl "Age 65+"

label var cond_pct   "Condo Pct"
label var chat_l3_st "Condo Pct (pred, 1980)"
label var chat_l4_st "Condo Pct (pred, 1970)"

**Add metro FE

*encode cbsa, gen(cbsa_num)

*xtset cbsa_num

**Basic regressions: reduced-form, structural, and IV (with FE)

*Set of regressors

*global x_p   = "own munit1a munit2_4 munit5pl mbed1 mbed2 mbed3 mbed4pl hu_age10_20 hu_age20_30 hu_age30_40 hu_age40pl";

#delimit ;
global x_p = "cc_status own munit1a munit2_4 munit5pl mbed1 mbed2 mbed3 mbed4pl 
			  hu_age10_20 hu_age20_30 hu_age30_40 hu_age40pl vachu trvlpb wkhome 
			  auto";
#delimit cr

*Set of outcomes, predictions versus actual

*global yy = "lminc emp educ_b marshr shrwht age35_65 age65pl"
global yy = "lminc educ_b shrwht"

*xtreg lminc chat_tobit cc_status $x_p if source == "NCDB"  & year == 2010, fe vce(robust)
/*
foreach v of varlist $yy {

eststo: reg   `v' cond_pct $x_p if year == 2010 , vce(cluster cbsa)
eststo: reg   `v' chat_l4_st $x_p if  year == 2010, vce(cluster cbsa)
eststo: xtreg `v' cond_pct $x_p if year == 2010 , fe vce(robust)
eststo: xtreg `v' chat_l4_st $x_p if year == 2010, fe vce(robust)
eststo: ivregress 2sls `v' $x_p (cond_pct = chat_l4_st) if year == 2010

#delimit;
esttab using "$out\chat_`v'_act_1970.tex", replace label title("Condo Regressions on Neighborhood Outcomes (NBCD)")
r2 order(cond_pct chat_l4_st) keep(cond_pct chat_l4_st)
addnote("(1) and (2) are OLS." "(3) and (4) include metro FE, both include metro-level clustered standard errors." 
"(5) is 2SLS estimate with prediction as instrument."
"Additional controls include housing and commuting characteristics."
"Base year is 1970.");
clear matrix;
#delimit cr
}

foreach v of varlist $yy {

eststo: reg   `v' cond_pct $x_p if year == 2010 , vce(cluster cbsa)
eststo: reg   `v' chat_l3_st $x_p if  year == 2010, vce(cluster cbsa)
eststo: xtreg `v' cond_pct $x_p if year == 2010 , fe vce(robust)
eststo: xtreg `v' chat_l3_st $x_p if year == 2010, fe vce(robust)
eststo: ivregress 2sls `v' $x_p (cond_pct = chat_l3_st) if year == 2010

#delimit;
esttab using "$out\chat_`v'_act_1980.tex", replace label title("Condo Regressions on Neighborhood Outcomes (NBCD)")
r2 order(cond_pct chat_l3_st) keep(cond_pct chat_l3_st)
addnote("(1) and (2) are OLS." "(3) and (4) include metro FE, both include metro-level clustered standard errors." 
"(5) is 2SLS estimate with prediction as instrument."
"Additional controls include housing and commuting characteristics."
"Base year is 1980.");
clear matrix;
#delimit cr
}
*/

**Generate income percentiles
/*
sum cbsa_num
global N = r(max)

forvalues y = 1970(10)2010 {

forvalues j = 0/$N {

disp "`y': `j'"

quietly sum minc`y' if cbsa == `j', d

if r(N) > 0 {

local q = r(N)

if `q' > 100 {

xtile incp`y'_`j' = minc`y' if ua_code == `j', nq(100)

}

else if  `q' > 50 {

xtile incp`y'_`j' = minc`y' if ua_code == `j', nq(50)
replace incp`y'_`j' = incp`y'_`j'*2

}

else if  `q' > 25 {

xtile incp`y'_`j' = minc`y' if ua_code == `j', nq(25)
replace incp`y'_`j' = incp`y'_`j'*4

}

else {

xtile incp`y'_`j' = minc`y' if ua_code == `j', nq(10)
replace incp`y'_`j' = incp`y'_`j'*10

}

}

}

}

bysort cbsa_num : gen J = _N

forvalues y = 1970(10)2010 {
egen incp`y' = rowtotal(incp`y'*)
drop incp`y'_*
}
*/

save "$work\condo_full.dta", replace

