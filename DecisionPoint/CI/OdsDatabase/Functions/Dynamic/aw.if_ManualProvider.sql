IF OBJECT_ID('aw.if_ManualProvider', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_ManualProvider;
GO

CREATE FUNCTION aw.if_ManualProvider(
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
	t.ManualProviderId,
	t.TIN,
	t.LastName,
	t.FirstName,
	t.GroupName,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.Zip
FROM src.ManualProvider t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ManualProviderId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ManualProvider
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ManualProviderId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ManualProviderId = s.ManualProviderId
WHERE t.DmlOperation <> 'D';

GO


