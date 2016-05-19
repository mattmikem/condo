********************************************
*Condo Prediction (1980, 90, 2000, 2006-2010)
*This uses actual condo data mapped to NCDB
*i.e. no IPUMS!

*M. Miller, 16W
********************************************

cd "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"

capture log close

clear
clear matrix
clear mata

set more off

set maxvar 30000

global data  = "L:\Research\Condos\Data"
global work  = "L:\Research\Condos\Working Data"
*global bound = "L:\Research\Resurgence\Working Files\Boundary"
global bound = "L:\Research\Resurgence\Working Files\Near Boundary"
global out   = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Output\01-18-2016"

use "$work\ncdb_condo.dta"

joinby geo2010 year using "$work\actual_condo.dta", unmatched(master)
drop _merge

**Predictions

xtset geo2010 year, delta(10)

#delimit ;

global x_p = "cc_status own munit1a munit2_4 munit5pl mbed1 mbed2 mbed3 mbed4pl 
			  hu_age10_20 hu_age20_30 hu_age30_40 hu_age40pl vachu trvlpb wkhome 
			  auto commut25 commut25_45 commut45pl";

#delimit cr
		
foreach v of varlist $x_p {

gen l_`v'  = L.`v'  if year == 2010
gen l2_`v' = L2.`v' if year == 2010
gen l3_`v' = L3.`v' if year == 2010
gen l4_`v' = L4.`v' if year == 2010
}

#delimit ;

global l3_x_p = "cc_status l3_own l3_munit1a l3_munit2_4 l3_munit5pl l3_mbed1 l3_mbed2 l3_mbed3 l3_mbed4pl 
			  l3_hu_age10_20 l3_hu_age20_30 l3_hu_age30_40 l3_hu_age40pl l3_vachu l3_trvlpb l3_wkhome 
			  l3_auto l3_commut25 l3_commut25_45 l3_commut45pl";

*Need to add in l4_hu_age30pl, was cut from last NCDB pull;
			  
global l4_x_p = "cc_status l4_own l4_munit1a l4_munit2_4 l4_munit5pl l4_mbed1 l4_mbed2 l4_mbed3 l4_mbed4pl 
			  l4_hu_age10_20 l4_hu_age20_30 l4_hu_age30_40 l4_vachu l4_trvlpb l4_wkhome 
			  l4_auto";
#delimit cr

*gen condo_pct = wcnt03/wcnt01

**Labels

*label var munit1d      "1 Unit (detached) or Other"
label var munit1a      "1 Unit (attached)"
label var munit2_4     "2 - 4 Units"
label var munit5pl     "5+ Units"
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
*label var trantime     "Commute Time (Mean)"
*label var l_munit1d      "1 Unit (detached) (2000)"
label var l_munit1a      "1 Unit (attached) (2000)"
label var l_munit2_4     "2 - 4 Units (2000)"
label var l_munit5pl     "5+ Units (2000)"
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
*label var l_trantime     "Commute Time (Mean) (2000)"
*label var l2_munit1d      "1 Unit (detached) (1980)"
label var l2_munit1a      "1 Unit (attached) (1990)"
label var l2_munit2_4     "2 - 4 Units (1990)"
label var l2_munit5pl     "5+ Units (1990)"
*label var l2_mbed0        "Studio/Zero Bedrooms (1980)"
label var l2_mbed1        "One Bedroom (1990)"
label var l2_mbed2        "Two Bedrooms (1990)"
label var l2_mbed3        "Three Bedrooms (1990)"
label var l2_mbed4pl      "4+ Bedrooms (1980)"
*label var l2_hu_age10     "House Age $<$ 10 yrs (1980)"
label var l2_hu_age10_20  "House Age 10 - 20 yrs (1990)"
label var l2_hu_age20_30  "House Age 20 - 30 yrs (1990)"
label var l2_hu_age30_40  "House Age 30 - 40 yrs (1990)"
label var l2_hu_age40pl   "House Age 40+ yrs (1990)"
label var l2_own          "\% Units Owned (1990)"
*label var l2_trantime     "Commute Time (Mean) (1990)"
*label var l3_munit1d      "1 Unit (detached) (1980)"
label var l3_munit1a      "1 Unit (attached) (1980)"
label var l3_munit2_4     "2 - 4 Units (1980)"
label var l3_munit5pl     "5+ Units (1980)"
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
label var l3_own          "\% Units Owned (1980)"
*label var l3_trantime     "Commute Time (Mean) (1980)"
label var l3_munit1a      "1 Unit (attached) (1980)"
label var l3_munit2_4     "2 - 4 Units (1980)"
label var l3_munit5pl     "5+ Units (1980)"
*label var l3_mbed0        "Studio/Zero Bedrooms (1980)"
label var l4_munit1a      "1 Unit (attached) (1970)"
label var l4_munit2_4     "2 - 4 Units (1970)"
label var l4_munit5pl     "5+ Units (1970)"
label var l4_mbed1        "One Bedroom (1970)"
label var l4_mbed2        "Two Bedrooms (1970)"
label var l4_mbed3        "Three Bedrooms (1970)"
label var l4_mbed4pl      "4+ Bedrooms (1970)"
*label var l3_hu_age10     "House Age $<$ 10 yrs (1980)"
label var l4_hu_age10_20  "House Age 10 - 20 yrs (1970)"
label var l4_hu_age20_30  "House Age 20 - 30 yrs (1970)"
label var l4_hu_age30_40  "House Age 30 - 40 yrs (1970)"
label var l4_hu_age40pl   "House Age 40+ yrs (1970)"
label var l4_own          "\% Units Owned (1970)"
*label var l4_trantime     "Commute Time (Mean) (1970)"

gen cond_pct = wcnt03/wcnt01

**Stepwise

stepwise, pe(.1): tobit cond_pct $l3_x_p if year == 2010, ll(0) ul(1)
predict chat_l3_st, ystar(0,1)
stepwise, pe(.1): tobit cond_pct $l4_x_p if year == 2010, ll(0) ul(1)
predict chat_l4_st, ystar(0,1)

save "$work\condo_pred.dta", replace



**************************************************************************************************************************************************************
**DDD Framework
/*
**DDD Analysis

drop if LocalOrdMsa == .

gen post = 0
replace post = 1 if year > reg_year & reg_year != .
replace post = 1 if year > 1970 & reg_year == .

gen loc_ord_msa = 0
replace loc_ord_msa = 1 if LocalOrdMsa > 3 & LocalOrdMsa != .

gen post_cc         = post*cc_status
gen post_loc_ord    = post*loc_ord_msa 
gen cc_loc_ord      = cc_status*loc_ord_msa
gen cc_loc_ord_post = cc_status*loc_ord_msa*post

label var post_loc_ord     "Post-Condo Ord $\times$ MSA with Condo Ordinance"
label var post_cc          "Post-Condo Ord $\times$ Central City Tract"
label var cc_loc_ord_post  "Post-Condo Ord $\times$ CC Tract $\times$ MSA with Condo Ord"
xx
**Predictions with Training

stepwise, pe(.1): tobit cond_pct $l3_x_p if year == 2010 & loc_ord_msa == 0, ll(0) ul(1)
predict chat_l3_M_st, ystar(0,1) 
stepwise, pe(.1): tobit cond_pct $l3_x_p if year == 2010 & cc_status == 0, ll(0) ul(1)
predict chat_l3_C_st, ystar(0,1)
stepwise, pe(.1): tobit cond_pct $l4_x_p if year == 2010 & loc_ord_msa == 0, ll(0) ul(1)
predict chat_l4_M_st, ystar(0,1) 
stepwise, pe(.1): tobit cond_pct $l4_x_p if year == 2010 & cc_status == 0, ll(0) ul(1)
predict chat_l4_C_st, ystar(0,1)

eststo: reg lminc cond_pct cc_status loc_ord_msa post post_cc post_loc_ord cc_loc_ord cc_loc_ord_post $x_p, r
eststo: ivregress 2sls lminc $x_p (cond _pct = cc_status loc_ord_msa post post_cc post_loc_ord cc_loc_ord cc_loc_ord_post)

*Start with effect on condo rates

replace cond_pct = 0 if year == 1970 | year == 1980

local b = 1970

eststo: reg cond_pct cc_status post post_cc        if (loc_ord_msa == 1 & year == `b') | (loc_ord_msa == 1 & year == 2010), r
eststo: reg cond_pct cc_status post post_cc        if (loc_ord_msa == 0 & year == `b') | (loc_ord_msa == 0 & year == 2010), r
eststo: reg cond_pct loc_ord_msa post post_loc_ord if (cc_status == 1 & year == `b')   | (cc_status == 1 & year == 2010), r
eststo: reg cond_pct loc_ord_msa post post_loc_ord if (cc_status == 0 & year == `b')   | (cc_status == 0 & year == 2010), r
eststo: reg cond_pct cc_status loc_ord_msa post post_cc post_loc_ord cc_loc_ord cc_loc_ord_post if (year == `b' | year == 2010), r  

eststo: reg cond_pct cc_status loc_ord_msa cc_loc_ord if (year == 2010), r  



#delimit ;
esttab using "$out\ddd_cond_pct.tex", replace label 
title("Diff-in-Diff-in-Diff (and Components)") se brackets
order(post_cc post_loc_ord cc_loc_ord_post) keep(post_cc post_loc_ord cc_loc_ord_post)
addnote("Tracts are indexed by time (pre and post ordinance), MSA status (if there was ever a local ordinance re condos),"
"and central city status (meaning if local ordinance in MSA is relevant)." 
"(1) Limited to MSA with Local Ord at some point in time." 
"(2) Limited to MSA no Local Ord." "(3) Limited to Central City." "(4) Limited to Suburbs.") 
r2 nocons ;

#delimit cr
clear matrix
