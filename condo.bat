:: ----condo.bat------

:: This is the batch file for condo project. Inputs:
:: 'usa_00014' imports and labels IPUMS file.
:: 'full_msalist' imports full set of MSAs (not just those in IPUMS)
:: 'place_quick' imports 2010 Census Places file 
:: 'condo_ncdb' turns raw NCDB into form with vars relevant for condo analysis
:: 'ords' builds in Ordinance data for Municipalities/States; note that this is merged on using a CBSA-city_name list pulled (superceded by 'ords_full')
:: 'condo_predict' analysis as CONSPUMA level
:: 'condo_predict_msa' analysis at MSA-CC level
:: 'condo_predict_ncdb' supersedes other 'condo_predict' programs and works at neighborhood level

statase -b usa_00014.do
statase -b fullmsa_list.do
statase -b place_quick.do
statase -b state_xwalk.do
statase -b condo_ncdb.do
statase -b ords_full.do
statase -b state_conv.do
::statase -b condo_predict_msa.do
statase -b condo_predict_ncdb.do

::Regulation based analysis

statase -b boundary_build.do
::statase -b ords_analysis.do  
statase -b dd_iv_analysis.do
statese -b boundary_analysis.do


	