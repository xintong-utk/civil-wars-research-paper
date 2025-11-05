#Overview
This repository contains all data-processing and analysis code for the article: 
How External Economic Sanctions Shape Civil War Outcomes: Comparing Multilateral and Unilateral Sanctions

#Authors: Zi Gu & Xin Tong  

#Research Question: How do multilateral and unilateral sanctions affect civil war outcomes?

We argue that:  
Multilateral sanctions, backed by international institutions, facilitate negotiated settlements by mitigating the commitment problem.  
Unilateral sanctions weaken state capacity and increase the likelihood of rebel victory, prolonging conflict.

#Data Sources
GSDB: Global Sanctions Database for sender identity & scope
TIES: Threat and Imposition of Sanctions for timing & enforcement
UCDP Conflict Termination v3: Civil war outcomes (1990–2022)
World Bank WDI, Polity V, V-Dem: Controls for GDP, regime type, institutions

DV: Civil war outcome (ongoing/negotiated/rebel/government).  
IV: Sanction type (none/unilateral/multilateral).  

#Code Files and Function
`00_define_paths.do`: Define project directories.
`01_gsdb_clear.do`: Clean GSDB sanctions.
`02_ucdp_clear.do`: Process UCDP conflict data.
`03_merge.do`: Merge sanction & conflict datasets.
`04_preview.do`: Generate descriptive statistics.
`05_cox_regression.do`: Run Cox & multinomial logit models.
`06_gdp_clear.do`: Add GDP covariates.
`07_VDem_clear.do`: Import V-Dem indicators.
`08_pop_clear.do`: Add population controls.
