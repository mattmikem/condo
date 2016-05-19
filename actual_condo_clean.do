***********************************************
*Build of Actual Condo data from Census Custom
*M. Miller, 16W
***********************************************

cd "L:\Research\Condos\Working Data"
*cd "C:\Users\Matthew\Desktop\ECON\Research\Urban\Papers\Condos\Working"

clear
clear matrix

set more off

global ccust = "C:\Users\mmiller\Dropbox\Research\Urban\Data\Census Custom"

import delimited using "$ccust\S46201_140.csv", rowrange(3:) varnames(3) delim(",")

*Test for condo values 

keep tblid - order wcnt0 
drop title

reshape clear
reshape i tblid - geoname 
reshape j order
reshape xij wcnt0
reshape wide

split geoid, parse("US")
destring geoid2, gen(geo2010)

gen year = 2010

save actual_condo, replace

**These differences are generally fineL min -5, max 6, likely due to a rounding issue from Census restrictions. 

*egen total = rowtotal(wcnt02 wcnt03)

*gen diff = wcnt01 - total

*sum diff

/*

split geoname, parse(",")

collapse (sum) wcnt0*, by(geoname2 geoname3)

