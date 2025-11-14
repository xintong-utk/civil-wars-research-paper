* 10_model_analyse.do

clear all
set more off
do "$dofiles/00_define_paths.do"

* 1. Load the final dataset
use "$output/merged_final.dta", clear
encode iso3, gen(iso3_num)
encode region, gen(region_num)
encode location, gen(location_num)
xtset conflict_id year
recode termination_outcome (1=1) (0 2 3=0), gen(d_negotiate)

* H1
ssc install firthlogit
firthlogit d_negotiate i.sanction_type duration gdp_pcap_us_curr pop_total libdem_idx corruption_idx

* H2 
* set base: unilateral, only keep uni/multilateral

keep if inlist(sanction_type,1,2
gen multi = (sanction_type==2)
firthlogit d_negotiate multi duration gdp_pcap_us_curr pop_total libdem_idx corruption_idx

* 把"谈判"与"军事胜利"合并成"冲突终止"，问题改为：
recode termination_outcome (1/3=1), gen(d_ended)
keep if inlist(sanction_type,1,2)

* H3
use "$output/merged_final.dta", clear
encode iso3, gen(iso3_num)
encode iso3, gen(iso3_num)keep if inlist(sanction_type,1,2)
recode termination_outcome (2=1) (0 1 3=0), gen(d_rebelwin)
tab sanction_type d_rebelwin
firthlogit d_rebelwin i.sanction_type duration gdp_pcap_us_curr pop_total libdem_idx corruption_idx

*Lagged
xtset conflict_id year
firthlogit d_negotiate i.sanction_type L_ln_gdp_pcap L_ln_pop L_polyarchy_idx

gen L_dur   = L.duration
gen gdp_gr  = (gdp_pcap_us_curr - L.gdp_pcap_us_curr)/L.gdp_pcap_us_curr
* 交互项
gen multi = (sanction_type == 2)
gen multiXpoly = multi * L_polyarchy_idx
gen multiXgr   = multi*gdp_gr
relogit d_negotiate multi L_polyarchy_idx multiXpoly conflict_duration L_ln_gdp_pcap L_ln_pop corruption_idx, cluster(iso3_num)
. 


gen L1_sanction_type = L1.sanction_type

recode termination_outcome (1=1) (0 2 3=0), gen(d_negotiate)
recode termination_outcome (2=1) (0 1 3=0), gen(d_rebelwin)
keep if inlist(sanction_type,1,2)
gen unilateral = (sanction_type==1)   
gen L1_unilateral = L.unilateral 
relogit d_negotiate L1_unilateral duration gdp_pcap_us_curr pop_total libdem_idx corruption_idx, cluster(iso3_num)
relogit d_rebelwin L1_unilateral duration gdp_pcap_us_curr pop_total libdem_idx corruption_idx, cluster(iso3_num)


///

mlogit termination_outcome i.sanction_type conflict_duration gdp_pcap_us_curr pop_total libdem_idx corruption_idx i.region_num i.location_num, baseoutcome(0) vce(cluster iso3_num)
//
recode termination_outcome (1=1) (0 2 3=0), gen(d_negotiate)
logit d_negotiate i.sanction_type conflict_duration gdp_pcap_us_curr pop_total libdem_idx corruption_idx i.region_num i.location_num, vce(cluster iso3_num)
relogit d_ended multi duration gdp_pcap_us_curr pop_total libdem_idx corruption_idx, cluster(iso3_num)


* 2. Redefine the data structure of survival analysis
* id(conflict_id): conflict_id (Panel ID)
* failure(is_terminated): termination_outcome 
* time(duration): duration
* failure(termination_outcome)is multiple variable
stset duration, failure(termination_outcome) id(conflict_id) exit(time .) scale(1)

* Check Distribution of dependent variable
tab termination_outcome, m label

gen compete_risk = .
replace compete_risk = 1 if fail == 1
replace compete_risk = 2 if inlist(fail, 2, 3, 4)
