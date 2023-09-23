IF OBJECT_ID('dbo.if_EDIMapTool', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_EDIMapTool;
GO

CREATE FUNCTION dbo.if_EDIMapTool(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.SiteCode,
	t.EDIPortType,
	t.EDIMapToolID,
	t.EDISourceID,
	t.EDIMapToolName,
	t.EDIMapToolType,
	t.EDIMapToolDesc,
	t.EDIObjectID,
	t.MenuTitle,
	t.SecurityLevel,
	t.EDIInputFileName,
	t.EDIOutputFileName,
	t.EDIMultiFiles,
	t.EDIReportType,
	t.FormProperties,
	t.Jurisdiction,
	t.EDIType,
	t.EDIPartnerID,
	t.BillControlTableCode,
	t.EDIControlFlag,
	t.BillControlSeq,
	t.EDIObjectSiteCode,
	t.PermitUndefinedRecIDs,
	t.SelectionQuery,
	t.ReportSelectionQuery,
	t.Class,
	t.LineSelectionQuery,
	t.PortProperties,
	t.EDIFileConfigSiteCode,
	t.EDIFileConfigSeq,
	t.LZControlTableCode,
	t.LZControlSeq
FROM src.EDIMapTool t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SiteCode,
		EDIPortType,
		EDIMapToolID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EDIMapTool
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SiteCode,
		EDIPortType,
		EDIMapToolID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SiteCode = s.SiteCode
	AND t.EDIPortType = s.EDIPortType
	AND t.EDIMapToolID = s.EDIMapToolID
WHERE t.DmlOperation <> 'D';

GO


