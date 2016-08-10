capture program drop cut_ivreg
program cut_ivreg 

	args var steps yvar xvars_en xvar_ex iv ifs options options_iv title xtitle ytitle
	
	mat R = J(`steps'+1, 5, .)
	quietly sum `var', d
	local min = r(min)
	local max = r(p99)
	local step = (`max' - `min')/`steps' 
	local ii = 1
	
	forvalues i = `min'(`step')`max' {
	
		*disp `i'
		*disp "`xvars'" 
		*disp "`ifs'"
		*disp "`options'"
		quietly xtreg `yvar' `xvars_en' `xvars_ex' if `ifs' & `var' >= `i', `options'  
		mat R[`ii',1] = _b[`xvars_en']
		mat R[`ii',2] = _se[`xvars_en']
		mat R[`ii',3] = `i'
		*Specific for condo version
		quietly xtivreg `yvar' `xvars_ex' (`xvars_en' = `iv') if `ifs' & `var' >= `i', `options_iv'
		mat R[`ii',4] = _b[`xvars_en']
		mat R[`ii',5] = _se[`xvars_en']
		local ii = `ii' + 1
		
	}
	
	capture drop R1-R5
	svmat R
	capture drop ci_*
	gen ci_fe_l = R1-2*R2
	gen ci_fe_u = R1+2*R2
	gen ci_iv_l = R4-2*R5
	gen ci_iv_u = R4+2*R5
	#delimit ;
	twoway (line R1 R4 ci_fe_l ci_fe_u ci_iv_l ci_iv_u R3, lcolor(blue green blue blue green green) lpattern(solid solid dash dash dash dash)),
	name(iv_`yvar'_`var', replace)
	title("`title'")
	xtitle("`xtitle'")
	ytitle("Effect of Ownership on `ytitle'")
	legend(order(1 "FE" 2 "FE, IV"))
	note("Effect corresponds to estimate with sample restricted to neighborhoods above x-axis value."
	"Includes 95% confidence interval on estimate (dashed line).")
	graphregion(color(white)) bgcolor(white);
	#delimit cr
end

