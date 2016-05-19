********************************************
*Baseline NCDB for Condo Predictions
*M. Miller, 15S+
********************************************

cd "C:\Users\mmiller\Research\Urban\Condos"
*cd "C:\Users\Matthew\Desktop\ECON\Research\Urban\Papers\Condos\Working"

clear
clear matrix

set maxvar 8000

set more off

*global ncdb = "C:\Users\Matthew\Desktop\ECON\Research\Urban\Data\NCDB"
global ncdb = "L:\Research\Resurgence\NCDB"

import delimited using "$ncdb\full.csv", delimit(",")
*insheet using "$ncdb\full.csv", comma

keep geo2010 - sduni trctpop* shrwht* numhhs* shrblk* ttunit* ttunt* ocunit* ocunt* reunit* reunt* bltto* bltyr* spownoc* sprntoc* bdtot* indemp* ownocc* rntocc* tothsun* vachu* avhhin* educ12* educ16* educpp* mcwkid* mcnkid* age* shrwht*

label var ttunit17 "1970 Total housing units consisting of1 unit, detached"
label var ttunit27 "1970 Total housing units consisting of1 unit, attached"
label var ttunit37 "1970 Total housing units consisting of2 units"
label var ttunit47 "1970 Total housing units consisting of3-4 units"
label var ttunit57 "1970 Total housing units consisting of5+ units"
label var ttunitm7 "1970 Total housing units consisting ofa mobile home ortrailer"
label var ocunit17 "1970 Occupied housing units consistingof 1 unit, detached"
label var ocunit27 "1970 Occupied housing units consistingof 1 unit, attached"
label var ocunit37 "1970 Occupied housing units consistingof 2 units"
label var ocunit47 "1970 Occupied housing units consistingof 3-4 units"
label var ocunit57 "1970 Occupied housing units consistingof 5+ units"
label var ocunitm7 "1970 Occupied housing units consistingof a mobile homeor"
label var reunit17 "1970 Renter-occ. housing units consisting of 1 unit, detached"
label var reunit27 "1970 Renter-occ. housing units consisting of 1 unit, attached"
label var reunit37 "1970 Renter-occ. housing units consisting of 2 units"
label var reunit47 "1970 Renter-occ. housing units consisting of 3-4 units"
label var reunit57 "1970 Renter-occ. housing units consisting of 5+ units"
label var reunitm7 "1970 Renter-occ. housing units consisting of a mobile home"
label var bltto707 "1970 Total occ. and vac. year-round housing units built1969-1970"
label var bltto687 "1970 Total occ. and vac. year-round housing units built1965-1968"
label var bltto647 "1970 Total occ. and vac. year-round housing units built1960-1964"
label var bltto597 "1970 Total occ. and vac. year-round housing units built1950-1959"
label var bltto497 "1970 Total occ. and vac. year-round housing units built1940-1949"
label var bltto397 "1970 Total occ. and vac. year-round housing units built1939"
label var rntocc8 "1980 Total renter-occ. housing units"
label var ownocc8 "1980 Total owner-occ. housing units"
label var sprntoc8 "1980 Total spec. renter-occ. housing units"
label var spownoc8 "1980 Total spec. owner-occ. noncondo.housing units"
label var ttunit18 "1980 Total housing units consisting of1 unit, detached"
label var ttunit28 "1980 Total housing units consisting of1 unit, attached"
label var ttunit38 "1980 Total housing units consisting of2 units"
label var ttunit48 "1980 Total housing units consisting of3-4 units"
label var ttunit58 "1980 Total housing units consisting of5+ units"
label var ttunitm8 "1980 Total housing units consisting ofa mobile home ortrailer"
label var ocunit18 "1980 Occupied housing units consistingof 1 unit, detached"
label var ocunit28 "1980 Occupied housing units consistingof 1 unit, attached"
label var ocunit38 "1980 Occupied housing units consistingof 2 units"
label var ocunit48 "1980 Occupied housing units consistingof 3-4 units"
label var ocunit58 "1980 Occupied housing units consistingof 5+ units"
label var ocunitm8 "1980 Occupied housing units consistingof a mobile homeor"
label var reunit18 "1980 Renter-occ. housing units consisting of 1 unit, detached"
label var reunit28 "1980 Renter-occ. housing units consisting of 1 unit, attached"
label var reunit38 "1980 Renter-occ. housing units consisting of 2 units"
label var reunit48 "1980 Renter-occ. housing units consisting of 3-4 units"
label var reunit58 "1980 Renter-occ. housing units consisting of 5+ units"
label var reunitm8 "1980 Renter-occ. housing units consisting of a mobile home"
label var rntocc9 "1990 Total renter-occ. housing units"
label var ownocc9 "1990 Total owner-occ. housing units"
label var sprntoc9 "1990 Total spec. renter-occ. housing units"
label var spownoc9 "1990 Total spec. owner-occ. housing units"
label var ttunit19 "1990 Total housing units consisting of1 unit, detached"
label var ttunit29 "1990 Total housing units consisting of1 unit, attached"
label var ttunit39 "1990 Total housing units consisting of2 units"
label var ttunit49 "1990 Total housing units consisting of3-4 units"
label var ttunit59 "1990 Total housing units consisting of5+ units"
label var ttunitm9 "1990 Total housing units consisting ofa mobile home ortrailer"
label var ttunito9 "1990 Total housing units consisting ofother type of structure"
label var ocunit19 "1990 Occupied housing units consistingof 1 unit, detached"
label var ocunit29 "1990 Occupied housing units consistingof 1 unit, attached"
label var ocunit39 "1990 Occupied housing units consistingof 2 units"
label var ocunit49 "1990 Occupied housing units consistingof 3-4 units"
label var ocunit59 "1990 Occupied housing units consistingof 5+ units"
label var ocunitm9 "1990 Occupied housing units consistingof a mobile homeor"
label var ocunito9 "1990 Occupied housing units consistingof other type ofstructure"
label var reunit19 "1990 Renter-occ. housing units consisting of 1 unit, detached"
label var reunit29 "1990 Renter-occ. housing units consisting of 1 unit, attached"
label var reunit39 "1990 Renter-occ. housing units consisting of 2 units"
label var reunit49 "1990 Renter-occ. housing units consisting of 3-4 units"
label var reunit59 "1990 Renter-occ. housing units consisting of 5+ units"
label var reunitm9 "1990 Renter-occ. housing units consisting of a mobile home"
label var reunito9 "1990 Renter-occ. housing units consisting of other typeof"
label var rntocc0 "2000 Total renter-occ. housing units"
label var ownocc0 "2000 Total owner-occ. housing units"
label var sprntoc0 "2000 Total spec. renter-occ. housing units"
label var spownoc0 "2000 Total spec. owner-occ. housing units"
label var ttunit10 "2000 Total housing units consisting of1 unit, detached"
label var ttunit20 "2000 Total housing units consisting of1 unit, attached"
label var ttunit30 "2000 Total housing units consisting of2 units"
label var ttunit40 "2000 Total housing units consisting of3-4 units"
label var ttunit50 "2000 Total housing units consisting of5+ units"
label var ttunt500 "2000 Total housing units consisting of50+ units"
label var ttunitm0 "2000 Total housing units consisting ofa mobile home ortrailer"
label var ttunito0 "2000 Total housing units consisting ofother type of structure"
label var ocunit10 "2000 Occupied housing units consistingof 1 unit, detached"
label var ocunit20 "2000 Occupied housing units consistingof 1 unit, attached"
label var ocunit30 "2000 Occupied housing units consistingof 2 units"
label var ocunit40 "2000 Occupied housing units consistingof 3-4 units"
label var ocunit50 "2000 Occupied housing units consistingof 5+ units"
label var ocunt500 "2000 Occupied housing units consistingof 50+ units"
label var ocunitm0 "2000 Occupied housing units consistingof a mobile homeor"
label var ocunito0 "2000 Occupied housing units consistingof other type ofstructure"
label var reunit10 "2000 Renter-occ. housing units consisting of 1 unit, detached"
label var reunit20 "2000 Renter-occ. housing units consisting of 1 unit, attached"
label var reunit30 "2000 Renter-occ. housing units consisting of 2 units"
label var reunit40 "2000 Renter-occ. housing units consisting of 3-4 units"
label var reunit50 "2000 Renter-occ. housing units consisting of 5+ units"
label var reunt500 "2000 Renter-occ. housing units consisting of 50+ units"
label var reunitm0 "2000 Renter-occ. housing units consisting of a mobile home"
label var reunito0 "2000 Renter-occ. housing units consisting of other typeof"
label var tothsun1 "2010 Total housing units"
label var ttunit11a "06-10 Total housing units consisting of 1 unit, detached"
label var ttunit21a "06-10 Total housing units consisting of 1 unit, attached"
label var ttunit31a "06-10 Total housing units consisting of 2 units"
label var ttunit41a "06-10 Total housing units consisting of 3-4 units"
label var ttunit51a "06-10 Total housing units consisting of 5+ units"
label var ttunt501a "06-10 Total housing units consisting of 50+ units"
label var ttunitm1a "06-10 Total housing units consisting of a mobile home or trailer"
label var ttunito1a "06-10 Total housing units consisting of other type of structure"
label var ocunit11a "06-10 Occupied housing units consisting of 1 unit, detached"
label var ocunit21a "06-10 Occupied housing units consisting of 1 unit, attached"
label var ocunit31a "06-10 Occupied housing units consisting of 2 units"
label var ocunit41a "06-10 Occupied housing units consisting of 3-4 units"
label var ocunit51a "06-10 Occupied housing units consisting of 5+ units"
label var ocunt501a "06-10 Occupied housing units consisting of 50+ units"
label var ocunitm1a "06-10 Occupied housing units consisting of a mobile home or"
label var ocunito1a "06-10 Occupied housing units consisting of other type of structure"
label var reunit11a "06-10 Renter-occupied housing units consisting of 1 unit,"
label var reunit21a "06-10 Renter-occupied housing units consisting of 1 unit,"
label var reunit31a "06-10 Renter-occupied housing units consisting of 2 units"
label var reunit41a "06-10 Renter-occupied housing units consisting of 3-4 units"
label var reunit51a "06-10 Renter-occupied housing units consisting of 5+ units"
label var reunt501a "06-10 Renter-occupied housing units consisting of 50+ units"
label var reunitm1a "06-10 Renter-occupied housing units consisting of a mobile"
label var reunito1a "06-10 Renter-occupied housing units consisting of othertype"
label var bltyr698 "1980 Total housing units built 1960-1969"
label var bltyr598 "1980 Total housing units built 1950-1959"
label var bltyr498 "1980 Total housing units built 1940-1949"
label var bltyr398 "1980 Total housing units built 1939 or earlier"
label var bltyr808 "1980 Year-round housing units built 1979-March 1980"
label var bltyr788 "1980 Year-round housing units built 1975-1978"
label var bltyr748 "1980 Year-round housing units built 1970-1974"
label var bltyr799 "1990 Total housing units built 1970-1979"
label var bltyr699 "1990 Total housing units built 1960-1969"
label var bltyr599 "1990 Total housing units built 1950-1959"
label var bltyr499 "1990 Total housing units built 1940-1949"
label var bltyr399 "1990 Total housing units built 1939 or earlier"
label var bltyr909 "1990 Total housing units built 1989-March 1990"
label var bltyr889 "1990 Total housing units built 1985-1988"
label var bltyr849 "1990 Total housing units built 1980-1984"
label var bltyr000 "2000 Total housing units built 1999-March 2000"
label var bltyr980 "2000 Total housing units built 1995-1998"
label var bltyr940 "2000 Total housing units built 1990-1994"
label var bltyr890 "2000 Total housing units built 1980-1989"
label var bltyr790 "2000 Total housing units built 1970-1979"
label var bltyr690 "2000 Total housing units built 1960-1969"
label var bltyr590 "2000 Total housing units built 1950-1959"
label var bltyr490 "2000 Total housing units built 1940-1949"
label var bltyr390 "2000 Total housing units built 1939 or earlier"
label var bltyr051a "06-10 Total housing units built 2005 or later"
label var bltyr041a "06-10 Total housing units built 2000 to 2004"
label var bltyr991a "06-10 Total housing units built 1990 to 1999"
label var bltyr891a "06-10 Total housing units built 1980 to 1989"
label var bltyr791a "06-10 Total housing units built 1970 to 1979"
label var bltyr691a "06-10 Total housing units built 1960 to 1969"
label var bltyr591a "06-10 Total housing units built 1950 to 1959"
label var bltyr491a "06-10 Total housing units built 1940 to 1949"
label var bltyr391a "06-10 Total housing units built 1939 or earlier"
label var bdtot07 "1970 Total housing units with 0 bedrooms"
label var bdtot17 "1970 Total housing units with 1 bedroom"
label var bdtot27 "1970 Total housing units with 2 bedrooms"
label var bdtot37 "1970 Total housing units with 3 bedrooms"
label var bdtot47 "1970 Total housing units with 4 bedrooms"
label var bdtot57 "1970 Total housing units with 5+ bedrooms"
label var bdtot08 "1980 Total housing units with 0 bedrooms"
label var bdtot18 "1980 Total housing units with 1 bedroom"
label var bdtot28 "1980 Total housing units with 2 bedrooms"
label var bdtot38 "1980 Total housing units with 3 bedrooms"
label var bdtot48 "1980 Total housing units with 4 bedrooms"
label var bdtot58 "1980 Total housing units with 5+ bedrooms"
label var bdtot09 "1990 Total housing units with 0 bedrooms"
label var bdtot19 "1990 Total housing units with 1 bedroom"
label var bdtot29 "1990 Total housing units with 2 bedrooms"
label var bdtot39 "1990 Total housing units with 3 bedrooms"
label var bdtot49 "1990 Total housing units with 4 bedrooms"
label var bdtot59 "1990 Total housing units with 5+ bedrooms"
label var bdtot00 "2000 Total housing units with 0 bedrooms"
label var bdtot10 "2000 Total housing units with 1 bedroom"
label var bdtot20 "2000 Total housing units with 2 bedrooms"
label var bdtot30 "2000 Total housing units with 3 bedrooms"
label var bdtot40 "2000 Total housing units with 4 bedrooms"
label var bdtot50 "2000 Total housing units with 5+ bedrooms"
label var bdtot01a "06-10 Total housing units with 0 bedrooms"
label var bdtot11a "06-10 Total housing units with 1 bedroom"
label var bdtot21a "06-10 Total housing units with 2 bedrooms"
label var bdtot31a "06-10 Total housing units with 3 bedrooms"
label var bdtot41a "06-10 Total housing units with 4 bedrooms"
label var bdtot51a "06-10 Total housing units with 5+ bedrooms"
label var ownocc7 "1970 Total owner-occ. housing units"
label var ownocc8 "1980 Total owner-occ. housing units"
label var ownocc9 "1990 Total owner-occ. housing units"
label var ownocc0 "2000 Total owner-occ. housing units"
label var ownocc1a "2006-2010 Total owner-occ. housing units"
label var tothsun7       "1970 Total housing units"
label var tothsun8       "1980 Total housing units"
label var tothsun9       "1990 Total housing units"
label var tothsun0       "2000 Total housing units"
label var tothsun1       "2010 Total housing units"
label var vachu7 "1970 Total vacant housing units"
label var vachu8 "1980 Total vacant housing units"
label var vachu9 "1990 Total vacant housing units"
label var vachu0 "2000 Total vacant housing units"
label var vachu1 "2010 Total vacant housing units"

**Create variables similar to CONSPUMA

**Housing Units

forvalues y = 7/9 {

egen munit1d_19`y'0   = rowtotal(ttunit1`y' ttunitm`y')
gen munit1a_19`y'0    = ttunit2`y'
egen munit2_4_19`y'0  = rowtotal(ttunit3`y' ttunit4`y')
gen munit5pl_19`y'0   = ttunit5`y'
}

egen munit1d_2000   = rowtotal(ttunit10 ttunitm0)
gen munit1a_2000    = ttunit20
egen munit2_4_2000  = rowtotal(ttunit30 ttunit40)
egen munit5pl_2000  = rowtotal(ttunit50 ttunt500)

egen munit1d_2010   = rowtotal(ttunit11a ttunitm1a)
gen munit1a_2010    = ttunit21a
egen munit2_4_2010  = rowtotal(ttunit31a ttunit41a)
egen munit5pl_2010  = rowtotal(ttunit51a ttunt501a)

**Bedrooms

forvalues y = 7/9 {

gen  mbed0_19`y'0   = bdtot0`y'
gen  mbed1_19`y'0   = bdtot1`y'
gen  mbed2_19`y'0   = bdtot2`y'
gen  mbed3_19`y'0   = bdtot3`y'
egen mbed4pl_19`y'0 = rowtotal(bdtot4`y' bdtot5`y')

}

gen  mbed0_2000   = bdtot00
gen  mbed1_2000   = bdtot10
gen  mbed2_2000   = bdtot20
gen  mbed3_2000   = bdtot30
egen mbed4pl_2000 = rowtotal(bdtot40 bdtot50)

gen  mbed0_2010   = bdtot01a
gen  mbed1_2010   = bdtot11a
gen  mbed2_2010   = bdtot21a
gen  mbed3_2010   = bdtot31a
egen mbed4pl_2010 = rowtotal(bdtot41a bdtot51a)

**Structure Age

*1970

gen hu_age10_20_1970 = bltto597
gen hu_age20_30_1970 = bltto497
gen hu_age30_40_1970 = bltto397

*1980

gen hu_age10_20_1980 = bltyr698
gen hu_age20_30_1980 = bltyr598
gen hu_age30_40_1980 = bltyr498
gen hu_age40pl_1980  = bltyr398

*1990

gen hu_age10_20_1990  = bltyr799
gen hu_age20_30_1990  = bltyr699
gen hu_age30_40_1990  = bltyr599
egen hu_age40pl_1990  = rowtotal(bltyr399 bltyr499)

*2000

gen hu_age10_20_2000  = bltyr890
gen hu_age20_30_2000  = bltyr790
gen hu_age30_40_2000  = bltyr690
egen hu_age40pl_2000  = rowtotal(bltyr390 bltyr490 bltyr590)

*2010

gen hu_age10_20_2010  = bltyr991a
gen hu_age20_30_2010  = bltyr891a
gen hu_age30_40_2010  = bltyr791a
egen hu_age40pl_2010  = rowtotal(bltyr391a bltyr491a bltyr591a bltyr691a)

*Income 

**N HHs

gen numhhs1980 = tothsun8 - vachu8
gen numhhs1990 = tothsun9 - vachu9

rename numhhs7 numhhs1970 
rename numhhs0 numhhs2000
rename numhhs1 numhhs2010

**Income 

rename avhhin7n  avhhin1970 
rename avhhin8n  avhhin1980 
rename avhhin9n  avhhin1990 
rename avhhin0n  avhhin2000
rename avhhin1an avhhin2010

forvalues y = 1970(10)2010 {
gen minc_`y' = avhhin`y'/numhhs`y'
}

**Education Ratios

gen educ_hs_1970 = educ127/educpp7
gen educ_hs_1980 = educ128/educpp8
gen educ_hs_1990 = educ129/educpp9
gen educ_hs_2000 = educ120/educpp0
gen educ_hs_2010 = educ121a/educpp1a

**Education Ratios

gen educ_b_1970 = educ167/educpp7
gen educ_b_1980 = educ168/educpp8
gen educ_b_1990 = educ169/educpp9
gen educ_b_2000 = educ160/educpp0
gen educ_b_2010 = educ161a/educpp1a

**Married Ratio

gen marshr_1970 = (mcwkid7 + mcnkid7)/numhhs1970
gen marshr_1980 = (mcwkid8 + mcnkid8)/numhhs1980
gen marshr_1990 = (mcwkid9 + mcnkid9)/numhhs1990
gen marshr_2000 = (mcwkid0 + mcnkid0)/numhhs2000
gen marshr_2010 = (mcwkid1 + mcnkid1)/numhhs2010

*Emp

gen emp_1970 = indemp7
gen emp_1980 = indemp8
gen emp_1990 = indemp9
gen emp_2000 = indemp0
gen emp_2010 = indemp1a

*White

rename shrwht7 shrwht_1970
rename shrwht8 shrwht_1980
rename shrwht9 shrwht_1990
rename shrwht0 shrwht_2000
rename shrwht1 shrwht_2010

**Ownership

*****
rename ownocc7  own_1970
rename ownocc8  own_1980
rename ownocc9  own_1990
rename ownocc0  own_2000
rename ownocc1a own_2010

drop ownocc*

save ncdb_hous, replace
*/

use ncdb_hous, clear

rename tothsun7  tothu_1970
rename tothsun8  tothu_1980
rename tothsun9  tothu_1990
rename tothsun0  tothu_2000
rename tothsun1  tothu_2010

rename vachu7  vachu_1970
rename vachu8  vachu_1980
rename vachu9  vachu_1990
rename vachu0  vachu_2000
rename vachu1  vachu_2010

keep geo2010 state stusab place cbsa* munit* mbed* hu_age* own_* tothu_* vachu_* educ_b* educ_hs* marshr* minc* emp* shrwht*

keep if cbsa != ""

*drop vachu1a tothsun1a

**Divide by tothsun....

reshape clear
reshape i geo2010 state stusab place cbsa
reshape j year, string
reshape xij munit1d munit1a munit2_4 munit5pl mbed0 mbed1 mbed2 mbed3 mbed4pl hu_age10_20 hu_age20_30 hu_age30_40 hu_age40pl own tothu vachu marshr educ_b educ_hs minc emp shrwht
reshape long

destring year, replace force ignore("_")

foreach v of varlist munit1d munit1a munit2_4 munit5pl mbed0 mbed1 mbed2 mbed3 mbed4pl hu_age10_20 hu_age20_30 hu_age30_40 hu_age40pl own vachu {

replace `v' = `v'/tothu
drop if `v' > 1 & `v' != .

}

gen source = "NCDB"

joinby place using "C:\Users\Matthew\Dropbox\Research\Urban\Working Data\place_city.dta", unmatched(master)

replace cc_status = 0 if cc_status == .

drop _merge

save ncdb_condo, replace
saveold ncdb_condo, replace
