IF OBJECT_ID('dbo.CriticalAccessHospitalInpatientRevenueCode', 'V') IS NOT NULL
    DROP VIEW dbo.CriticalAccessHospitalInpatientRevenueCode;
GO

CREATE VIEW dbo.CriticalAccessHospitalInpatientRevenueCode
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
FROM src.CriticalAccessHospitalInpatientRevenueCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


