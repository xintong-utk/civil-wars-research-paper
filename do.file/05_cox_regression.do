* 04_cox_regression.do
* Runs the core survival analysis (Cox Proportional Hazards Model) to test the hypothesis.

clear all
set more off

* Ensure 00_define_paths.do is run first to define global $data and $dofiles
do "$dofiles/00_define_paths.do"

* 1. Load the final dataset (with or without external controls)
use "$data/merged.dta", clear

* 2. Re-establish Survival Data
* duration: duration variable; is_terminated: event indicator; conflict_id: panel ID
stset duration, failure(is_terminated == 1) origin(time 0) id(conflict_id)

* Convert region string variable to numeric factor variable
cap encode region, gen(region_numeric)

* 3. Model 1: Baseline Regression (Naked Model)
* Core variables: Sanction Type (i.sanction_type)
* Conflict controls: Region (i.region_numeric) and global time trend (year)
stcox i.sanction_type i.region_numeric year, nohr 
est store M1_Baseline
