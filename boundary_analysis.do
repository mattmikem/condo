****************************************************
*DD/IV Framework for Analysis at Boundary
*M. Miller, 16S

*This program is very similar to 'dd_iv_analysis.do'
*but hones in on boundary as experimental region

*****************************************************

cd "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"

capture log close

clear
clear matrix
clear mata

set more off

set maxvar 30000

global data  = "L:\Research\Condos\Data"
global work  = "L:\Research\Condos\Working Data"
global out   = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Output\05-18-2016"
global pro   = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Programs"
global cc    = "L:\Research\Resurgence\Working Files"

global thr_u = 50
global thr_l = 0
global N = $thr_u
quietly do "$pro\for_dd_iv_build.do"

***OBS LEVEL STABLE

use "$cc\city_centers.dta"

destring geo2010, replace

keep ua_code geo2010 cc_*

save cc, replace

use "$work\condo_full.dta"

joinby geo2010 using cc, unmatched(master)

**DDD Analysis on Condos

*drop if LocalOrdMsa == .

*Post Restriction (A) (see (B) below)

gen post = 0

replace post = 1 if year > Date1 & Date1 != .
replace post = 1 if year > 1980  & Date1 == .
replace post = 1 if year > 1980  & Date1 > 2010

**Without condo percentages in each year, just need pre year and post

local b = 1970

*replace post = 1 if year == 2010

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

keep if year == 1970 | year == 1980 | year == 1990 | year == 2000 | year == 2010

*Start with effect on condo rates

replace cond_pct = 0 if year == 1970 | year == 1980

#delimit ;

global x_p = "own munit1a munit2_4 munit5pl mbed1 mbed2 mbed3 mbed4pl 
			  hu_age10_20 hu_age20_30 hu_age30_40 vachu trvlpb wkhome 
			  auto";

#delimit cr

label var vachu    "Vacant Units"
label var trvlpb   "Commute by Public Transit"
label var wkhome   "Work at Home"
label var auto     "Commute by Car"
label var top_city "Central City"

*Washes out Newark :(

replace top_city = 0 if loc_ord == 0 & loc_ord_msa == 1

eststo: estpost tabstat $x_p if year == 1970 & loc_ord_msa == 1 & bound_dist == 0, by(top_city) statistics(mean sd count) columns(statistics) nototal 
eststo: estpost tabstat $x_p if year == 1970 & loc_ord_msa == 0 & bound_dist == 0, by(top_city) statistics(mean sd count) columns(statistics) nototal

*eststo: estpost tabstat $tab1_vars, by(hi_iq) statistics(mean sd count) columns(statistics)

#delimit ;
esttab est* using "$out\cvars_means_1.tex", 
replace main(mean) aux(sd) label
title("Covariate Means in 1970 - Tracts at the Boundary (1 in city, 0 in suburbs)") nostar unstack mlabel("Ordiance Cities" "Non-Ordinance Cities")
addnotes("Limited to tracts that abut the central city boundary."); 
#delimit cr

clear matrix

eststo: estpost ttest $x_p if year == 1970 & loc_ord_msa == 1 & bound_dist == 0, by(top_city)
eststo: estpost ttest $x_p if year == 1970 & loc_ord_msa == 0 & bound_dist == 0, by(top_city)

#delimit ;

esttab est* using "$out\cvars_balance_1.tex",  
label title("Difference in Covariate Means in 1970 - Tracts at the Boundary (Diff is suburb minus city)") replace wide  
mlabel("Ordinance Cities" "Non-Ordinance Cities")
addnotes("Limited to tracts that abut the central city boundary.") ;
#delimit cr
clear matrix

/*
replace bound_dist = -1*bound_dist if top_city == 1

quietly sum bound_dist, d

local min_d = r(p5)
local max_d = r(p90)

#delimit ;
twoway 
(lpolyci cond_pct bound_dist if loc_ord_msa == 1 & year == 2010 & (bound_dist < 0 | (bound_dist == 0 & top_city == 1)) & bound_dist > `min_d', lcolor(blue))
(lpolyci cond_pct bound_dist if loc_ord_msa == 1 & year == 2010 & (bound_dist > 0 | (bound_dist == 0 & top_city == 0)) & bound_dist < `max_d', lcolor(blue))
(lpolyci cond_pct bound_dist if loc_ord_msa == 0 & year == 2010 & (bound_dist < 0 | (bound_dist == 0 & top_city == 1)) & bound_dist > `min_d', lcolor(orange))
(lpolyci cond_pct bound_dist if loc_ord_msa == 0 & year == 2010 & (bound_dist > 0 | (bound_dist == 0 & top_city == 0)) & bound_dist < `max_d', lcolor(orange)),
xline(0) xscale(range(`min_d' `max_d'));
#delimit cr
*/

**Boundary Analysis*************************************************************

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

**Analysis for ownership (to exploit timing)

gen post_top         = top_city*post
gen post_loc_ord_msa = loc_ord_msa*post
gen post_loc_ord     = loc_ord*post

gen top_conf = 0
replace top_conf = 1 if top_city == 0 & loc_ord == 1

forvalues d = 200(200)3200 { 

*eststo: reg cond_pct cc_status loc_ord_msa cc_loc_ord if year == 2010 & bound_dist <= `d', r
*eststo: reg cond_pct top_city  loc_ord_msa loc_ord  if year == 2010 & bound_dist <= `d', r

eststo: reg own top_city loc_ord_msa post post_top post_loc_ord_msa post_loc_ord if bound_dist <= `d' & l4_munit5pl > 0.55 & top_conf == 0

mat b = e(b)
mat var = vecdiag(e(V))
mat coeff_dd[`c', `r'] = b[1,6]
mat se_dd[`c', `r'] = sqrt(var[1,6]) 

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

local title = "DDD for Ownership Rates by Distance from Boundary"

#delimit ;
twoway connected ci_low_dd coeff_dd ci_high_dd dist if dist < 3500 & dist != .,
name(bound_cond, replace)
title(`title')
xtitle("Distance from Boundary (meters)")
ytitle("DDD Estimate on Ownership")
xline(3100)
note("Value at $max_p1, after vertical red line, corresponds to estimate including all tracts." "Includes tracts where more than half of the structures contain more than five units.")
legend(label(1 "95% CI Low") label(2 "DD Estimate") label(3 "95% CI High"))
lcolor(gray blue gray)
mcolor(gray blue gray)
lpattern(dash solid dash)  
graphregion(color(white)) bgcolor(white);
#delimit cr

graph export "$out\bound_cond.png", replace name(bound_cond)

sum coeff se

drop ci* coeff* se*

clear matrix
xx
**Additional estimates

eststo: reg own post top_city loc_ord_msa post_top post_loc_ord_msa post_loc_ord if bound_dist < 1600 & l4_munit5pl > 0.55, r
eststo: reg own post loc_ord post_loc_ord if top_city == 1 & bound_dist < 1600, r
eststo: reg own post loc_ord post_loc_ord if cc_2 == 1, r
eststo: reg own post loc_ord post_loc_ord if cc_1 == 1,r

label var post_loc_ord "Local Ordinance $\times$ Post"

#delimit ;
esttab using "$out\own_reg.tex", replace label 
title("Effects of Ordinances on Ownership") se brackets
order(post_loc_ord) keep(post_loc_ord)
mtitle("DDD" "City tracts at Boundary" "City Center (lax)" "City Center (strict)")
addnote("Tracts are indexed by time (pre and post ordinance) and regulatory status (if there was ever a local ordinance re condos)." ) 
r2 nocons ;

#delimit cr

clear matrix


**Explore condo versus ownership a bit more.

xtile munit5pl_tile = l4_munit5pl, nq(10)

xx


*drop dist bound_$max_p1
/*
#delimit ;
esttab using "$out\dd_iv_d`y'.tex", replace label 
title("`title'") se brackets
addnote("Limited to tracts within `d' m of central city boundary." "Estimates include controls for lag `lt', local housing stock, and commuting characteristics." "Robust standard errors.")
order(cond_pct) keep(cond_pct)
mtitle("OLS" "2SLS: Pred Condo \& Local Ord")
nocons ;
#delimit cr
*/

clear matrix

**IV

foreach y of varlist $yy {

gen d`y' = D.`y'
gen l`y' = L.`y'

}

gen var_names = ""
replace var_names = "Log Mean Income"             if _n == 1
replace var_names = "Share with Bachelors Degree" if _n == 2
replace var_names = "Share White"                 if _n == 3

local j = 1

local d = 200
local lag = 4

foreach y in $yy {

eststo: reg d`y' cond_pct   $x_p                                                 if bound_dist < `d' & year == 2010, r
	
eststo: ivregress 2sls d`y' (cond_pct = top_city loc_ord_msa loc_ord)            if bound_dist < `d' & year == 2010, vce(r)
estat overid


local t = var_names[`j']
local title = "Effect of Condoization on "+ "`t'"
local lt = lower("`t'")

#delimit ;
esttab using "$out\dd_iv_`y'.tex", replace label 
title("`title'") se brackets
addnote("Limited to tracts within `d' m of central city boundary." "Estimates include controls for lag `lt'." "Robust standard errors.")
order(cond_pct) keep(cond_pct)
mtitle("OLS" "2SLS: Pred Condo \& Local Ord")
nocons ;

#delimit cr

local j = `j' + 1

clear matrix

}

