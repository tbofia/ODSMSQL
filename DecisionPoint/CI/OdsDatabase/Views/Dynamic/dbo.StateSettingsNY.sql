IF OBJECT_ID('dbo.StateSettingsNY', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsNY;
GO

CREATE VIEW dbo.StateSettingsNY
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingsNYID
	,NF10PrintDate
	,NF10CheckBox1
	,NF10CheckBox18
	,NF10UseUnderwritingCompany
	,UnderwritingCompanyUdfId
	,NaicUdfId
	,DisplayNYPrintOptionsWhenZosOrSojIsNY
	,NF10DuplicatePrint
FROM src.StateSettingsNY
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


