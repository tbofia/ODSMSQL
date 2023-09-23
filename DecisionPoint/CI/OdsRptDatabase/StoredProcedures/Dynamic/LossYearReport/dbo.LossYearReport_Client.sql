IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LossYearReport_Client') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.LossYearReport_Client
GO

CREATE PROCEDURE  dbo.LossYearReport_Client (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0,
@IsZeroAllowedFiltered INT  = 0)
AS
BEGIN
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@RunType INT = 0,	@if_Date AS DATETIME = NULL,@ReportType INT = 5,@OdsCustomerId INT = 44,@IsAllowedFilter INT = 0;

DECLARE @SQLScript VARCHAR(MAX);

ALTER INDEX ALL ON  stg.LossYearReport_Client DISABLE;

SET @SQLScript = CAST ('' AS VARCHAR(MAX)) + '

IF OBJECT_ID(''tempdb..#LossYearReport_Filtered'') IS NOT NULL DROP TABLE #LossYearReport_Filtered;
SELECT  OdsCustomerId,  
		CompanyName,  
		SOJ, 
		AgeGroup, 
		DateQuarter, 
		FormType,
		CoverageType,
		EncounterTypePriority,
		ServiceGroup,
		RevenueCodeCategoryId,
		Gender, 
		Outlier_cat, 
		ClaimantState,
		ClaimantCounty, 
		ProviderSpecialty, 
		ProviderState, 
		InjuryNatureId,
		CmtIdNo, 
		DT_SVC,
		Period,
		CASE WHEN  '+CAST(@IsZeroAllowedFiltered AS CHAR(1))+' = 0 THEN 0 ELSE 1 END IsAllowedGreaterThanZero,
		Allowed, 
		Charged, 
		Units 
INTO #LossYearReport_Filtered
FROM  stg.LossYearReport_Filtered
WHERE IsAllowedGreaterThanZero = CASE WHEN '+CAST(@IsZeroAllowedFiltered AS CHAR(1))+' = 0 THEN IsAllowedGreaterThanZero ELSE 1 END
'+

--National Map
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt
)
SELECT 11 as ReportID,
		''nationalmap'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			IsAllowedGreaterThanZero
		) X
GROUP BY 
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+ 

--state_state_outlier_pvdstate_no_formtype
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero,
	ProviderState, 
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt
	)
SELECT 1 ReportID,
		''state_state_outlier_pvdstate_no_formtype'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		IsAllowedGreaterThanZero,
		ProviderState, 
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			IsAllowedGreaterThanZero,
			ProviderState,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			IsAllowedGreaterThanZero,
			ProviderState
		)X
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero,
	ProviderState
OPTION (HASH GROUP);
'+ 

--age_state_outlier_pvdstate_no_formtype_rvgrp
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	AgeGroup, 
	DateQuarter, 
	CoverageType,
	RevenueCodeCategoryId,
	Outlier_cat, 
	ClaimantState, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt
)
SELECT 3 ReportID,
		''age_state_outlier_pvdstate_no_formtype_rvgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		AgeGroup, 
		DateQuarter, 
		CoverageType,
		RevenueCodeCategoryId,
		Outlier_cat, 
		ClaimantState, 
		ProviderState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			AgeGroup,
			DateQuarter, 
			CoverageType,
			RevenueCodeCategoryId,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo, 
			SOJ, 
			AgeGroup,
			DateQuarter, 
			CoverageType,
			RevenueCodeCategoryId,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
		)X
GROUP BY  OdsCustomerId,
	SOJ, 
	AgeGroup,
	DateQuarter, 
	CoverageType,
	RevenueCodeCategoryId,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--specialty_state_outlier_pvdstate_no_formtype
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState, 
	ProviderSpecialty, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt
)
SELECT 7 ReportID,
		''specialty_state_outlier_pvdstate_no_formtype'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState, 
		ProviderSpecialty, 
		ProviderState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter,
			CoverageType, 
			Outlier_cat, 
			ClaimantState,
			ProviderSpecialty,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter,
			CoverageType, 
			Outlier_cat, 
			ClaimantState,
			ProviderSpecialty,
			ProviderState,
			IsAllowedGreaterThanZero
		)X    
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter,
	CoverageType, 
	Outlier_cat, 
	ClaimantState,
	ProviderSpecialty,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+
		
--gender_state_outlier_pvdstate_no_formtype
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Gender, 
	Outlier_cat, 
	ClaimantState, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 9 ReportID,
		''gender_state_outlier_pvdstate_no_formtype'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Gender, 
		Outlier_cat, 
		ClaimantState, 
		ProviderState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Gender,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY  
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Gender,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
		)X    
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Gender,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--county_severity_map
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState, 
	ClaimantCounty,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 14 ReportID,
		''county_severity_map'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState, 
		ClaimantCounty,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			ClaimantCounty,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			ClaimantCounty,
			IsAllowedGreaterThanZero
		)X    
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	ClaimantCounty,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--national_pip_map
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 12 ReportID,
		''national_pip_map'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units, 
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo, 
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			IsAllowedGreaterThanZero
		) X   
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--state_state_outlier_pvdstate_srvcgrp_rvgrp
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	RevenueCodeCategoryId,
	Outlier_cat, 
	ClaimantState, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 2 ReportID,
		''state_state_outlier_pvdstate_srvcgrp_rvgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		FormType,
		CoverageType,
		ServiceGroup,
		RevenueCodeCategoryId,
		Outlier_cat, 
		ClaimantState, 
		ProviderState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			RevenueCodeCategoryId,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			RevenueCodeCategoryId,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
		)X    
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	RevenueCodeCategoryId,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+  

--age_state_outlier_pvdstate_srvcgrp_rvgrp
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	AgeGroup, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	RevenueCodeCategoryId,
	Outlier_cat, 
	ClaimantState, 
	ProviderState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 4 ReportID,
		''age_state_outlier_pvdstate_srvcgrp_rvgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		AgeGroup, 
		DateQuarter, 
		FormType,
		CoverageType,
		ServiceGroup,
		RevenueCodeCategoryId,
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			AgeGroup,
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			RevenueCodeCategoryId,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo, 
			SOJ, 
			AgeGroup,
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			RevenueCodeCategoryId,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
		) X   
GROUP BY OdsCustomerId, 
	SOJ, 
	AgeGroup,
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	RevenueCodeCategoryId,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--specialty_state_outlier_pvdstate_srvcgrp
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	Outlier_cat, 
	ClaimantState, 
	ProviderSpecialty, 
	ProviderState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 8 ReportID,
		''specialty_state_outlier_pvdstate_srvcgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		FormType,
		CoverageType,
		ServiceGroup,
		Outlier_cat, 
		ClaimantState, 
		ProviderSpecialty, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo, 
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			Outlier_cat, 
			ClaimantState,
			ProviderSpecialty,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			Outlier_cat, 
			ClaimantState,
			ProviderSpecialty,
			ProviderState,
			IsAllowedGreaterThanZero
		) X   
GROUP BY  OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		FormType,
		CoverageType,
		ServiceGroup,
		Outlier_cat, 
		ClaimantState,
		ProviderSpecialty,
		ProviderState,
		IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--gender_state_outlier_pvdstate_srvcgrp_rvgrp*/
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	RevenueCodeCategoryId,
	Gender, 
	Outlier_cat, 
	ClaimantState, 
	ProviderState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 10 ReportID,
		''gender_state_outlier_pvdstate_srvcgrp_rvgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		FormType,
		CoverageType,
		ServiceGroup,
		RevenueCodeCategoryId,
		Gender, 
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			RevenueCodeCategoryId,
			Gender,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			ServiceGroup,
			RevenueCodeCategoryId,
			Gender,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
			) X  
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	RevenueCodeCategoryId,
	Gender,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--injury_state_outlier_pvdstate_no_formtype
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState, 
	ProviderState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt,
	InjuryNatureId)
SELECT 5 ReportID,
		''injury_state_outlier_pvdstate_no_formtype'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt,
		InjuryNatureId
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			InjuryNatureId,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			InjuryNatureId
		) X 
GROUP BY OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		ProviderState,
		IsAllowedGreaterThanZero,
		InjuryNatureId
OPTION (HASH GROUP);
'+

--injury_state_outlier_pvdstate_srvcgrp
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	ServiceGroup,
	Outlier_cat, 
	ClaimantState, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt,
	InjuryNatureId)
SELECT 6 ReportID,
		''injury_state_outlier_pvdstate_srvcgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		FormType,
		CoverageType,
		ServiceGroup,
		Outlier_cat, 
		ClaimantState, 
		ProviderState,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt,
		InjuryNatureId
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter,
			FormType, 
			CoverageType,
			ServiceGroup,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			InjuryNatureId,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter,
			FormType, 
			CoverageType,
			ServiceGroup,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			InjuryNatureId
		) X 
GROUP BY OdsCustomerId, 
		SOJ, 
		DateQuarter,
		FormType, 
		CoverageType,
		ServiceGroup,
		Outlier_cat, 
		ClaimantState,
		ProviderState,
		IsAllowedGreaterThanZero,
		InjuryNatureId
OPTION (HASH GROUP);
'+	
		
--National_Injury_Map
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt,
	InjuryNatureId)
SELECT 13 ReportID,
		''National_Injury_Map'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt,
		InjuryNatureId
FROM (
SELECT I.OdsCustomerId, 
		I.CmtIDNo,
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		IsAllowedGreaterThanZero,
		InjuryNatureId,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT DT_SVC) DT_SVC
FROM #LossYearReport_Filtered I
GROUP BY 
		I.OdsCustomerId, 
		I.CmtIDNo,
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		IsAllowedGreaterThanZero,
		InjuryNatureId
    )X    
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	IsAllowedGreaterThanZero,
	InjuryNatureId
OPTION (HASH GROUP);
'+	
		
--county_injury_map
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState, 
	ClaimantCounty,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt,
	InjuryNatureId)
SELECT 15 ReportID,
		''county_injury_map'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState, 
		ClaimantCounty,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt,
		InjuryNatureId
FROM (	
	SELECT I.OdsCustomerId, 
			I.CmtIDNo, 
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			ClaimantCounty,
			IsAllowedGreaterThanZero,
			InjuryNatureId,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			Outlier_cat, 
			ClaimantState,
			ClaimantCounty,
			IsAllowedGreaterThanZero,
			InjuryNatureId
		) X  
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	ClaimantCounty,
	IsAllowedGreaterThanZero,
	InjuryNatureId
OPTION (HASH GROUP);
'+
		
--state_state_outlier_pvdstate_no_formtype_period
'
SELECT I.OdsCustomerId, 
		I.CmtIDNo,
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		ProviderState,
		Period,
		CASE                                        /*Prepping for cummulative sum By Period*/
	 		WHEN Period =   ''b4 dol'' THEN 0
	 		WHEN Period =   ''1st Quarter'' THEN 1
			WHEN Period =   ''2nd Quarter'' THEN 2
			WHEN Period =   ''3rd Quarter'' THEN 3
			WHEN Period =   ''4th Quarter'' THEN 4
			WHEN Period =   ''5th Quarter'' THEN 5
			WHEN Period =   ''6th Quarter'' THEN 6
			WHEN Period =   ''7th Quarter'' THEN 7
			WHEN Period =   ''8th Quarter'' THEN 8
			WHEN Period =   ''ultimate'' THEN 9 END PeriodId,
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units,
		COUNT(DISTINCT DT_SVC) DT_SVC	
INTO #ForCummulativeSum	   
FROM #LossYearReport_Filtered I
GROUP BY 
		I.OdsCustomerId, 
		I.CmtIDNo,
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState,
		ProviderState,
		Period,
		CASE 
	 		WHEN Period =   ''b4 dol'' THEN 0
	 		WHEN Period =   ''1st Quarter'' THEN 1
			WHEN Period =   ''2nd Quarter'' THEN 2
			WHEN Period =   ''3rd Quarter'' THEN 3
			WHEN Period =   ''4th Quarter'' THEN 4
			WHEN Period =   ''5th Quarter'' THEN 5
			WHEN Period =   ''6th Quarter'' THEN 6
			WHEN Period =   ''7th Quarter'' THEN 7
			WHEN Period =   ''8th Quarter'' THEN 8
			WHEN Period =   ''ultimate'' THEN 9 END,
		IsAllowedGreaterThanZero

INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState, 
	ProviderState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt,
	Period)
SELECT 16 ReportID,
		''state_state_outlier_pvdstate_no_formtype_period'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt,
		Period 
FROM (
	SELECT  t1.OdsCustomerId, 
			t1.CmtIDNo,		   
			t1.SOJ, 			
			t1.DateQuarter, 			
			t1.CoverageType,			
			t1.Outlier_cat, 
			t1.ClaimantState, 			
			t1.ProviderState, 
			t1.IsAllowedGreaterThanZero,
			t1.Period,
			SUM(t2.Allowed) Allowed, 
			SUM(t2.Charged) Charged, 
			SUM(t2.UNITS) Units, 
			SUM(t2.DT_SVC) DT_SVC			
	FROM #ForCummulativeSum t1            /*Sum cummulative By Period*/
	INNER JOIN #ForCummulativeSum t2 
		ON t1.OdsCustomerId = t2.OdsCustomerId
		AND t1.Cmtidno = t2.Cmtidno
		AND t1.SOJ	=	 t2.SOJ
		AND t1.DateQuarter	=	t2.DateQuarter	
		AND t1.CoverageType	=	t2.CoverageType	
		AND t1.Outlier_cat = t2.Outlier_cat
		AND t1.ClaimantState =	 t2.ClaimantState		
		AND t1.ProviderState  = t2.ProviderState
		AND t1.IsAllowedGreaterThanZero = t2.IsAllowedGreaterThanZero
		AND t1.PeriodId >= t2.PeriodId  /*Sum cummulative By Period*/
	GROUP BY t1.OdsCustomerId, 
			t1.CmtIDNo,		   
			t1.SOJ, 			
			t1.DateQuarter, 			
			t1.CoverageType,			
			t1.Outlier_cat, 
			t1.ClaimantState, 			
			t1.ProviderState, 
			t1.IsAllowedGreaterThanZero,
			t1.Period
	)X
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero,
	Period
OPTION (HASH GROUP);
'+
		
--EncounterTYpe_state_state_outlier_pvdstate_no_formtype
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	EncounterTypePriority,
	Outlier_cat, 
	ClaimantState, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 17 ReportID,
		''encountertype_state_state_outlier_pvdstate_no_formtype'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		EncounterTypePriority,
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			EncounterTypePriority,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			EncounterTypePriority,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
		)X
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	EncounterTypePriority,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--encountertype_state_state_outlier_pvdstate_formtype_srvcgrp
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	EncounterTypePriority,
	ServiceGroup,
	Outlier_cat, 
	ClaimantState, 
	ProviderState, 
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt)
SELECT 18 ReportID,
		''encountertype_state_state_outlier_pvdstate_formtype_srvcgrp'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		FormType,
		CoverageType,
		EncounterTypePriority,
		ServiceGroup,
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			EncounterTypePriority,
			ServiceGroup,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			FormType,
			CoverageType,
			EncounterTypePriority,
			ServiceGroup,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero
		)X    
GROUP BY OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	FormType,
	CoverageType,
	EncounterTypePriority,
	ServiceGroup,
	Outlier_cat, 
	ClaimantState,
	ProviderState,
	IsAllowedGreaterThanZero
OPTION (HASH GROUP);
'+

--EncounterType_injury_state_outlier_pvdstate_no_formtype
'
INSERT INTO stg.LossYearReport_Client(
	ReportID,
	ReportName,
	OdsCustomerId, 
	SOJ, 
	DateQuarter, 
	CoverageType,
	EncounterTypePriority,
	Outlier_cat, 
	ClaimantState, 
	ProviderState,
	IsAllowedGreaterThanZero,
	Allowed, 
	Charged, 
	Units, 
	ClaimantCnt, 
	DOSCnt,
	InjuryNatureId)
SELECT 19 ReportID,
		''encountertype_injury_state_outlier_pvdstate_no_formtype'' ReportName,
		OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		EncounterTypePriority,
		Outlier_cat, 
		ClaimantState, 
		ProviderState, 
		IsAllowedGreaterThanZero,
		SUM(Allowed) Allowed, 
		SUM(Charged) Charged, 
		SUM(UNITS) Units, 
		COUNT(DISTINCT CmtIDNo) ClaimantCnt, 
		SUM(DT_SVC) DOSCnt,
		InjuryNatureId
FROM (
	SELECT I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			EncounterTypePriority,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			InjuryNatureId,
			SUM(Allowed) Allowed, 
			SUM(Charged) Charged, 
			SUM(UNITS) Units,
			COUNT(DISTINCT DT_SVC) DT_SVC
	FROM #LossYearReport_Filtered I
	GROUP BY 
			I.OdsCustomerId, 
			I.CmtIDNo,
			SOJ, 
			DateQuarter, 
			CoverageType,
			EncounterTypePriority,
			Outlier_cat, 
			ClaimantState,
			ProviderState,
			IsAllowedGreaterThanZero,
			InjuryNatureId
		) X 
GROUP BY OdsCustomerId, 
		SOJ, 
		DateQuarter, 
		CoverageType,
		EncounterTypePriority,
		Outlier_cat, 
		ClaimantState,
		ProviderState,
		IsAllowedGreaterThanZero,
		InjuryNatureId
OPTION (HASH GROUP);'

    
EXEC(@SQLScript);

ALTER INDEX ALL ON  stg.LossYearReport_Client REBUILD;
		
END


GO


