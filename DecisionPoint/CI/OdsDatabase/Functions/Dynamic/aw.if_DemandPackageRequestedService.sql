IF OBJECT_ID('aw.if_DemandPackageRequestedService', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_DemandPackageRequestedService;
GO

CREATE FUNCTION aw.if_DemandPackageRequestedService(
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
	t.DemandPackageRequestedServiceId,
	t.DemandPackageId,
	t.ReviewRequestOptions
FROM src.DemandPackageRequestedService t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandPackageRequestedServiceId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandPackageRequestedService
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandPackageRequestedServiceId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandPackageRequestedServiceId = s.DemandPackageRequestedServiceId
WHERE t.DmlOperation <> 'D';

GO


