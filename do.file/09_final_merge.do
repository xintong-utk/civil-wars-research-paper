* Final Data
clear all
set more off

do "/Users/gu/Documents/sanctions_civilwar/do/00_define_paths.do"
use "/Users/gu/Documents/sanctions_civilwar/data/merged.dta"

* =======================================================
* Step 1: Load and Merge Country-Year Controls into Master File

sort iso3 year
encode iso3, gen(country_id)
drop iso3
rename country_id iso3
rename iso3 iso3_num
decode iso3_num, gen(iso3) 
sort iso3 year

* 2. Merge GDP per Capita Data
merge m:1 iso3 year using "$data/gdp_clear.dta"
drop if _merge == 2
drop _merge

* 3. Merge Total Population Data
merge m:1 iso3 year using "$data/pop_clear.dta"
drop if _merge == 2
drop _merge

* 4. Merge V-Dem Data 
merge m:1 iso3 year using "$data/vdem_clear.dta"
drop if _merge == 2
drop _merge
keep if polyarchy_idx != .

* Save the conflict-year master file for later merge
save "$output/merged_temp_master.dta", replace

* =======================================================
* Step 2 Generate lagged variable

* 1. Generate Lagged Variables
gen L_ln_gdp_pcap = L.ln_gdp_pcap
gen L_ln_pop = L.ln_pop
gen L_polyarchy_idx = L.polyarchy_idx

* 2. Keep only the numeric key and the new lagged variables
keep iso3_num year L_ln_gdp_pcap L_ln_pop L_polyarchy_idx
sort iso3_num year
save "$output/merged_temp_lags.dta", replace

* =======================================================
* Step 3 Merge Lagged Data
use "$ouput/merged_temp_master.dta", clear

* 1. Drop the contemporaneous control variables
drop ln_gdp_pcap ln_pop polyarchy_idx

* 2. Merge the new lagged variables back using the consistent NUMERIC key
merge m:1 iso3_num year using "$output/merged_temp_lags.dta"

* Final cleanup
drop if _merge == 2 | _merge == 1 
drop _merge
keep if L_ln_gdp_pcap != .
label variable L_ln_gdp_pcap "Lagged ln(GDP per Capita)"
label variable L_ln_pop "Lagged ln(Total Population)"
label variable L_polyarchy_idx "Lagged V-Dem Polyarchy Index" 

* =======================================================
save "$output/merged_final.dta", replace
