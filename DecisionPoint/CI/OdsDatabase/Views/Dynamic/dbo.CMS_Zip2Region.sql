IF OBJECT_ID('dbo.CMS_Zip2Region', 'V') IS NOT NULL
    DROP VIEW dbo.CMS_Zip2Region;
GO

CREATE VIEW dbo.CMS_Zip2Region
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StartDate
	,EndDate
	,ZIP_Code
	,State
	,Region
	,AmbRegion
	,RuralFlag
	,ASCRegion
	,PlusFour
	,CarrierId
FROM src.CMS_Zip2Region
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


