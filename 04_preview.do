* 04_preview.do
* Preliminary analysis and data exploration using the merged dataset.

clear all
set more off

* Ensure 00_define_paths.do is run first to define global $data and $dofiles
do "$dofiles/00_define_paths.do"

* 1. Load the final dataset
use "$data/merged.dta", clear
stset duration, failure(termination_outcome==1) origin(time 0) id(conflict_id) exit(time .)

* 2. Descriptive Statistics
tabstat duration sanction_type is_terminated, statistics(mean sd min max count)

* Cross-tabulation: Sanction Type vs. Termination Event
tab termination_outcome sanction_type, col

* 3. Kaplan-Meier Survival Function Plot

* **Define Group Labels**
label define sanction_groups 0 "No Sanction (0)" 1 "Unilateral Sanction (1)" 2 "Multilateral Sanction (2)", replace
label values sanction_type sanction_groups

* The Kaplan-Meier plot visually shows the survival probability for different groups.
* Survival probability here refers to the probability of the conflict continuing.
sts graph, by(sanction_type) xlabel(0(5)25) ylabel(0(0.2)1) legend(order(1 "No Sanction" 2 "Unilateral Sanction" 3 "Multilateral Sanction") pos(1) col(1)) title("Kaplan-Meier Survival Function") subtitle("Grouped by Sanction Type") xtitle("Civil War Duration (Years)") ytitle("Conflict Survival Probability (Continuation)") 

