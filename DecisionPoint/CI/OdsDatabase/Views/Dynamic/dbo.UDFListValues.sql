IF OBJECT_ID('dbo.UDFListValues', 'V') IS NOT NULL
    DROP VIEW dbo.UDFListValues;
GO

CREATE VIEW dbo.UDFListValues
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ListValueIdNo
	,UDFIdNo
	,SeqNo
	,ListValue
	,DefaultValue
FROM src.UDFListValues
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


