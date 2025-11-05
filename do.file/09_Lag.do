***09_lag term generation ***

* 1. Import Data
* use "$data/main.dta", clear 

* 2. Panel Data Structure
encode iso3, generate(country_id)
xtset country_id year, yearly

* 3. Lagged Dependent Variable
* L.conflict indicate previous year's conflict
gen L_conflict = L.conflict
label variable L_conflict "Conflict Status in Previous Year (L.conflict)"

* 4. Test
tabulate L_conflict, missing
list country_id year conflict L_conflict in 1/20

* 5. Save
save "main_lag.dta", replace

