*************************************************
*Condos - Import Saiz Supply Elasticities
*M. Miller, 16W+
*************************************************


cd "L:\Research\Resurgence\Working Files"

clear
clear matrix
clear mata

set maxvar 8000
set more off

global data = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Condos\FOR_MATT\Literature"

import excel "$data\Saiz (2010, QJE).xlsx", sheet("Table 46") first

preserve
rename R   rank
rename MSA msa
rename S   sup_el

keep rank msa sup_el

save se1, replace

restore

rename D rank 
rename E msa 
rename F sup_el

keep rank msa sup_el

append using se1

*Overwrite se1

save se1, replace
clear

import excel "$data\Saiz (2010, QJE).xlsx", sheet("Table 48")

preserve
rename A rank 
rename B msa
rename C sup_el

keep rank msa sup_el

append using se1
save se1, replace

restore

rename D rank 
rename E msa 
rename F sup_el

keep rank msa sup_el

append using se1
save se1, replace

drop if rank == .

sort rank

browse

**This is only used to create mapping.

*export excel "List_HSE.xlsx"

