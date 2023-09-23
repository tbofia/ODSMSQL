IF OBJECT_ID('dbo.Bitmasks', 'V') IS NOT NULL
    DROP VIEW dbo.Bitmasks;
GO

CREATE VIEW dbo.Bitmasks
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TableProgramUsed
	,AttributeUsed
	,Decimal
	,ConstantName
	,Bit
	,Hex
	,Description
FROM src.Bitmasks
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


