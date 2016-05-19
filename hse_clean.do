

cd "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Programs"

global work = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Working"

clear

do saiz_hse

gen stem = ""

replace stem = substr(msa, 1, strpos(msa,",")-1)
replace stem = substr(msa, 1, strpos(msa, "*")-1) if strpos(stem, "*") != 0 | stem == ""

rename stem city_name 

drop rank msa

save "$work\hse_city.dta", replace
