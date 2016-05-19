********************************************
*Condo Analyses of Regulation (prelim)
*M. Miller, 15F
********************************************

cd "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"

capture log close

clear
clear matrix
clear mata

set more off

set maxvar 30000

global work  "L:\Research\Condos\Working Data"
global bound "L:\Research\Resurgence\Working Files\Boundary"
global out   "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Output\03-02-2016"

**Regressions on Outcomes**

use "$work\condo_temp_msa.dta", clear

keep geo2010 source chat_tobit_1970
keep if source == "NCDB"

rename chat_tobit_1970 chat_tobit

drop if chat_tobit == .

duplicates drop

save chat, replace

use "$work\condo_temp_msa.dta", clear

**City name adjustments

*Notes: missing Anchorage, AK; Gilbert/Chandler, AZ issue

replace city_name = "Indianapolis" if strpos(city_name, "Indianapolis") != 0

keep if source == "NCDB"

*Predicted Condo Rates

joinby geo2010 source using chat, unmatched(master)
drop _merge

*Boundary identifiers

joinby geo2010 using "$bound\bound.dta", unmatched(master)
drop _merge

*State and Municipal ordinances

joinby state city_name using ords_full, unmatched(master)

gen top_city = 0
replace top_city = 1 if _merge == 3

drop _merge

*2010 Condo rates from Census

joinby geo2010 using "$work\actual_condo.dta", unmatched(master)
drop _merge

**Re-apply local ordinace status to entire set of CBSA tracts, not just CC (for DDD).

save "$work\temp.dta", replace

keep Rank* Date* cbsa top_city

keep if top_city == 1

/*
egen rank_max = rowmax(Rank*)
egen date_min = rowmax(Date*)

gen cut1 = Rank1*10000 + Date1
gen cut2 = Rank2*10000 + Date2 
gen cut3 = Rank3*10000 + Date3
gen cut4 = Rank4*10000 + Date4
*/

gen msa_ord = 0

forvalues i = 1/4 {

replace msa_ord = 1 if Rank`i' > 0 & Date`i' < 2010

}

duplicates drop cbsa msa_ord, force

gsort cbsa -msa_ord

duplicates drop cbsa, force

keep cbsa msa_ord

save ord_cbsa, replace

use "$work\temp.dta", replace

joinby cbsa using ord_cbsa

gen lminc = ln(minc)

gen act_con = wcnt03/wcnt01

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
label var act_con   "Condo Pct (actual)"

**Add metro FE

encode cbsa, gen(cbsa_num)

xtset cbsa_num

*Set of regressors

global x_p   = "own munit1a munit2_4 munit5pl mbed1 mbed2 mbed3 mbed4pl hu_age10_20 hu_age20_30 hu_age30_40 hu_age40pl";

*Set of outcomes

global yy = "lminc emp educ_b marshr shrwht age35_65 age65pl"

*xtreg lminc chat_tobit cc_status $x_p if source == "NCDB"  & year == 2010, fe vce(robust)

foreach v of varlist $yy {

eststo: reg   `v' act_con cc_status $x_p if source == "NCDB"  & year == 2010 & chat_tobit != ., vce(cluster cbsa)
eststo: reg   `v' chat_tobit cc_status $x_p if source == "NCDB"  & year == 2010, vce(cluster cbsa)
eststo: xtreg `v' act_con cc_status $x_p if source == "NCDB"  & year == 2010 & chat_tobit != ., fe vce(robust)
eststo: xtreg `v' chat_tobit cc_status $x_p if source == "NCDB"  & year == 2010, fe vce(robust)

esttab using "$out\chat_`v'.tex", replace label title("Condo Associations with Outcomes (NBCD)") r2 order(act_con chat_tobit) keep(act_con chat_tobit) note("(1) and (2) are OLS, (3) and (4) include metro FE, both include metro-level clustered se.")
clear matrix

}

**Include legislation
/*
rename state prime_st

joinby prime_st using st_conv

gen rtp_chat = rtp_cat*chat_tobit
gen notice_chat = notice_cat*chat_tobit

label var rtp_chat "RTP $\times$ Condo Pct (pred)"
label var notice_chat "Notice $\times$ Condo Pct (pred)"
label var rtp_cat "RTP"
label var notice_cat "Notice"
*/

**Baseline Regulation Analysis

*Any score of local regulation versus none

gen local_ord = 0
replace local_ord = 1 if Rank1 > 0
gen loc_ord_chat = local_ord*chat_tobit

*gen loc_ord_cc = LocalOrdin
*replace loc_ord_cc = 0 if cc_status == 0

label var local_ord    "Strict Local Ordinance (0/1)"
label var loc_ord_chat "Strict Loc Ord (0/1) $\times$ Condo Pct (pred)"

*Scores of local reg (use LocalOrd)
/*
foreach v of varlist $yy {

eststo: reg   `v' chat_tobit cc_status $x_p if source == "NCDB"  & year == 2010 & LocalOrdMsa > 3, vce(cluster cbsa)
eststo: xtreg `v' chat_tobit cc_status $x_p if source == "NCDB"  & year == 2010 & LocalOrdMsa > 3, fe vce(robust)
eststo: reg   `v' chat_tobit cc_status local_ord $x_p if source == "NCDB"  & year == 2010 & LocalOrdMsa  > 3, vce(cluster cbsa)
eststo: xtreg `v' chat_tobit cc_status local_ord $x_p if source == "NCDB"  & year == 2010 & LocalOrdMsa  > 3, fe vce(robust)
eststo: reg   `v' chat_tobit local_ord loc_ord_chat cc_status $x_p if source == "NCDB"  & year == 2010 & LocalOrdMsa  > 3, vce(cluster cbsa)
eststo: xtreg `v' chat_tobit local_ord loc_ord_chat cc_status $x_p if source == "NCDB"  & year == 2010 & LocalOrdMsa  > 3, fe vce(robust)
*eststo: xi: reg   `v' i.loc_ord_cc*chat_tobit cc_status $x_p if source == "NCDB"  & year == 2010 & LocalOrdin != ., vce(cluster cbsa)
*eststo: xi: xtreg `v' i.loc_ord_cc*chat_tobit cc_status $x_p if source == "NCDB"  & year == 2010 & LocalOrdin != ., fe vce(robust)

#delimit ;
esttab using "$out\chat_`v'_ord.tex", replace label 
title("Condo Ordinance Assciations with Outcomes in 2010 (NBCD) ") order(chat_tobit) keep(chat_tobit local_ord loc_ord_chat) r2 se brackets
addnote("All regressions include controls for contemporaneous housing stock" "(1) is OLS, (2) includes metro FE, (3) and (4) are the same but includes interactions with categories.");
#delimit cr
clear matrix

}
*/
**DDD Analysis

drop if top_city == 0

gen post = 0
replace post = 1 if year > reg_year & reg_year != .
replace post = 1 if year > 1970 & reg_year == .

gen loc_ord_msa = 0
replace loc_ord_msa = 1 if msa_ord == 1 & msa_ord != .

gen post_cc         = post*cc_status
gen post_loc_ord    = post*local_ord 
gen cc_loc_ord      = cc_status*local_ord
gen cc_loc_ord_post = cc_status*local_ord*post

label var post_loc_ord     "Post-Condo Ord $\times$ MSA with Condo Ordinance"
label var post_cc          "Post-Condo Ord $\times$ Central City Tract"
label var cc_loc_ord_post  "Post-Condo Ord $\times$ CC Tract $\times$ MSA with Condo Ord"

**Test diff-in-diff specs

*Start with effect on condo rates

eststo: reg act_con cc_status post post_cc if loc_ord_msa == 1, r
eststo: reg act_con cc_status post post_cc if loc_ord_msa == 0, r
eststo: reg act_con loc_ord_msa post post_loc_ord if cc_status == 1, r
eststo: reg act_con loc_ord_msa post post_loc_ord if cc_status == 0, r
eststo: reg act_con cc_status loc_ord_msa post post_cc post_loc_ord cc_loc_ord cc_loc_ord_post if year == 2010, r


#delimit ;
esttab using "$out\ddd_act_con.tex", replace label 
title("Diff-in-Diff-in-Diff (and Components)") se brackets
order(post_cc post_loc_ord cc_loc_ord_post) keep(post_cc post_loc_ord cc_loc_ord_post)
addnote("Tracts are indexed by time (pre and post ordinance), MSA status (if there was ever a local ordinance re condos),"
"and central city status (meaning if local ordinance in MSA is relevant)." 
"(1) Limited to MSA with Local Ord at some point in time." 
"(2) Limited to MSA no Local Ord." "(3) Limited to Central City." "(4) Limited to Suburbs.") 
r2 nocons ;

#delimit cr

clear matrix

xx
*Start with income

global yy  = "lminc emp educ_b marshr shrwht age35_65 age65pl"

foreach v of varlist $yy {

eststo: reg `v' cc_status post post_cc if loc_ord_msa == 1, r
eststo: reg `v' cc_status post post_cc if loc_ord_msa == 0, r
eststo: reg `v' loc_ord_msa post post_loc_ord if cc_status == 1, r
eststo: reg `v' loc_ord_msa post post_loc_ord if cc_status == 0, r
eststo: reg `v' cc_status loc_ord_msa post post_cc post_loc_ord cc_loc_ord cc_loc_ord_post, r  

#delimit ;
esttab using "$out\ddd_`v'.tex", replace label 
title("Diff-in-Diff-in-Diff (and Components)") se brackets
order(post_cc post_loc_ord cc_loc_ord_post) keep(post_cc post_loc_ord cc_loc_ord_post)
addnote("Tracts are indexed by time (pre and post ordinance), MSA status (if there was ever a local ordinance re condos),"
"and central city status (meaning if local ordinance in MSA is relevant)." 
"(1) Limited to MSA with Local Ord at some point in time." 
"(2) Limited to MSA no Local Ord." "(3) Limited to Central City." "(4) Limited to Suburbs.") 
r2 nocons ;

#delimit cr

clear matrix

}

**Include propensity for condo (chat and housing age)

drop loc_ord_chat l_hu_age30_40

gen post_cc_chat = post*cc_status*chat_tobit
gen post_cc_hous = post*cc_status*hu_age30_40
gen cc_chat      = cc_status*chat_tobit
gen loc_ord_chat = loc_ord_msa*chat_tobit


gen time = .
replace time = 0 if year == 1970
replace time = 1 if year == 2010

xtset geo2010 time

gen l_hu_age30_40   = L.hu_age30_40
gen cc_l_hu_age30_40  = cc_status*l_hu_age30_40
gen loc_hu_age30_40 = loc_ord_msa*l_hu_age30_40

label var cc_chat          "Central City $\times$ Condo Rate (predict)"
label var cc_l_hu_age30_40  "Central City $\times$ Age of Housing 30+ (1970)"
label var l_hu_age30_40    "Age of Housing 30+ (1970)"
label var loc_ord_chat     "MSA with Ord $\times$ Condo Rate (predict)"
label var loc_hu_age30_40  "MSA with Ord $\times$ Age of Housing 30+ (1970)"
label var loc_ord_msa      "MSA with Ord"

global yy  = "lminc emp educ_b marshr shrwht age35_65 age65pl"

gen d_lminc    = D.lminc
gen d_emp      = D.emp
gen d_educ_b   = D.educ_b
gen d_marshr   = D.marshr
gen d_shrwht   = D.shrwht
gen d_age35_65 = D.age35_65
gen d_age65pl  = D.age65pl

label var d_lminc    "Ln Mean Inc"
label var d_emp      "Employment"
label var d_educ_b   "Bach Deg"
label var d_marshr   "Share Married"
label var d_shrwht   "Share Wht"
label var d_age35_65 "Age 35 - 65"
label var d_age65pl  "Age 65+"

clear matrix

foreach v of varlist $yy {

eststo: reg d_`v' cc_status chat_tobit cc_chat              if loc_ord_msa == 1 & time !=. , r
eststo: reg d_`v' cc_status l_hu_age30_40 cc_l_hu_age30_40  if loc_ord_msa == 1 & time !=. , r
eststo: reg d_`v' loc_ord_msa chat_tobit loc_ord_chat       if cc_status == 1   & time != ., r
eststo: reg d_`v' loc_ord_msa l_hu_age30_40 loc_hu_age30_40 if cc_status == 1   & time != ., r 

#delimit ;
esttab using "$out\dd_hi_`v'.tex", replace label 
title("Diff-in-Diff with Condo Conversion Interactions") se brackets
order(cc_status loc_ord_msa chat_tobit l_hu_age30_40 cc_chat cc_l_hu_age30_40 loc_ord_chat loc_hu_age30_40) keep(cc_status loc_ord_msa chat_tobit cc_chat l_hu_age30_40 cc_l_hu_age30_40 loc_ord_chat loc_hu_age30_40)
addnote("Tracts are indexed by time (pre and post ordinance), MSA status (if there was ever a local ordinance re condos),"
"and central city status (meaning if local ordinance in MSA is relevant)." 
"(1) and (2) Limited to MSA with Local Ord at some point in time." 
 "(3) and (4) Limited to Central City.") 
r2 nocons ;

#delimit cr

clear matrix

}
xx
*/
**Boundary Analysis

global min_d = 200
global max_d = 3000
global step  = 200

global n_d = ($max_d+$step-$min_d)/$step + 1

global max_p1 = $max_d+$step

gen bound_$max_p1 = 1

mat coeff_dd  = J($n_d, 7, .)
mat se_dd     = J($n_d, 7, .)
mat coeff_ddd = J($n_d, 7, .)
mat se_ddd    = J($n_d, 7, .)

local r = 1
local c = 1

foreach v of varlist $yy {

forvalues d = 200(200)3200 { 

eststo: reg `v' cc_status post post_cc if loc_ord_msa == 1 & bound_`d' == 1, r

mat b = e(b)
mat var = vecdiag(e(V))
mat coeff_dd[`c', `r'] = b[1,3]
mat se_dd[`c', `r'] = sqrt(var[1,3]) 

*eststo: reg `v' cc_status post post_cc if loc_ord_msa == 0 & bound_`d' == 1, r
eststo: reg `v' cc_status loc_ord_msa post post_cc post_loc_ord cc_loc_ord cc_loc_ord_post if bound_`d' == 1, r   

mat b = e(b)
mat var = vecdiag(e(V))
mat coeff_ddd[`c', `r'] = b[1,7]
mat se_ddd[`c', `r'] = sqrt(var[1,7])  

local c = `c' + 1

}

local r = `r' + 1
local c = 1

}

svmat coeff_dd
svmat se_dd
svmat coeff_ddd
svmat se_ddd

forvalues y = 1/7 {

gen ci_low_dd`y'  = coeff_dd`y' - 2*se_dd`y' 
gen ci_high_dd`y' = coeff_dd`y' + 2*se_dd`y'
gen ci_low_ddd`y'  = coeff_ddd`y' - 2*se_ddd`y' 
gen ci_high_ddd`y' = coeff_ddd`y' + 2*se_ddd`y'

}

gen dist = .
forvalues d = 1/16 {
replace dist = 200*`d' if _n == `d'
}

gen var_names = ""
replace var_names = "Log Mean Inc"      if _n == 1
replace var_names = "Employment"        if _n == 2
replace var_names = "At Least Bach Deg" if _n == 3
replace var_names = "Share Married"     if _n == 4
replace var_names = "Share White"       if _n == 5
replace var_names = "Age 35 - 65"       if _n == 6
replace var_names = "Age 65+" if _n == 7



forvalues y = 1/7 {

local t = var_names[`y']
local title = "DD for " + "`t'" + " by Distance from Boundary"

#delimit ;
twoway connected ci_low_dd`y' coeff_dd`y' ci_high_dd`y' dist if dist < 3500 & dist != .,
name(bound_`y', replace)
title(`title')
xtitle("Distance from Boundary (meters)")
ytitle("DD Estimate (Central  City vs Suburbs)")
xline(3100)
note("Value at $max_p1, after vertical line, corresponds to estimate including all tracts.")
legend(label(1 "95% CI Low") label(2 "DD Estimate") label(3 "95% CI High"))
lcolor(gray blue gray)
mcolor(gray blue gray)
lpattern(dash solid dash)  
graphregion(color(white)) bgcolor(white);
#delimit cr

graph export "$out\bound_`y'.png", replace name(bound_`y')

}

drop ci* coeff* se*
drop dist bound_$max_p1

xx
