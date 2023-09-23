IF OBJECT_ID('dbo.UB_RevenueCodes', 'V') IS NOT NULL
    DROP VIEW dbo.UB_RevenueCodes;
GO

CREATE VIEW dbo.UB_RevenueCodes
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RevenueCode
	,StartDate
	,EndDate
	,PRC_DESC
	,Flags
	,Vague
	,PerVisit
	,PerClaimant
	,PerProvider
	,BodyFlags
	,DrugFlag
	,CurativeFlag
	,RevenueCodeSubCategoryId
FROM src.UB_RevenueCodes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


