* 06_wdi_clear.do
* Purpose: Imports, cleans, and prepares World Development Indicators (WDI) data 

clear all
set more off
do "$dofiles/00_define_paths.do"

* 1. Import Data& & Clean
import delimited using "$data/WDI_GDP.csv", rowrange(5) clear

rename v2 iso3
rename v1 country_name
drop in 1
keep iso3 v35-v65
local year = 1990
forvalues i = 35/65 {
    rename v`i' gdp_`year'
    local year = `year' + 1
}

reshape long gdp_, i(iso3) j(year)
rename gdp_ gdp_pcap_us_curr
label variable gdp_pcap_us_curr "GDP per capita (current US$)"

* 2. logarithmic transformation
gen ln_gdp_pcap = log(gdp_pcap_us_curr)
label variable ln_gdp_pcap "ln(GDP per capita, current US$)"
drop if missing(ln_gdp_pcap)

* 3. Panel Data Structure
encode iso3, generate(country_id)
label variable country_id "Country ID"
xtset country_id year, yearly

* 4. Save
save "$data/gdp_clear.dta", replace

* 5. Abstract
summarize ln_gdp_pcap
list iso3 year ln_gdp_pcap in 1/10

*
