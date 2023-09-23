IF OBJECT_ID('aw.if_DemandPackage', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_DemandPackage;
GO

CREATE FUNCTION aw.if_DemandPackage(
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
	t.DemandPackageId,
	t.DemandClaimantId,
	t.RequestedByUserName,
	t.DateTimeReceived,
	t.CorrelationId,
	t.PageCount
FROM src.DemandPackage t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandPackageId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandPackage
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandPackageId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandPackageId = s.DemandPackageId
WHERE t.DmlOperation <> 'D';

GO


