*******************************************************
*Full MSA List (from Census rather than IPUMS extract)
*M. Miller, 15S
*******************************************************

clear
clear matrix

cd "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"

import excel using "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Geography\MSA List.xls", firstrow cellrange(A3:L1885)

*TO start, mimic current pull from IPUMS (could maybe use central status later on)

keep CBSACode CBSATitle FIPSStateCode MetropolitanMicropolitanStatis 

duplicates drop

rename CBSATitle msa_name
rename MetropolitanMicropolitanStatis metro_micro

gen     city_name = substr(msa_name, 1, strpos(msa_name, ",")-1)
replace city_name = substr(msa_name, 1, strpos(msa_name, "-")-1) if strpos(msa_name, "-") != 0 & strpos(msa_name, "-") < strpos(msa_name, ",")

**Define central city status depending on micro or metro.

gen     cc_status = 0
replace cc_status = 1 if metro_micro == "Metropolitan Statistical Area"

gen state = substr(msa_name, strpos(msa_name, ",")+1, 3)

replace state = trim(state)
replace city_name = trim(city_name)

save cen_city_full, replace
