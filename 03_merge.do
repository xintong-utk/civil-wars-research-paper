* 03_step3_merge.do
* This file merges the cleaned UCDP (Conflict-Year) and GSDB data.

clear all
set more off
do "$dofiles/00_define_paths.do"

* 1. Load UCDP data
use "$data/ucdp_term_conflict_dta/ucdp_cleared.dta", clear
sort iso3 year

* 2. Merge GSDB data
* "Many-to-One" merge：The GSDB data is Country-Year, and UCDP is Conflict-Year.
merge m:1 iso3 year using "$data/gsdb_v4/gsdb_cleared.dta"

* 3. Clean up the merged data
* The 'merge' indicator variable shows how the GSDB data matched:
* _merge == 1: Only in Master (UCDP conflict, but NO sanction for that country-year)
* _merge == 3: Matched (UCDP conflict with sanction for that country-year)
* We must explicitly recode the missing sanction_type (where _merge==1) to 0 (No Sanction).
tab _merge, m

* Recode sanction_type: missing sanctions become 'No Sanction' (0)
replace sanction_type = 0 if _merge == 1 
label val sanction_type typ
* Drop observations that only appeared in the sanction datas2et (no conflict)
drop if _merge == 2
* Drop the temporary merge variable
drop _merge

* 4. Final cleaning and saving
* Keep only relevant variables for model estimation (DV and IV)
keep conflict_id location year iso3 termination_outcome sanction_type region conflict_duration
* Generate a continuous conflict duration variable if needed (optional step for analysis)
bysort conflict_id: gen t = conflict_duration
label var t "Conflict Duration Year"
rename t duration

* 5 Data for Survival Analysis
gen is_terminated = 0
replace is_terminated = 1 if termination_outcome != 0
label var is_terminated "Conflict Termination Event (1=Yes, 0=Censored)"
* For Cox/Parametric models
* id(conflict_id): Unique identifier conflict
* failure(is_terminated): event variable(1=occurence)
* time(t): Duration variabl (Conflict Duration Year)
stset duration, failure(termination_outcome) id(conflict_id) exit(time .) scale(1)

* 6 Save the final merged dataset
save "$data/merged.dta", replace
desc

* 7 Check 
list conflict_id duration iso3 termination_outcome sanction_type if inlist(sanction_type, 0, 1, 2) & inrange(year, 1990, 1995), sep(5)
tab termination_outcome sanction_type, col nofreq

