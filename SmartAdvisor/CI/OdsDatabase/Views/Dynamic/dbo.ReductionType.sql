IF OBJECT_ID('dbo.ReductionType', 'V') IS NOT NULL
    DROP VIEW dbo.ReductionType;
GO

CREATE VIEW dbo.ReductionType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReductionCode
	,ReductionDescription
	,BEOverride
	,BEMsg
	,Abbreviation
	,DefaultMessageCode
	,DefaultDenialMessageCode
FROM src.ReductionType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


