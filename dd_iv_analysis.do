*********************************************
*DD/IV Framework for Analysis, incl. Boundary
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
global out   = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Output\04-26-2016"
global pro   = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Programs"

global thr_u = 101
global thr_l = 0
global N = $thr_u
quietly do "$pro\for_dd_iv_build.do"

***OBS LEVEL STABLE

use "$work\condo_full.dta"

**DDD Analysis on Condos

*drop if LocalOrdMsa == .

*Post Restriction (A) (see (B) below)

gen post = 0

*replace post = 1 if year > reg_year & reg_year != .
*replace post = 1 if year > 1980 & reg_year == .
*replace post = 1 if year > 1980 & reg_year > 2010

**Without condo percentages in each year, just need pre year and post

local b = 1970

replace post = 1 if year == 2010

**Local city regulation

gen     loc_ord = 0
replace loc_ord = 1 if Rank1 > 0 & Rank1 != .

gen loc_ord_msa = 0
*replace loc_ord_msa = 1 if LocalOrdMsa > 3 & LocalOrdMsa != .
replace loc_ord_msa = 1 if msa_w_ord == 1 & msa_w_ord != .

*gen post_cc         = post*cc_status
*gen post_loc_ord    = post*loc_ord_msa 
*gen cc_loc_ord      = cc_status*loc_ord_msa
*gen cc_loc_ord_post = cc_status*loc_ord_msa*post

*label var post_loc_ord     "Post-Condo Ord $\times$ MSA with Condo Ordinance"
*label var post_cc          "Post-Condo Ord $\times$ Central City Tract"
*label var cc_loc_ord_post  "Post-Condo Ord $\times$ CC Tract $\times$ MSA with Condo Ord"

keep if year == 1970 | year == 1980 | year == 2010

*Start with effect on condo rates

replace cond_pct = 0 if year == 1970 | year == 1980

/*
eststo: reg cond_pct cc_status post post_cc        if (loc_ord_msa == 1 & year == `b') | (loc_ord_msa == 1 & year == 2010), r
eststo: reg cond_pct cc_status post post_cc        if (loc_ord_msa == 0 & year == `b') | (loc_ord_msa == 0 & year == 2010), r
eststo: reg cond_pct loc_ord_msa post post_loc_ord if (cc_status == 1 & year == `b')   | (cc_status == 1 & year == 2010), r
eststo: reg cond_pct loc_ord_msa post post_loc_ord if (cc_status == 0 & year == `b')   | (cc_status == 0 & year == 2010), r
eststo: reg cond_pct cc_status loc_ord_msa post post_cc post_loc_ord cc_loc_ord cc_loc_ord_post if (year == `b' | year == 2010), r  

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
*/
#delimit ;

global x_p = "own munit1a munit2_4 munit5pl mbed1 mbed2 mbed3 mbed4pl 
			  hu_age10_20 hu_age20_30 hu_age30_40 hu_age40pl vachu trvlpb wkhome 
			  auto";

#delimit cr

*global x_p = ""

* commut25 commut25_45 commut45pl

*Washes out Newark :(

replace top_city = 0 if loc_ord == 0 & loc_ord_msa == 1

**Boundary Analysis

global min_d = 200
global max_d = 3000
global step  = 200

global n_d = ($max_d+$step-$min_d)/$step + 1

global max_p1 = $max_d+$step

replace bound_dist = $max_p1 if bound_dist > $max_d

gen bound_$max_p1 = 1

mat coeff_dd  = J($n_d, 1, .)
mat se_dd     = J($n_d, 1, .)
mat coeff_ddd = J($n_d, 1, .)
mat se_ddd    = J($n_d, 1, .)

local r = 1
local c = 1

forvalues d = 200(200)3200 { 

*eststo: reg cond_pct cc_status loc_ord_msa cc_loc_ord if year == 2010 & bound_dist <= `d', r
eststo: reg cond_pct top_city  loc_ord_msa loc_ord  if year == 2010 & bound_dist <= `d', r

mat b = e(b)
mat var = vecdiag(e(V))
mat coeff_dd[`c', `r'] = b[1,3]
mat se_dd[`c', `r'] = sqrt(var[1,3]) 

*eststo: reg `v' cc_status post post_cc if loc_ord_msa == 0 & bound_`d' == 1, r

local c = `c' + 1

}

*local r = `r' + 1
*local c = 1

svmat coeff_dd
svmat se_dd

gen ci_low_dd   = coeff_dd - 2*se_dd 
gen ci_high_dd  = coeff_dd + 2*se_dd

gen dist = .
forvalues d = 1/16 {
replace dist = 200*`d' if _n == `d'
}

local title = "DD for Condo Rates by Distance from Boundary"

#delimit ;
twoway connected ci_low_dd coeff_dd ci_high_dd dist if dist < 3500 & dist != .,
name(bound_cond, replace)
title(`title')
xtitle("Distance from Boundary (meters)")
ytitle("DD Estimate (Central  City vs Suburbs)")
xline(3100)
note("Value at $max_p1, after vertical red line, corresponds to estimate including all tracts.")
legend(label(1 "95% CI Low") label(2 "DD Estimate") label(3 "95% CI High"))
lcolor(gray blue gray)
mcolor(gray blue gray)
lpattern(dash solid dash)  
graphregion(color(white)) bgcolor(white);
#delimit cr

graph export "$out\bound_cond.png", replace name(bound_cond)

sum coeff se

drop ci* coeff* se*
drop dist bound_$max_p1

clear matrix

**Now with predicted condo rates.

******************************************************
**Include propensity for condo (chat and housing age)
******************************************************

*drop l_hu_age30_40

local lag = 4

gen post_cc_chat     = post*cc_status*chat_l`lag'_st
*gen post_cc_hous = post*cc_status*hu_age30_40
gen cc_chat          = cc_status*chat_l`lag'_st
gen loc_ord_msa_chat = loc_ord_msa*chat_l`lag'_st

gen tc_chat          = top_city*chat_l`lag'_st
gen loc_ord_chat     = loc_ord*chat_l`lag'_st

gen time = .
replace time = 0 if year == 2010 - `lag'*10
replace time = 1 if year == 2010

*gen l_hu_age30_40   = L.hu_age30_40
*gen cc_l_hu_age     = cc_status*l`lag'_hu_age30_40
*gen loc_hu_age      = loc_ord_msa*l`lag'_hu_age30_40
*gen loc_cc_l_hu_age = loc_ord_msa*cc_status*l`lag'_hu_age30_40    

label var cc_chat              "Central City $\times$ Condo Rate (predict)"
*label var cc_l_hu_age30_40  "Central City $\times$ Age of Housing 30+ (1970)"
*label var l_hu_age30_40    "Age of Housing 30+ (1970)"
label var loc_ord_msa_chat     "MSA with Ord $\times$ Condo Rate (predict)"
*label var loc_hu_age30_40  "MSA with Ord $\times$ Age of Housing 30+ (1970)"
label var loc_ord_msa          "MSA with Ord"
label var loc_ord              "City with Ord"
label var tc_chat              "City $\times$ Condo Rate (predict)"
label var loc_ord_chat         "City with Ord $\times$ Condo Rate (predict)" 

*tab PLACENAME loc_ord if sup_el < 1.1 & top_city == 1

gen loc_cc_chat = loc_ord_msa*cc_status*chat_l`lag'_st
gen loc_cc      = loc_ord_msa*cc_status  

gen     st_ord = 0
replace st_ord = 1 if st_rank2 > 0

label var loc_cc      "MSA with Ord $\times$ CC"
label var loc_cc_chat "MSA with Ord $\times$ CC $\times $ Condo Rate (pred)"
*label var loc_cc_l_hu_age "MSA with Ord $\times$ CC $\times $ Age Housing"

**Condo Prediction

*Changes

xtset geo2010 time	

*global yy = "age35_65 age65pl"

foreach y of varlist $yy {

gen d`y' = D.`y'
gen l`y' = L.`y'

}

forvalues d = 200(600)2000 {
*eststo: reg cond_pct cc_status loc_ord_msa chat_l`lag'_st loc_cc loc_cc_chat $x_p if year == 2010 & bound_d < `d'
eststo: reg cond_pct top_city loc_ord_msa chat_l`lag'_st loc_ord loc_ord_chat leduc_b lminc lshrwht $x_p if year == 2010 & bound_dist < `d'

if `d' == 200 {

mat b = e(b)

global hstar = b[1,5]/(-1*b[1,6])

disp $hstar
}
}

eststo: reg cond_pct top_city loc_ord_msa chat_l`lag'_st loc_ord loc_ord_chat leduc_b lminc lshrwht $x_p if year == 2010, r
*eststo: reg cond_pct cc_status loc_ord_msa chat_l`lag'_st loc_cc loc_cc_chat $x_p if year == 2010, r

#delimit ;
esttab using "$out\dd_hi_cond.tex", replace label 
title("Diff-in-Diff with Condo Conversion Interactions") se brackets
order(chat_l`lag'_st loc_ord loc_ord_chat) keep(chat_l`lag'_st loc_ord loc_ord_chat)
mtitle("200 m" "800 m" "1400 m" "2000 m" "All") 
addnote("Additional controls include characteristics of the neighborhood housing stock, commuting characteristics," "and lags of mean income, education, and share white.")
r2;

#delimit cr

clear matrix

***By Propensity Quartile

xtile chat_tile = chat_l`lag'_st, nq(4)

local d = 1600

sum sup_el

local m = 2

gen hes_cat = ""
replace hes_cat = "Inelastic Housing" if sup_el < `m'
replace hes_cat = "Elastic Housing" if sup_el >= `m' 
*& sup_el < 2.5
*replace hes_cat = "Elastic (high) Housing" if sup_el >= 2.5

forvalues p = 1/4 {
*eststo: reg cond_pct cc_status loc_ord_msa chat_l`lag'_st loc_cc loc_cc_chat $x_p if year == 2010 & bound_d < `d'
eststo: reg cond_pct top_city loc_ord_msa chat_l`lag'_st loc_ord loc_ord_chat leduc_b lminc lshrwht $x_p if year == 2010 & bound_dist < `d' & chat_tile == `p'
}

#delimit ;
esttab using "$out\dd_hi_cond_chattile.tex", replace label 
title("Diff-in-Diff with Condo Conversion Interactions (by Propensity Quartile)") se brackets
order(chat_l`lag'_st loc_ord loc_ord_chat) keep(chat_l`lag'_st loc_ord loc_ord_chat)
mtitle("Q1" "Q2" "Q3" "Q4") 
addnote("Additional controls include characteristics of the neighborhood housing stock, commuting characteristics," "and lags of mean income, education, and share white." "Limited to tracts within `d' meters of boundary.")
r2;

#delimit cr

clear matrix

local lag = 4
local d   = 1600

*"Elastic (high) Housing" 
foreach e in "Inelastic Housing" "Elastic Housing"  {
*eststo: reg cond_pct cc_status loc_ord_msa chat_l`lag'_st loc_cc loc_cc_chat $x_p if year == 2010 & bound_d < `d'
eststo: reg cond_pct top_city loc_ord_msa chat_l`lag'_st loc_ord loc_ord_chat leduc_b lminc lshrwht $x_p if year == 2010 & bound_dist < `d' & hes_cat == "`e'"
}

#delimit ;
esttab using "$out\dd_hi_cond_chathes.tex", replace label 
title("Diff-in-Diff with Condo Conversion Interactions (by Housing Supply Elasticity)") se brackets
order(chat_l`lag'_st loc_ord loc_ord_chat) keep(chat_l`lag'_st loc_ord loc_ord_chat)
mtitle("Inelastic Housing" "Elastic Housing") 
addnote("Additional controls include characteristics of the neighborhood housing stock, commuting characteristics," 
"and lags of mean income, education, and share white." "Limited to tracts within `d' meters of boundary." 
"Elasticities from Saiz (2010)." "Elasticity threshold is `m'.")
r2;

#delimit cr

clear matrix

**More detailed supply elasticity estimates:

local lag = 4

gen chat_sup_el = chat_l`lag'*sup_el
gen ord_sup_el  = loc_ord*sup_el
gen loc_ord_chat_sup_el = loc_ord_chat*sup_el

label var sup_el      "Supply Elasticity"
label var chat_sup_el "Condo Pct (pred) $\times$ Supply Elas"
label var ord_sup_el  "Ordinance $\times$ Supply Elas"
label var loc_ord_chat_sup_el "Condo Pct (pred) $\times$ Ordinance $\times$ Supply Elas"
 
forvalues dd = 800(800)3200 {

eststo: reg cond_pct chat_l`lag' sup_el loc_ord  chat_sup_el ord_sup_el loc_ord_chat loc_ord_chat_sup_el if year == 2010 & bound_dist < `dd', r 

}

#delimit ;
esttab using "$out\dd_hi_supply.tex", replace label 
title("Condo Rates by Ordinance and Supply Elasticity") se brackets
mtitle("800 m" "1600 m" "2400 m" "All") 
addnote("Additional controls include characteristics of the neighborhood housing stock, commuting characteristics," "and lags of mean income, education, and share white." "Limited to tracts within `d' meters of boundary.")
r2;

#delimit cr

clear matrix


*order(chat_l`lag'_st loc_ord loc_ord_chat) keep(chat_l`lag'_st loc_ord loc_ord_chat)

xx
*order(chat_l`lag'_st loc_cc loc_cc_chat) keep(chat_l`lag'_st  loc_cc loc_cc_chat)

*kdensity chat_l`lag'_st, 
*xline($hstar) name(hstar,replace)
*title("Density of Predict Condo Rates")
*note("Line at {&phi}{subscript:1}{superscript:0}/{&phi}{subscript:1}{superscript:1}")
*graphregion(color(white)) bgcolor(white);

**Age of Housing Stock (focus on conversion)
/*
forvalues d = 200(600)2000 {
eststo: reg cond_pct cc_status loc_ord_msa l4_hu_age30_40 loc_cc loc_cc_l_hu_age $x_p if year == 2010 & bound_`d' == 1
if `d' == 200 {

mat b = e(b)

global hstar = b[1,5]/(-1*b[1,6])

disp $hstar
}
}


eststo: reg cond_pct cc_status loc_ord_msa l4_hu_age30_40 loc_cc loc_cc_l_hu_age $x_p if year == 2010

#delimit ;
esttab using "$out\dd_hi_huage.tex", replace label 
title("Diff-in-Diff with Age of Housing Interactions") se brackets
order(l`lag'_hu_age30_40 loc_cc loc_cc_l_hu_age) keep(l`lag'_hu_age30_40 loc_cc loc_cc_l_hu_age)
mtitle("200 m" "800 m" "1400 m" "2000 m" "All") 
addnote("Additional controls include characteristics of the neighborhood housing stock.")
r2;

*kdensity chat_l`lag'_st, 
*xline($hstar) name(hstar,replace)
*title("Density of Predict Condo Rates")
*note("Line at {&phi}{subscript:1}{superscript:0}/{&phi}{subscript:1}{superscript:1}")
*graphregion(color(white)) bgcolor(white);


#delimit cr

clear matrix
*/

**IV Estimats

*Levels

gen var_names = ""
replace var_names = "Log Mean Income"             if _n == 1
replace var_names = "Share with Bachelors Degree" if _n == 2
replace var_names = "Share White"                 if _n == 3

local j = 1

local d = 2400

foreach y in $yy {

eststo: reg `y' cond_pct   $x_p                                                              if bound_dist < `d' & year == 2010, r
/*
eststo: ivregress 2sls `y' $x_p (cond_pct = chat_l`lag'_st)                                  if bound_dist < `d' & year == 2010, vce(r)
eststo: ivregress 2sls `y' $x_p (cond_pct = cc_status loc_ord_msa loc_cc)                    if bound_dist < `d' & year == 2010, vce(r)
estat overid
eststo: ivregress 2sls `y' $x_p (cond_pct = cc_status loc_ord_msa chat_l`lag'_st loc_cc loc_cc_chat) if bound_dist < `d' & year == 2010, vce(r)
estat overid
*/
eststo: ivregress 2sls `y' $x_p  (cond_pct = chat_l`lag'_st)                                  if bound_dist < `d' & year == 2010, vce(r)
eststo: ivregress 2sls `y' $x_p  (cond_pct = top_city loc_ord_msa loc_ord)                    if bound_dist < `d' & year == 2010, vce(r)
estat overid
eststo: ivregress 2sls `y' $x_p  top_city loc_ord_msa chat_l`lag'_st loc_ord (cond_pct = loc_ord_chat) if bound_dist < `d' & year == 2010, vce(r)
*estat overid

local t = var_names[`j']
local title = "Effect of Condoization on "+ "`t'"

#delimit ;
esttab using "$out\dd_iv_`y'.tex", replace label 
title("`title'") se brackets
addnote("Limited to tracts within `d' m of central city boundary." "Estimates include controls for local housing stock, robust standard errors.")
order(cond_pct) keep(cond_pct)
mtitle("OLS" "2SLS: Pred Condo" "{\color{red} 2SLS: Local Ord}" "2SLS: Pred Condo \& Local Ord")
nocons ;

#delimit cr

local j = `j' + 1

clear matrix

}

local j = 1

*local d = 2000
*local lag = 4

foreach y in $yy {

eststo: reg `y' l`y' cond_pct   $x_p                                                               if bound_dist < `d' & year == 2010, r

/*
eststo: ivregress 2sls d`y' $x_p (cond_pct = chat_l`lag'_st)                                   if bound_dist < `d' & year == 2010, vce(r)
eststo: ivregress 2sls d`y' $x_p (cond_pct = cc_status loc_ord_msa loc_cc)                     if bound_dist < `d' & year == 2010, vce(r)
estat overid
eststo: ivregress 2sls d`y' $x_p (cond_pct = cc_status loc_ord_msa chat_l`lag'_st loc_cc loc_cc_chat) if bound_dist < `d' & year == 2010, vce(r)
estat overid
*/

*eststo: ivregress 2sls `y' l`y' $x_p (cond_pct = chat_l`lag'_st)                                   if bound_dist < `d' & year == 2010, vce(r)
*eststo: ivregress 2sls `y' l`y' $x_p (cond_pct = top_city loc_ord_msa loc_ord)                     if bound_dist < `d' & year == 2010, vce(r)
*estat overid
eststo: ivregress 2sls `y' l`y' $x_p top_city loc_ord_msa chat_l`lag'_st loc_ord (cond_pct =  loc_ord_chat) if bound_dist < `d' & year == 2010, vce(r)
*estat overid

local t = var_names[`j']
local title = "Effect of Condoization on "+ "`t'"
local lt = lower("`t'")

#delimit ;
esttab using "$out\dd_iv_d`y'.tex", replace label 
title("`title'") se brackets
addnote("Limited to tracts within `d' m of central city boundary." "Estimates include controls for lag `lt', local housing stock, and commuting characteristics." "Robust standard errors.")
order(cond_pct) keep(cond_pct)
mtitle("OLS" "2SLS: Pred Condo \& Local Ord")
nocons ;

#delimit cr

local j = `j' + 1

clear matrix

}

**Boundary Analysis (IV)

*Lazy set up, need to move manually through outcomes.

local j = 1

foreach y of varlist $yy {

global min_d = 200
global max_d = 3000
global step  = 200

global n_d = ($max_d+$step-$min_d)/$step + 1

global max_p1 = $max_d+$step

replace bound_dist = $max_p1 if bound_dist > $max_d

*gen bound_$max_p1 = 1

mat coeff_dd  = J($n_d, 1, .)
mat se_dd     = J($n_d, 1, .)
mat coeff_ddd = J($n_d, 1, .)
mat se_ddd    = J($n_d, 1, .)

local r = 1
local c = 1

local lag = 4

forvalues d = 200(200)3200 { 

*eststo: reg cond_pct cc_status loc_ord_msa cc_loc_ord if year == 2010 & bound_dist <= `d', r
eststo: ivregress 2sls `y' l`y' $x_p top_city loc_ord_msa chat_l`lag'_st loc_ord (cond_pct = loc_ord_chat) if bound_dist < `d' & year == 2010, vce(r)

mat b = e(b)
mat var = vecdiag(e(V))
mat coeff_dd[`c', `r'] = b[1,1]
mat se_dd[`c', `r'] = sqrt(var[1,1]) 

*eststo: reg `v' cc_status post post_cc if loc_ord_msa == 0 & bound_`d' == 1, r

local c = `c' + 1

}

*local r = `r' + 1
*local c = 1

svmat coeff_dd
svmat se_dd

gen ci_low_dd   = coeff_dd - 2*se_dd 
gen ci_high_dd  = coeff_dd + 2*se_dd

gen dist = .
forvalues d = 1/16 {
replace dist = 200*`d' if _n == `d'
}

local t = var_names[`j']

local title = "DD-IV for `t' by Distance from Boundary"

#delimit ;
twoway connected ci_low_dd coeff_dd ci_high_dd dist if dist < 3500 & dist != .,
name(bound_`y', replace)
title(`title')
xtitle("Distance from Boundary (meters)")
ytitle("IV Estimate")
xline(3100)
note("Value at $max_p1, after vertical red line, corresponds to estimate including all tracts.")
legend(label(1 "95% CI Low") label(2 "DD Estimate") label(3 "95% CI High"))
lcolor(gray blue gray)
mcolor(gray blue gray)
lpattern(dash solid dash)  
graphregion(color(white)) bgcolor(white);
#delimit cr

drop ci* coeff* se*
drop dist 

*bound_$max_p1
local j = `j' + 1

}



graph export "$out\bound_lminc.png", replace name(bound_lminc)
graph export "$out\bound_educ_b.png", replace name(bound_educ_b)
graph export "$out\bound_shrwht.png", replace name(bound_shrwht)

**Partitioning of Pre-period amounts

clear matrix

xtile mincp    = minc   if year == 1970, nq(4)
xtile lmincp   = lminc  if year == 1970, nq(4)
xtile edu_bp   = educ_b if year == 1970, nq(4)
xtile shrwhtp  = shrwht if year == 1970, nq(4) 

gen llmincp   = L.lmincp
gen leduc_bp  = L.edu_bp
gen lshrwhtp  = L.shrwhtp

local lag = 4

local j = 1

foreach y of varlist $yy {

forvalues p = 1/4 {

eststo: reg `y' cond_pct $x_p if year == 2010 & l`y'p == `p' , r
eststo: ivregress 2sls `y' $x_p top_city loc_ord_msa chat_l`lag'_st loc_ord (cond_pct = loc_ord_chat) if year == 2010 & l`y'p == `p', vce(r)

}

local t = var_names[`j']
local title = "Estimates on Change in "+ "`t' by Base Year Quartile"

#delimit ;
esttab using "$out\qu_dd_iv_d`y'.tex", replace label 
title("`title'") se brackets
addnote("Roman numeral indicates 1970 quartile of outcome variable." "No boundary limitation." "Estimates include controls for local housing stock, robust standard errors.")
order(cond_pct) keep(cond_pct)
mtitle("OLS (I)" "2SLS (I)" "OLS (II)" "2SLS (II)" "OLS (III)" "2SLS (III)" "OLS (IV)" "2SLS (IV)")
nocons ;

#delimit cr

local j = `j' + 1

clear matrix

}


**Reduced Form

local lag = 4
local d   = 2400

label var top_city "Primary or Secondary City"

eststo: reg lminc  llminc  top_city loc_ord_msa chat_l`lag'_st loc_ord loc_ord_chat $x_p if bound_dist < `d' & year == 2010, vce(r)
eststo: reg educ_b leduc_b top_city loc_ord_msa chat_l`lag'_st loc_ord loc_ord_chat $x_p if bound_dist < `d' & year == 2010, vce(r)
eststo: reg shrwht lshrwht top_city loc_ord_msa chat_l`lag'_st loc_ord loc_ord_chat $x_p if bound_dist < `d' & year == 2010, vce(r)

*estat overid

*local t = var_names[`j']
*local title = "Effect of Condoization on "+ "`t'"
*local lt = lower("`t'")

#delimit ;
esttab using "$out\rf_ddiv.tex", replace label 
title("Reduced Form") se brackets
addnote("Limited to tracts within `d' m of central city boundary." "Estimates include controls for lag d.v., local housing stock, and commuting characteristics." "Robust standard errors.")
order(top_city loc_ord_msa chat_l`lag'_st loc_ord loc_ord_chat) keep(top_city loc_ord_msa chat_l`lag'_st loc_ord loc_ord_chat)

nocons ;

#delimit cr

clear matrix


