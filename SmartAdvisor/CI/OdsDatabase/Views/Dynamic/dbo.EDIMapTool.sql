IF OBJECT_ID('dbo.EDIMapTool', 'V') IS NOT NULL
    DROP VIEW dbo.EDIMapTool;
GO

CREATE VIEW dbo.EDIMapTool
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SiteCode
	,EDIPortType
	,EDIMapToolID
	,EDISourceID
	,EDIMapToolName
	,EDIMapToolType
	,EDIMapToolDesc
	,EDIObjectID
	,MenuTitle
	,SecurityLevel
	,EDIInputFileName
	,EDIOutputFileName
	,EDIMultiFiles
	,EDIReportType
	,FormProperties
	,Jurisdiction
	,EDIType
	,EDIPartnerID
	,BillControlTableCode
	,EDIControlFlag
	,BillControlSeq
	,EDIObjectSiteCode
	,PermitUndefinedRecIDs
	,SelectionQuery
	,ReportSelectionQuery
	,Class
	,LineSelectionQuery
	,PortProperties
	,EDIFileConfigSiteCode
	,EDIFileConfigSeq
	,LZControlTableCode
	,LZControlSeq
FROM src.EDIMapTool
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


