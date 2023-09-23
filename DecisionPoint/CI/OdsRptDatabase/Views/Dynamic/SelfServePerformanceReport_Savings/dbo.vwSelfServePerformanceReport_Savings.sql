IF OBJECT_ID ('dbo.vwSelfServePerformanceReport_Savings', 'V') IS NOT NULL
DROP VIEW dbo.vwSelfServePerformanceReport_Savings;
GO

CREATE VIEW dbo.vwSelfServePerformanceReport_Savings
AS 

SELECT    
		OdsCustomerId,
		CustomerName,
		Company,
		Office, 
		SOJ,
		ClaimCoverageType,
		BillCoverageType,
		FormType, 
		ClaimID, 
		ClaimantID, 
		ProviderTIN,
		BillID,
		BillCreateDate,
		BillCommitDate, 
		MitchellCompleteDate, 
		ClaimCreateDate, 
		ClaimDateofLoss,
		ExpectedRecoveryDate, 
		BillLine, 
		ProcedureCode,
		ProcedureCodeDescription,
		ProcedureCodeMajorGroup,
		BodyPart, 
		ReductionType,
		AdjSubCatName,
		DuplicateBillFlag, 
		DuplicateLineFlag,
		Adjustment,
		ProviderCharges, 
		TotalAllowed,
		TotalUnits,
		ExpectedRecoveryDuration

FROM  dbo.SelfServePerformanceReport_Savings
GO


