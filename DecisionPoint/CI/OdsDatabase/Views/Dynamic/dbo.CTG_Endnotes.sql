IF OBJECT_ID('dbo.CTG_Endnotes', 'V') IS NOT NULL
    DROP VIEW dbo.CTG_Endnotes;
GO

CREATE VIEW dbo.CTG_Endnotes
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Endnote
	,ShortDesc
	,LongDesc
FROM src.CTG_Endnotes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


