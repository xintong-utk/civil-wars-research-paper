* 07_vdem_clear.do

clear all
set more off

* Ensure 00_define_paths.do is run first to define global $data and $dofiles
do "$dofiles/00_define_paths.do"

* 1. Load dataset
use "$data/V-Dem-CY-FullOthers-v15_dta/V-Dem.dta", clear

* 2. Variables Selection
keep country_text_id year v2x_polyarchy v2x_libdem v2x_corr
rename country_text_id iso3
rename v2x_polyarchy polyarchy_idx
rename v2x_libdem libdem_idx
rename v2x_corr corruption_idx

foreach var of varlist polyarchy_idx libdem_idx corruption_idx {
    replace `var' = . if `var' == -999
    label variable `var' "V-Dem `var' Index (Control)"
}

* 3. Filter Time Range
keep if year >= 1990 & year <= 2020
* 4. Create Panel Data
encode iso3, generate(country_id)
label variable country_id "Country ID"
label variable iso3 "ISO 3-Letter Country Code"
xtset country_id year, yearly
* Filter out all rows where control variables are missing
egen missing_count = rowmiss(polyarchy_idx libdem_idx corruption_idx)
drop if missing_count == 3
drop missing_count

*Display data summary
summarize polyarchy_idx libdem_idx corruption_idx
xtdescribe
list iso3 year polyarchy_idx in 1/10

* 5. Save
save "$data/vdem_clear.dta", replace

