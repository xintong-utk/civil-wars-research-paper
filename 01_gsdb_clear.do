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
rename _ISO3N_ ncountry
kountry ncountry, from(iso3n) to(iso3c)
rename _ISO3C_ iso3

* 3. keep economic sanction（trade/financial）
* Keep only trade and financial sanctions, excluding arms/military (as per the implied focus on economic sanctions)
keep if trade==1 | financial==1

* 4. Convert Event Data (begin/end) to Country-Year Panel
sort case_id begin
by case_id: gen time_span = end - begin + 1
expand time_span
bys case_id: gen year = begin + _n - 1
keep if year>=1990 & year<=2022

* 5. Aggregate to country-year: use max to prioritize multilateral sanction (1) over unilateral (0)
collapse (max) sender_mult, by(iso3 year)

* 6. Create the sanction type variable
gen     sanction_type = 0                   // no sanction
replace sanction_type = 1 if sender_mult==0 // unilateral
replace sanction_type = 2 if sender_mult==1 // multilateral

label define typ 0 "No" 1 "Unilateral" 2 "Multilateral"
label val sanction_type typ

* 7. save data
* Use global macro for replicable path
save "$data/gsdb_v4/gsdb_cleared.dta", replace

* Expanded GSDB
clear all
set more off

do "$dofiles/00_define_paths.do"

import delimited "$data/gsdb_v4/GSDB_V4.csv", clear
* Re-apply country code conversion and filtering
kountry sanctioned_state, from(other) stuck
rename _ISO3N_ iso3             // Use Alpha Code
keep if trade==1 | financial==1
* Convert Event Data to Country-Year Panel
sort case_id begin
by case_id: gen time_span = end - begin + 1
expand time_span
bys case_id: gen year = begin + _n - 1
keep if year>=1990 & year<=2022
collapse (max) financial trade, by(iso3 year)

* Create the sanction type variable based on the combination of types
keep if trade==1 | financial==1

* Convert Event Data to Country-Year Panel
sort case_id begin
by case_id: gen time_span = end - begin + 1
expand time_span
bys case_id: gen year = begin + _n - 1
keep if year>=1990 & year<=2022

* Aggregate to country-year, using max to identify the strongest type present that year
* If both financial (2) and trade (3) are present, the max of (2,3) is not right.
* We collapse by taking the MAX of financial and MAX of trade separately.

collapse (max) financial trade, by(iso3 year)

* Create the sanction type variable based on the combination of types
gen sanction_type = 0
* Type 1: Both Financial and Trade
replace sanction_type = 4 if financial == 1 & trade == 1
* Type 2: Only Trade (or Trade + Arms/Other)
replace sanction_type = 3 if financial == 0 & trade == 1
* Type 3: Only Financial (or Financial + Arms/Other)
replace sanction_type = 2 if financial == 1 & trade == 0

label define s_typ 1 "Both" 2 "Trade" 3 "Financial"
label val sanction_type s_typ

* Save expanded data
sort iso3 year
save "$data/gsdb_v4/gsdb_expanded.dta", replace
