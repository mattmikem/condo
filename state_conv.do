********************************************
*State Conversion Clean
*M. Miller, 15X
********************************************

cd "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"

capture log close

clear
clear matrix
clear mata

set more off

insheet using "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\State_conversion_legislation\Data_forstata\conversions_dataset_02.txt", tab

drop v*

gen     prime_st = state
replace prime_st = substr(prime_st, 1, strpos(prime_st, "-")-1) if strpos(prime_st,"-") != 0
replace prime_st = substr(prime_st, 1, strpos(prime_st, "/")-1) if strpos(prime_st,"/") != 0

keep prime_st rtp_cat1 notice_cat1

duplicates drop

gen rtp_cat = 0
replace rtp_cat = 1 if rtp_cat1 < 3
gen notice_cat = 0
replace notice_cat = 1 if notice_cat1 < 3

*Temporary

duplicates drop prime_st, force

save st_conv, replace
