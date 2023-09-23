IF OBJECT_ID('dbo.UdfDataFormat', 'V') IS NOT NULL
    DROP VIEW dbo.UdfDataFormat;
GO

CREATE VIEW dbo.UdfDataFormat
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,UdfDataFormatId
	,DataFormatName
FROM src.UdfDataFormat
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


