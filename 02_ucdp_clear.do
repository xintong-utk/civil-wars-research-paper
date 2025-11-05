* 02_step2_ucdp.do
* This file cleans the UCDP data, refines the country code, and creates the DV.

clear all
set more off

* Make sure 00_define_paths.do is run first to define global $data
do "$dofiles/00_define_paths.do"

* 1. read-in ucdp_civilwar
* Use global macro for replicable path
use "$data/ucdp_term_conflict_dta/ucdp_term_conflict_cleaned.dta", clear

* 2. Refine countrycode
* Install kountry only if it's not already installed
cap ssc install kountry, replace
* Convert the conflict location code (GW code) to ISO3C for merging
kountry location, from(other) stuck
rename _ISO3N_ ncountry
kountry ncountry, from(iso3n) to(iso3c)
rename _ISO3C_ iso3

* 3. data clean：filter time range and conflict type
keep if year>=1990 & year<=2022              
keep if type_of_conflict2 == 3       // keep civilwar  

* 4. Create conflict duration variable
gen start_date2_numeric = date(start_date2, "MDY")
replace start_date2_numeric = date(start_date2, "MDY") if missing(start_date2_numeric)
gen start_year = year(start_date2_numeric)
label var start_year "Start Year (>25)" 

sort conflict_id
by conflict_id: gen conflict_duration = year - start_year + 1
replace conflict_duration = 1 if conflict_duration < 1 & !missing(conflict_duration)
label var start_year "date_conflict>25"
label var conflict_duration "Conflict Duration in Years"

* 5. Create the Dependent Variable: Termination Outcome      
gen termination_outcome = 0
label var termination_outcome "Civil War Termination Outcome"    //termination outcome
replace termination_outcome = 1 if outcome == 1                  //negociated
replace termination_outcome = 3 if outcome == 3                  //Government Victory
replace termination_outcome = 4 if outcome == 4                  //Rebel Victory
replace termination_outcome = 2 if outcome == 2    	  			 //Ceasefire

label define term_labels 0 "Ongoing" 1 "Negotiated Settlement" 2 "Ceasefire" 3  "Government Victory" 4 "Rebel Victory"
label values termination_outcome term_labels

* 6. Other Variable
gen conflict_intensity = intensity_level
label define intensity 1 "Minor" 2 "War"
label values conflict_intensity intensity

gen territory_conflict = (incompatibility == 1 | incompatibility == 3) if !missing(incompatibility)

* 7. Save Document
save "$data/ucdp_term_conflict_dta/ucdp_cleared.dta", replace
                                      
* Test
list iso3 conflict_duration termination_outcome conflict_intensity location region type_of_conflict2 outcome

desc
