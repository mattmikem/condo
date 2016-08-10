****************************************************
*DD/IV Framework for Analysis in City Center
*M. Miller, 16S

*This program is very similar to 'dd_iv_analysis.do'
*but hones in on city center as region of interest.

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
global out   = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Output\08-01-2016"
global pro   = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Programs"
global cc    = "L:\Research\Resurgence\Working Files"

global thr_u = 100
global thr_l = 0
global N = $thr_u
quietly do "$pro\for_dd_iv_build.do"

***OBS LEVEL STABLE

use "$cc\city_centers.dta"

destring geo2010, replace

keep ua_code geo2010 cc_*

sort geo2010 ua_code

duplicates drop geo2010, force

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

*gen p

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

global x_p = "munit1a munit2_4 munit5pl mbed1 mbed2 mbed3 mbed4pl 
			  hu_age10_20 hu_age20_30 hu_age30_40 vachu trvlpb wkhome 
			  auto";
global x_pb = "munit1a_base munit2_4_base munit5pl_base mbed1_base mbed2_base mbed3_base mbed4pl_base 
			  hu_age10_20_base hu_age20_30_base hu_age30_40_base vachu_base trvlpb_base wkhome_base 
			  auto_base";			  

#delimit cr

xtset geo2010 year, delta(10)

foreach y of varlist $yy {

gen d`y' = D.`y'
gen l`y' = L.`y'

}

foreach v of varlist $x_p {

gen `v'_base = .
replace `v'_base = `v'    if year == 1970
replace `v'_base = L.`v'  if year == 1980
replace `v'_base = L2.`v' if year == 1990
replace `v'_base = L3.`v' if year == 2000
replace `v'_base = L4.`v' if year == 2010

*global x_pb "$x_pb" " " "`v'_base"

}

**Analysis for ownership (to exploit timing)

gen post_top         = top_city*post
gen post_loc_ord_msa = loc_ord_msa*post
gen post_loc_ord     = loc_ord*post

gen top_conf = 0
replace top_conf = 1 if top_city == 0 & loc_ord == 1

label var vachu    "Vacant Units"
label var trvlpb   "Commute by Public Transit"
label var wkhome   "Work at Home"
label var auto     "Commute by Car"
label var top_city "Central City"

gen h_post_loc_ord = L.munit5pl*post_loc_ord

destring cbsa, gen(cbsa_num)
xtset cbsa_num

**Distributions

#delimit ;
kdensity chat_l4_st if cc_2 == 1, addplot(kdensity chat_l4_st if cc_1 == 1)
name(chat_dens, replace)
title("Density by Predicted Condo Propensity")
legend(order(1 "Lax" 2 "Strict"))
graphregion(color(white)) bgcolor(white);
kdensity popdens if cc_2 == 1, addplot(kdensity popdens if cc_1 == 1)
name(pd_dens, replace)
title("Density by Population Density")
legend(order(1 "Lax" 2 "Strict"))
graphregion(color(white)) bgcolor(white);
kdensity munit5pl if cc_2 == 1, addplot(kdensity munit5pl if cc_1 == 1)
name(munit5pl_dens, replace)
title("Density by Pct 5+ Units")
legend(order(1 "Lax" 2 "Strict"))
graphregion(color(white)) bgcolor(white);
#delimit cr

graph export "$out\chat_dens.png", replace name(chat_dens)
graph export "$out\pd_dens.png", replace name(pd_dens)
graph export "$out\munit5pl_dens.png", replace name(munit5pl_dens)

keep if lminc != . & educ_b != . & shrwht != .

*eststo: reg   own post_loc_ord i.year i.ua_code if cc_2 == 1, cluster(ua_code) 
eststo: xtreg own post_loc_ord i.year age*         if cc_2 == 1, fe vce(robust)
eststo: xtreg own post_loc_ord i.year age* $x_pb     if cc_2 == 1, fe vce(robust)
 
*eststo: reg   own post_loc_ord i.year i.ua_code if cc_1 == 1, cluster(ua_code) 
eststo: xtreg own post_loc_ord i.year age*          if cc_1 == 1, fe vce(robust)
eststo: xtreg own post_loc_ord i.year age* $x_pb     if cc_1 == 1, fe vce(robust)

*eststo: reg   own post loc_ord post_loc_ord      if cc_1 == 1, cluster(ua_code)
*eststo: xtreg own post loc_ord post_loc_ord      if cc_1 == 1, fe vce(robust)
*eststo: xtreg own post loc_ord post_loc_ord $x_p if cc_1 == 1, fe vce(robust)

label var post_loc_ord "Local Ordinance $\times$ Post"

#delimit ;
esttab using "$out\own_reg.tex", replace label 
title("Effects of Ordinances on Ownership (also, First Stage)") se brackets
order(post_loc_ord) keep(post_loc_ord)
mtitle("Lax" "Lax with X" "Strict" "Strict, with X" )
addnote("Limited to city center neighborhoods (lax or strict)." "All specifications include city and year fixed effects." "All specifications have clustered standard errors by city." "Controls X are for 1970 housing characteristics at the neighborhood level." 
"Top $thr_u cities are included.") 
r2 nocons star(+ .1 * 0.05 ** 0.01 *** 0.001);
#delimit cr

clear matrix

*eststo: reg   own post_loc_ord i.year i.ua_code if cc_2 == 1, cluster(ua_code) 
eststo: xtreg own post_loc_ord i.year           if cc_2 == 1, fe 
eststo: xtreg own post_loc_ord i.year $x_p      if cc_2 == 1, fe 
 
*eststo: reg   own post_loc_ord i.year i.ua_code if cc_1 == 1, cluster(ua_code) 
eststo: xtreg own post_loc_ord i.year           if cc_1 == 1, fe 
eststo: xtreg own post_loc_ord i.year $x_p      if cc_1 == 1, fe 

*eststo: reg   own post loc_ord post_loc_ord      if cc_1 == 1, cluster(ua_code)
*eststo: xtreg own post loc_ord post_loc_ord      if cc_1 == 1, fe vce(robust)
*eststo: xtreg own post loc_ord post_loc_ord $x_p if cc_1 == 1, fe vce(robust)

label var post_loc_ord "Local Ordinance $\times$ Post"

#delimit ;
esttab using "$out\own_reg_noclus.tex", replace label 
title("Effects of Ordinances on Ownership (also, First Stage) [no standard error adj]") se brackets
order(post_loc_ord) keep(post_loc_ord)
mtitle("Lax" "Lax with X" "Strict" "Strict, with X" )
addnote("Limited to city center neighborhoods (lax or strict)." "All specifications include city and year fixed effects." "These specifications have no standard error adjustment (for comparison)." "Controls X are for housing characteristics at the neighborhood level." 
"Top $thr_u cities are included.") 
r2 nocons star(+ .1 * 0.05 ** 0.01 *** 0.001);
#delimit cr

clear matrix

gen plo1980 = 0
gen plo1990 = 0
gen plo2000 = 0
gen plo2010 = 0

forvalues y = 1980(10)2010 {

replace plo`y' = 1 if Date1 < `y' & Date1 >= `y' - 10 & Rank1 > 0 & year > Date1
local y_1 = `y' - 10
label var plo`y' "Ord Passed between `y_1' and `y'"

}

*eststo: reg   own post_loc_ord i.year i.ua_code if cc_2 == 1, cluster(ua_code) 
eststo: xtreg own plo1980 plo1990 plo2000 plo2010 i.year           if cc_2 == 1, fe vce(robust)
eststo: xtreg own plo1980 plo1990 plo2000 plo2010 i.year $x_pb      if cc_2 == 1, fe vce(robust)
 
*eststo: reg   own post_loc_ord i.year i.ua_code if cc_1 == 1, cluster(ua_code) 
eststo: xtreg own plo1980 plo1990 plo2000 plo2010 i.year           if cc_1 == 1, fe vce(robust)
eststo: xtreg own plo1980 plo1990 plo2000 plo2010 i.year $x_pb      if cc_1 == 1, fe vce(robust)

*eststo: reg   own post loc_ord post_loc_ord      if cc_1 == 1, cluster(ua_code)
*eststo: xtreg own post loc_ord post_loc_ord      if cc_1 == 1, fe vce(robust)
*eststo: xtreg own post loc_ord post_loc_ord $x_p if cc_1 == 1, fe vce(robust)

label var post_loc_ord "Local Ordinance $\times$ Post"

#delimit ;
esttab using "$out\own_reg_plo.tex", replace label 
title("Effects of Ordinances on Ownership (Decomposition)") se brackets
order(plo*) keep(plo*)
mtitle("Lax" "Lax with X" "Strict" "Strict, with X" )
addnote("Limited to city center neighborhoods (lax or strict)." "All specifications include city and year fixed effects." "All specifications have cluster-robust standard (by city)." "Controls X are for 1970 housing characteristics at the neighborhood level." 
"Top $thr_u cities are included.") 
r2 nocons star(+ .1 * 0.05 ** 0.01 *** 0.001);
#delimit cr

clear matrix


**Steps by condo likelihood 

xtset geo2010 year, delta(10)

gen     pd_base = popdens
replace pd_base = L.popdens  if year == 1980
replace pd_base = L2.popdens if year == 1990
replace pd_base = L3.popdens if year == 2000
replace pd_base = L4.popdens if year == 2010

gen     munit5pl_base = munit5pl
replace munit5pl_base = L.munit5pl  if year == 1980
replace munit5pl_base = L2.munit5pl if year == 1990
replace munit5pl_base = L3.munit5pl if year == 2000
replace munit5pl_base = L4.munit5pl if year == 2010

gen     chat_base = chat_l4_st
replace chat_base = F.chat_l4_st  if year == 2000
replace chat_base = F2.chat_l4_st if year == 1990
replace chat_base = F3.chat_l4_st if year == 1980
replace chat_base = F4.chat_l4_st if year == 1970


**Distributions

label var chat_base     "Condo Propensity"
label var pd_base       "Pop Density"
label var munit5pl_base "Pct 5+ Units"

#delimit ;
kdensity chat_l4_st if cc_2 == 1, addplot(kdensity chat_l4_st if cc_1 == 1)
name(chat_dens, replace)
title("Density by Predicted Condo Propensity")
legend(order(1 "Lax" 2 "Strict"))
graphregion(color(white)) bgcolor(white);
kdensity popdens if cc_2 == 1, addplot(kdensity popdens if cc_1 == 1)
name(pd_dens, replace)
title("Density by Population Density")
legend(order(1 "Lax" 2 "Strict"))
graphregion(color(white)) bgcolor(white);
kdensity munit5pl if cc_2 == 1, addplot(kdensity munit5pl if cc_1 == 1)
name(munit5pl_dens, replace)
title("Density by Pct 5+ Units")
legend(order(1 "Lax" 2 "Strict"))
graphregion(color(white)) bgcolor(white);
#delimit cr

graph export "$out\chat_dens.png", replace name(chat_dens)
graph export "$out\pd_dens.png", replace name(pd_dens)
graph export "$out\munit5pl_dens.png", replace name(munit5pl_dens)

xtset cbsa_num

cut_reg pd_base       100 own "post_loc_ord i.year " post_loc_ord "cc_1 != 1000" "fe vce(robust)" "Effect by Population Density Restriction" "Population Density"
cut_reg chat_base     100 own "post_loc_ord i.year " post_loc_ord "cc_1 != 1000" "fe vce(robust)" "Effect by Condo Propensity Restriction" "Condo Propensity"
cut_reg munit5pl_base 100 own "post_loc_ord i.year " post_loc_ord "cc_1 != 1000" "fe vce(robust)" "Effect by Pct 5+ Unit Restriction" "Pct 5+ Units"

graph export "$out\pd_base.png", replace name(pd_base)
graph export "$out\chat_base.png", replace name(chat_base)
graph export "$out\munit5pl_base.png", replace name(munit5pl_base)

**Limit to 1980+
/*
eststo: reg own post loc_ord post_loc_ord      if cc_2 == 1 & year != 1970, r
eststo: reg own post loc_ord post_loc_ord $x_p if cc_2 == 1 & year != 1970, r
eststo: reg own post loc_ord post_loc_ord      if cc_1 == 1 & year != 1970, r
eststo: reg own post loc_ord post_loc_ord $x_p if cc_1 == 1 & year != 1970, r

label var post_loc_ord "Local Ordinance $\times$ Post"

#delimit ;
esttab using "$out\own_reg_no70.tex", replace label 
title("Effects of Ordinances on Ownership (also, First Stage for Change regressions)") se brackets
order(post_loc_ord) keep(post_loc_ord)
mtitle("CC (lax)" "CC (lax) with X" "CC (strict)" "CC (strict) with X")
addnote("Tracts are indexed by time (pre and post ordinance) and regulatory status (if there was ever a local ordinance re condos)." "Controls are for housing characteristics.") 
r2 nocons scalars(F);
#delimit cr

clear matrix
*/
**Condo long difference

eststo: reg cond_pct post loc_ord post_loc_ord if cc_2 == 1 & inlist(year, 1970, 2010), r
eststo: reg cond_pct post loc_ord post_loc_ord if cc_1 == 1 & inlist(year, 1970, 2010), r
eststo: reg cond_pct post loc_ord post_loc_ord if cc_2 == 1 & inlist(year, 1980, 2010), r
eststo: reg cond_pct post loc_ord post_loc_ord if cc_1 == 1 & inlist(year, 1980, 2010), r

#delimit ;
esttab using "$out\cc_condo_reg.tex", replace label 
title("Effects of Ordinances on Condo Rates - City Center (Long Diff)") se brackets
order(post_loc_ord) keep(post_loc_ord)
mtitle("1970 Base, Lax" "1970 Base, Strict" "1980 Base, Lax" "1980 Base, Strict")
addnote("Tracts are indexed by time (pre and post ordinance) and regulatory status (if there was ever a local ordinance re condos)." ) 
r2 nocons ;
#delimit cr

clear matrix

gen var_names = ""
replace var_names = "Log Mean Income"             if _n == 1
replace var_names = "Share with Bachelors Degree" if _n == 2
replace var_names = "Share White"                 if _n == 3


tab year, gen(yr)

local j = 1

*gen ed_inc = educ_b/lminc

*drop if ed_inc > 0.085

foreach y in $yy {

	*eststo: reg d`y' cond_pct   $x_p                                                 if bound_dist < `d' & year == 2010, r

	eststo: xtreg    `y' own i.year age* if cc_2 == 1, fe vce(robust)	
	*eststo: ivreg2   `y' (own = post_loc_ord) if cc_2 == 1, cluster(cbsa_num year) first
	eststo: xtivreg `y' i.year age* (own = post_loc_ord) if cc_2 == 1,  fe vce(conventional) first small
	*estat overid
	*eststo: reg `y' own $x_p if cc_2 == 1, r
	*eststo: ivregress 2sls `y' $x_p (own = post loc_ord post_loc_ord) if cc_2 == 1, vce(r) first
	*estat overid

	*eststo: reg      `y' own  if cc_1 == 1, r
	eststo: xtreg   `y' own i.year age* if cc_1 == 1, fe vce(robust)	
	*eststo: ivreg2   `y' (own = post loc_ord post_loc_ord) if cc_1 == 1, cluster(ua_code) first
	eststo: xtivreg `y' i.year age* (own = post_loc_ord) if cc_1 == 1,  fe vce(conventional) first small

	local t = var_names[`j']
	local title = "Effect of Ownership on "+ "`t'"
	local lt = lower("`t'")

	#delimit ;
	esttab using "$out\dd_iv_`y'.tex", replace label 
	title("`title'") se brackets
	addnote("Limited to city center neighborhoods (lax or strict), includes age group controls." "All specifications have clustered standard errors by city." "Top 100 cities are included.")
	order(own) keep(own)
	mtitle("Lax, FE" "Lax, FE-IV" "Strict, FE" "Strict, FE-IV")
	nocons ;

	#delimit cr

	local j = `j' + 1

	clear matrix

	}
	
**Age Bar Effects

mat age = J(6,4,.)

local i = 1

foreach v of varlist age20_25 age25_35 age35_45 age45_55 age55_65 age65pl {

xtreg `v' own i.year if cc_1 == 1, fe vce(robust)
mat age[`i', 1] = _b[own]
mat age[`i', 2] = _se[own] 	
xtivreg `v' i.year (own = post_loc_ord) if cc_1 == 1,  fe vce(conventional) first small
mat age[`i', 3] = _b[own]
mat age[`i', 4] = _se[own] 	
 
local i = `i' + 1
}

svmat age 

gen     age_cat = ""
replace age_cat = "20 - 25" if _n == 1
replace age_cat = "25 - 35" if _n == 2
replace age_cat = "35 - 45" if _n == 3
replace age_cat = "45 - 55" if _n == 4
replace age_cat = "55 - 65" if _n == 5
replace age_cat = "65+"     if _n == 6

#delimit ;
graph bar age1 age3, over(age_cat)
name(age_bar, replace)
title("Ownership Effects on Age Group Populations")
ytitle("Effect")
legend(order(1 "FE" 2 "FE, IV"))
graphregion(color(white)) bgcolor(white);

#delimit cr

graph export "$out\age_bar.png", name(age_bar) replace
 	
cut_ivreg munit5pl_base 100 lminc own "i.year" post_loc_ord "cc_1 != 1000" "fe vce(robust)" "fe vce(conventional) small" "Effect of Ownership on Income" "Pct 5+ Units" "Ln Income" 
cut_ivreg pd_base 100 lminc own "i.year" post_loc_ord "cc_1 != 1000" "fe vce(robust)" "fe vce(conventional) small" "Effect of Ownership on Income" "Pop Dens" "Ln Income" 
cut_ivreg munit5pl_base 100 educ_b own "i.year" post_loc_ord "cc_1 != 1000" "fe vce(robust)" "fe vce(conventional) small" "Effect of Ownership on Education" "Pct 5+ Units" "Pct Bach Deg +" 
cut_ivreg pd_base 100 educ_b own "i.year" post_loc_ord "cc_1 != 1000" "fe vce(robust)" "fe vce(conventional) small" "Effect of Ownership on Education" "Pop Dens" "Pct Bach Deg +" 
cut_ivreg munit5pl_base 100 shrwht own "i.year" post_loc_ord "cc_1 != 1000" "fe vce(robust)" "fe vce(conventional) small" "Effect of Ownership on Share White" "Pct 5+ Units" "Share White" 
cut_ivreg pd_base 100 shrwht own "i.year" post_loc_ord "cc_1 != 1000" "fe vce(robust)" "fe vce(conventional) small" "Effect of Ownership on Share White" "Pop Dens" "Share White" 


foreach n in lminc educ_b shrwht {

graph export "$out\iv_`n'_pd.png", name(iv_`n'_pd_base) replace
graph export "$out\iv_`n'_munit5pl.png", name(iv_`n'_munit5pl_base) replace

}
	
/*
local j = 1
xx
foreach y in $yy {

eststo: reg d`y' own if cc_2 == 1, r	
eststo: ivregress 2sls d`y'      (own = post loc_ord post_loc_ord) if cc_2 == 1, vce(r) first
estat overid
eststo: reg d`y' own $x_p if cc_2 == 1, r
eststo: ivregress 2sls d`y' $x_p (own = post loc_ord post_loc_ord) if cc_2 == 1, vce(r) first
estat overid

eststo: reg `y' own if cc_1 == 1, r
eststo: ivregress 2sls d`y'      (own = post loc_ord post_loc_ord) if cc_1 == 1, vce(r) first
estat overid
eststo: reg `y' own $x_p if cc_1 == 1, r
eststo: ivregress 2sls d`y' $x_p (own = post loc_ord post_loc_ord) if cc_1 == 1, vce(r) first
estat overid

local t = var_names[`j']
local title = "Effect of Ownership on Change in "+ "`t'"
local lt = lower("`t'")

#delimit ;
esttab using "$out\dd_iv_d`y'.tex", replace label 
title("`title'") se brackets
addnote("Limited to tracts within city center." "Estimates include controls for present (2010) housing stock." "Robust standard errors.")
order(own) keep(own)
mtitle("OLS (lax)" "IV (lax)" "OLS (lax) with X" "IV (lax) with X" "OLS (strict)" "IV (strict)" "OLS (strict) with X" "IV (strict) with X" )
nocons ;

#delimit cr

local j = `j' + 1

clear matrix

}
*/
cut_reg 
