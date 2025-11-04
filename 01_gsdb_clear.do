* 01_step1_gsdb.do
* This file cleans the GSDB data and converts it to country-year format.

clear all
set more off
cd "/Users/gu/Documents/sanctions_civilwar/do"

* Make sure 00_define_paths.do is run first to define global $data
do "$dofiles/00_define_paths.do"

* 1. read-in dyadic sanction
* Use global macro for replicable path
import delimited "$data/gsdb_v4/GSDB_V4.csv", clear

* 2. refine country code
ssc install kountry, replace
kountry sanctioned_state, from(other) stuck
rename _ISO3N_ iso3

* 3. keep economic sanction（trade/financial）
* Keep only trade and financial sanctions, excluding arms/military (as per the implied focus on economic sanctions)
keep if trade==1 | financial==1

* 4. Convert Event Data (begin/end) to Country-Year Panel
sort case_id begin
by case_id: gen time_span = end - begin + 1
expand time_span
bys case_id: gen year = begin + _n - 1
keep if year>=1990 & year<=2022

* 5. Keep sanctioned state, year, and multilateral indicator
keep iso3 year sender_mult


* 6. Aggregate to country-year: use max to prioritize multilateral sanction (1) over unilateral (0)
collapse (max) sender_mult, by(iso3 year)

* 7. Create the sanction type variable
gen     sanction_type = 0                   // no sanction
replace sanction_type = 1 if sender_mult==0 // unilateral
replace sanction_type = 2 if sender_mult==1 // multilateral

label define typ 0 "No" 1 "Unilateral" 2 "Multilateral"
label val sanction_type typ

* 4. save data
* Use global macro for replicable path
save "$data/gsdb_v4/gsdb_cleared.dta", replace
