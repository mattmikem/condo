********************************************
*Build in Condo, Resurge, and NCDB
*M. Miller, 15S
********************************************


cd "C:\Users\Matthew\Desktop\ECON\Research\Urban\Papers\Condos\Working"

clear
clear matrix

set more off

global nbcd  = "C:\Users\Matthew\Desktop\ECON\Research\Urban\Data\NCDB"
global condo = "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"
global out   = "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Output\"

use resurge_alys_3_6

joinby geoid2 using "$nbcd\ncdb_condo", unmatched(master)
drop _merge
joinby geoid2 using ncdb_trctdet, unmatched(master)
drop _merge

**TEMP FIX TO MSA CODE BETWEEN IPUMS AND NCDB

gen     metaread = .
replace metaread = 520  if ua_name == "Atlanta, GA"
replace metaread = 1120 if ua_name == "Boston, MA--NH--RI"
replace metaread = 1600 if ua_name == "Chicago, IL--IN"
replace metaread = 2080 if ua_name == "Denver--Aurora, CO"
replace metaread = 3480 if ua_name == "Indianapolis, IN"
replace metaread = 4480 if ua_name == "Los Angeles--Long Beach--Anaheim, CA"
replace metaread = 5120 if ua_name == "Minneapolis--St. Paul, MN--WI"
replace metaread = 5600 if ua_name == "New York--Newark, NY--NJ--CT"
replace metaread = 7360 if ua_name == "San Francisco--Oakland, CA"
replace metaread = 6160 if ua_name == "Philadelphia, PA--NJ--DE--MD"
replace metaread = 7320 if ua_name == "San Diego, CA"
replace metaread = 7400 if ua_name == "San Jose, CA"
replace metaread = 7600 if ua_name == "Seattle, WA"
replace metaread = 8840 if ua_name == "Washington, DC--VA--MD"

joinby metaread using "$condo\hud", unmatched(master)
drop _merge
joinby metaread using "$condo\wh_condo", unmatched(master)
drop _merge

foreach v in ttunit ocunit reunit {

rename `v'17  `v'1_1970
rename `v'27  `v'2_1970
rename `v'37  `v'3_1970
rename `v'47  `v'4_1970
rename `v'57  `v'5_1970
rename `v'm7  `v'm_1970

rename `v'18  `v'1_1980
rename `v'28  `v'2_1980
rename `v'38  `v'3_1980
rename `v'48  `v'4_1980
rename `v'58  `v'5_1980
rename `v'm8  `v'm_1980

rename `v'19  `v'1_1990
rename `v'29  `v'2_1990
rename `v'39  `v'3_1990
rename `v'49  `v'4_1990
rename `v'59  `v'5_1990
rename `v'm9  `v'm_1990
rename `v'o9  `v'o_1990

rename `v'10  `v'1_2000
rename `v'20  `v'2_2000
rename `v'30  `v'3_2000
rename `v'40  `v'4_2000
rename `v'50  `v'5_2000
rename `v'm0  `v'm_2000
rename `v'o0  `v'o_2000

rename `v'11a `v'1_2010
rename `v'21a `v'2_2010
rename `v'31a `v'3_2010
rename `v'41a `v'4_2010
rename `v'51a `v'5_2010
rename `v'm1a `v'm_2010
rename `v'o1a `v'o_2010

}

rename ttunt500  ttunit50_2000
rename ocunt500  ocunit50_2000
rename reunt500  reunit50_2000
rename ttunt501a ttunit50_2010
rename ocunt501a ocunit50_2010
rename reunt501a reunit50_2010

**Condo definition: owner-occ unit > 4 units****************************

forvalues y = 1970(10)2010 {
	forvalues u = 1/5 {
	gen owunit`u'_`y' = ocunit`u'_`y' - reunit`u'_`y'
}
}

gen owunit50_2000 = ocunit50_2000 - reunit50_2000
gen owunit50_2010 = ocunit50_2010 - reunit50_2010

foreach s in tt oc {

egen `s'unit_1970 = rowtotal(`s'unit1_1970 `s'unit2_1970 `s'unit3_1970 `s'unit4_1970 `s'unit5_1970 `s'unitm_1970)
egen `s'unit_1980 = rowtotal(`s'unit1_1980 `s'unit2_1980 `s'unit3_1980 `s'unit4_1980 `s'unit5_1980 `s'unitm_1980)
egen `s'unit_1990 = rowtotal(`s'unit1_1990 `s'unit2_1990 `s'unit3_1990 `s'unit4_1990 `s'unit5_1990 `s'unitm_1990 `s'unito_1990)
egen `s'unit_2000 = rowtotal(`s'unit1_2000 `s'unit2_2000 `s'unit3_2000 `s'unit4_2000 `s'unit5_2000 `s'unitm_2000 `s'unito_2000 `s'unit50_2000)
egen `s'unit_2010 = rowtotal(`s'unit1_2010 `s'unit2_2010 `s'unit3_2010 `s'unit4_2010 `s'unit5_2010 `s'unitm_2010 `s'unito_2010 `s'unit50_2010)

}

egen condo_1970 = rowtotal(owunit5_1970)
egen condo_1980 = rowtotal(owunit5_1980)
egen condo_1990 = rowtotal(owunit5_1990)
egen condo_2000 = rowtotal(owunit5_2000 owunit50_2000)
egen condo_2010 = rowtotal(owunit5_2010 owunit50_2010)

forvalues y = 1970(10)2010 {

gen ctt_pct`y' = condo_`y'/ttunit_`y'
gen coc_pct`y' = condo_`y'/ocunit_`y'

}

**Construct year and Unit Numbers percentages

egen pct_10yrs1970 = rowtotal(bltto597 bltto497 bltto397)
egen pct_10yrs1980 = rowtotal(bltyr698 bltyr598 bltyr498 bltyr398)
egen pct_10yrs1990 = rowtotal(bltyr799 bltyr699 bltyr599 bltyr499 bltyr399)
egen pct_10yrs2000 = rowtotal(bltyr890 bltyr790 bltyr690 bltyr590 bltyr490 bltyr390)
egen pct_10yrs2010 = rowtotal(bltyr991a bltyr891a bltyr791a bltyr691a bltyr591a bltyr491a bltyr391a)

egen pct_pre601970 = rowtotal(bltto597 bltto497 bltto397)
egen pct_pre601980 = rowtotal(bltyr598 bltyr498 bltyr398)
egen pct_pre601990 = rowtotal(bltyr599 bltyr499 bltyr399)
egen pct_pre602000 = rowtotal(bltyr590 bltyr490 bltyr390)
egen pct_pre602010 = rowtotal(bltyr591a bltyr491a bltyr391a)
  
gen pct_1dunit1970 = ttunit1_1970  
gen pct_1dunit1980 = ttunit1_1980
gen pct_1dunit1990 = ttunit1_1990
gen pct_1dunit2000 = ttunit1_2000
gen pct_1dunit2010 = ttunit1_2010

egen pct_1a_4unit1970 = rowtotal(ttunit2_1970 ttunit3_1970 ttunit4_1970)
egen pct_1a_4unit1980 = rowtotal(ttunit2_1980 ttunit3_1980 ttunit4_1980)
egen pct_1a_4unit1990 = rowtotal(ttunit2_1990 ttunit3_1990 ttunit4_1990)
egen pct_1a_4unit2000 = rowtotal(ttunit2_2000 ttunit3_2000 ttunit4_200)
egen pct_1a_4unit2010 = rowtotal(ttunit2_2010 ttunit3_2010 ttunit4_2010)

gen pct_5unit1970 = ttunit5_1970
gen pct_5unit1980 = ttunit5_1980
gen pct_5unit1990 = ttunit5_1990
egen pct_5unit2000 = rowtotal(ttunit5_2000 ttunit50_2000)
egen pct_5unit2010 = rowtotal(ttunit5_2010 ttunit50_2010)

foreach v in pct_10yrs pct_pre60 pct_1dunit pct_1a_4unit pct_5unit {
forvalues y = 1970(10)2010 {

replace `v'`y' = `v'`y'/ttunit_`y'

}
}

**Education

rename educ127 educ121970
rename educ128 educ121980
rename educ129 educ121990
rename educ120 educ122000

rename educ167 educ161970
rename educ168 educ161980
rename educ169 educ161990
rename educ160 educ162000

rename educpp7 educpp1970
rename educpp8 educpp1980
rename educpp9 educpp1990
rename educpp0 educpp2000

save condo_temp, replace

**(very) small set of outliers with neg condo rates, filter out

**ANALYSES********************************************************

*(1) Rankings of UA by Condo Rate

collapse (sum) condo_* ttunit_*, by(ua_name ua_code)

forvalues y = 1970(10)2010 {
gen ctt_pct`y' = condo_`y'/ttunit_`y'
}

export excel "$out\condo_ratesbyUA.xls", sheet("rates") firstrow(var) replace

*(2) Descriptive Plots

use condo_temp, clear

global obs   = "geoid2 ua_code cc_2 dist right_fr notice_convert app_assist_lowinc pressure loczoning"
global hou   = "h_age hsize pct_pre60 pct_10yrs pct_1dunit pct_1a_4unit pct_5unit"
global ind   = "trctpop mean_inc shrmin marshr gayshr yprof elder educpp educ12 educ16"
global nei   = "comm_time spill_inc incp spp"
global dep   = "ctt_pct coc_pct"
global k     = "trctpop* h_age* hsize* mean_inc* shrmin* marshr* educpp* educ12* educ16* gayshr* elder* yprof* comm_time* spill_inc* incp* spp* ctt_pct* coc_pct* pct_1dunit* pct_1a_4unit* pct_5unit* pct_10yrs* pct_pre60* right_fr notice_convert app_assist_lowinc pressure loczoning"

keep $obs $k
drop h_age_2

reshape clear
reshape i $obs
reshape j year 
reshape xij $ind $hou $nei $dep
reshape long

**Minor variable edits

replace elder = elder/trctpop

gen educ_bach = educ16/educpp
gen educ_hs   = educ12/educpp

*Labels

label var h_age        "Mean Age of Housing"
label var hsize        "Mean Size of Housing"
label var mean_inc     "Mean HH Income"
label var shrmin       "Minority Pop Share"
label var marshr       "Married HH Share"
label var gayshr       "Gay Couple HH Share"
label var yprof        "Pop Share Ages 20 - 34"
label var elder        "Pop Share Age 54 +"
label var comm_time    "Mean Commute Time"
label var spill_inc    "Spillover Neighborhood Income"
label var incp         "Income Percentile"
label var spp          "Spillover Income Percentile"
label var ctt_pct      "Condo Pct of Total Housing"
label var coc_pct      "Condo Pct of Occupied Housing"
label var pct_pre60    "Pct Built Before 1960"
label var pct_10yrs    "Pct Built 10 yrs +"
label var pct_1dunit   "Pct 1 unit detached"
label var pct_1a_4unit "Pct 1 unit att - 4 units"
label var pct_5unit    "Pct 5 units +"
label var educ_hs      "Pct with HS Diploma(25+)"
label var educ_bach    "Pct with Bachelor Deg (25+)"


gsort geoid2 year -dist
duplicates drop geoid2 year, force

*[NEED TO REVIEW SOURCE OF DUPLICATION]

drop if year == 2012

destring geoid2, gen(trctid)
tsset trctid year, delta(10)

browse

**General Regressions

*Cross-sectional, will run pooled after a reshape below

**City Center predictive, but not distance (donut shape would be an issue)

global hou  = "h_age hsize"
global hou1 = "pct_pre60 pct_10yrs pct_1dunit pct_1a_4unit pct_5unit"
global ind  = "mean_inc shrmin marshr yprof elder"
global nei  = "spill_inc incp spp cc_2"

*Cross-Sections

forvalues y = 1970(10)2010 {

disp "`y'"

reg ctt_pct $ind if year == `y', cluster(ua_code)
reg ctt_pct $hou if year == `y', cluster(ua_code)
reg ctt_pct $nei if year == `y', cluster(ua_code)
reg ctt_pct $ind $hou $nei if year == `y', cluster(ua_code)

}

disp "All Years (pooled)"

reg ctt_pct $ind $hou $nei, cluster(ua_code)

*Lags

forvalues y = 1980(10)2000 {

disp "`y'"

reg D.ctt_pct L.mean_inc  L.shrmin L.marshr L.yprof if year == `y', cluster(ua_code)
reg D.ctt_pct L.h_age     L.hsize                   if year == `y', cluster(ua_code)
reg D.ctt_pct cc_2 L.spill_inc L.incp               if year == `y', cluster(ua_code)
reg D.ctt_pct cc_2 L.mean_inc L.shrmin L.marshr L.yprof L.spill_inc L.h_age L.hsize if year == `y', cluster(ua_code)

}

reg D.ctt_pct cc_2 L.mean_inc L.shrmin L.marshr L.yprof L.spill_inc L.h_age L.hsize, cluster(ua_code)

forvalues y = 1970(10)2010 {

twoway (lpoly ctt_pct dist if year == `y' & right_fr == 1 & dist < 20) (lpoly ctt_pct dist if year == `y' & right_fr == 2 & dist < 20), title("By RFR") name(rfr`y', replace) graphregion(color(white)) bgcolor(white)
graph export "$out\rfr_dist`y'.png", replace

}

forvalues j = 0/8 {

#delimit ;
twoway (lpoly ctt_pct dist if year == 1970 & ua_code == `j' & dist < 20) 
(lpoly ctt_pct dist if year == 1980 & ua_code == `j' & dist < 20) 
(lpoly ctt_pct dist if year == 1990 & ua_code == `j' & dist < 20) 
(lpoly ctt_pct dist if year == 2000 & ua_code == `j' & dist < 20) 
(lpoly ctt_pct dist if year == 2010 & ua_code == `j' & dist < 20), 
legend(label(1 "1970")  label(2 "1980") label(3 "1990") label(4 "2000") label( 5 "2010")) 
title("Urban Area `j'") 
name(dist`j', replace)
graphregion(color(white)) bgcolor(white);
#delimit cr
graph export "$out\dist`j'.png", replace

}
*/
**Reduced Form

foreach v in elder yprof marshr mean_inc educ_bach{

forvalues y = 1970(10)2010 {

if `y' == 2010 & `v' == educ_bach {

}

else { 

eststo: reg `v' ctt_pct $hou1 if year == `y', cluster(ua_code)

}

}

#delimit ;
esttab est* using "$out\`v'_rf.csv", 
replace title("Condoization Reduced Form Associations on: `v'")  
mtitles("1970" "1980" "1990" "2000" "2010") se brackets r2 label;
#delimit cr
clear matrix
}

**First Stage Explore

foreach v in right_fr notice_convert app_assist_lowinc loczoning pressure {

gen `v'_X_4units   = `v'*pct_1a_4unit
gen `v'_X_5units   = `v'*pct_5unit
gen `v'_X_10yrs    = `v'*pct_10yrs
gen `v'_X_pre60    = `v'*pct_pre60

}

global z "right_fr* notice_convert* loczoning*"

forvalues y = 1970(10)2010 {

eststo: reg ctt_pct $z $hou1 if year == `y'

}

#delimit ;
esttab est* using "$out\fs.csv", 
replace title("Condoization First Stage Explore")  
mtitles("1970" "1980" "1990" "2000" "2010") se brackets r2 scalars(F);
#delimit cr
clear matrix

xx
reg ctt_pct_1980 dist incp1970, cluster(ua_code)
reg ctt_pct_1980 cc_2 incp1970, cluster(ua_code)

reg ctt_pct_1990 dist incp1980, cluster(ua_code)
reg ctt_pct_1990 cc_2 incp1980, cluster(ua_code)

reg ctt_pct_2000 dist incp1990, cluster(ua_code) 
reg ctt_pct_2000 cc_2 incp1990, cluster(ua_code) 

reg ctt_pct_2010 dist incp2000, cluster(ua_code) 
reg ctt_pct_2010 cc_2 incp2000, cluster(ua_code) 
