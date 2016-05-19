**Income Percentile

local j = 0

forvalues y = 1970(10)2010 {

forvalues j = 0/$N {

disp "`y': `j'"

quietly sum minc if cbsa_num == `j' & year == `y', d

if r(N) > 0 {

local q = r(N)

if `q' > 100 {

xtile incp`y'_`j' = minc if cbsa_num == `j' & year == `y', nq(100)

}

else if  `q' > 50 {

xtile incp`y'_`j' = minc if cbsa_num == `j' & year == `y', nq(50)
replace incp`y'_`j' = incp`y'_`j'*2

}

else if  `q' > 25 {

xtile incp`y'_`j' = minc if cbsa_num == `j' & year == `y', nq(25)
replace incp`y'_`j' = incp`y'_`j'*4

}

else {

*xtile incp`y'_`j' = minc if cbsa_num == `j' & year == `y', nq(10)
*replace incp`y'_`j' = incp`y'_`j'*10

}

}

}

}

egen incp = rowtotal(incp*)
drop incp_*


