* 08_step8_pop.do
* This file cleans the WPI Populatio total data.

clear all
set more off

* Make sure 00_define_paths.do is run first to define global $data
do "$dofiles/00_define_paths.do"

* * 1. read-in WDI.Pop Data
import delimited using "$data/WDI_POPULATION.csv", clear rowrange(5)

* 2. Clean Variable name
* Mannually claen

rename v2 iso3
rename v1 country_name
drop in 1

*Filter the range of variables(v35:1990 to v65:2020)
keep iso3 v35-v65

* 3. Convert the data from wide format to long format
local year = 1990
forvalues i = 35/65 {
    rename v`i' pop_`year'
    local year = `year' + 1
}
reshape long pop_, i(iso3) j(year)

*Rename population variable
rename pop_ pop_total
label variable pop_total "Total Population"

* 4. Logarithmic Transformation
*In panel analysis, the population size is usually taken as the logarithm
gen ln_pop = log(pop_total)
label variable ln_pop "ln(Total Population)"
drop if missing(ln_pop)

* 5. Panel Data Structure
encode iso3, generate(country_id)
label variable country_id "Country ID (Numeric)"
xtset country_id year, yearly

* 6. Save Data
save "$data/pop_clear.dta", replace

* 7. 最终显示数据摘要
summarize ln_pop
list iso3 year ln_pop in 1/10
