
capture program drop estnice
program estnice

		args xlist year lag set

		#delimit ;
		esttab est* using "$out\\`set'_spec`year'_`lag'.csv", 
		replace label title("`set' Spec `year' (Lag `lag') - [Dep Var = Condo Percentage]") 
		order(`xlist')  
		mlabel("`year' (+)" "`year' (-)" "`year' (Full)") 
		r2 ar2 se brackets addn("(+) indicates forward stepwise, (-) indicates backward stepwise.");
		esttab est* using "$out\\`set'_spec`year'_`lag'.tex", 
		replace label title("`set' Spec `year' - [Dep Var = Condo Percentage]") 
		order(`xlist')
		mlabel("`year' (+)" "`year' (-)" "`year' (Full)") 
		r2 ar2 se brackets addn("(+) indicates forward stepwise, (-) indicates backward stepwise. Stopping critera $\alpha = 0.1$ ");;
		# delimit cr
		clear matrix
end
