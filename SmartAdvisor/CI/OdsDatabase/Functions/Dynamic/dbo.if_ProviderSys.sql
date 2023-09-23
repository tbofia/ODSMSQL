IF OBJECT_ID('dbo.if_ProviderSys', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderSys;
GO

CREATE FUNCTION dbo.if_ProviderSys(
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
	t.ProviderSubset,
	t.ProviderSubSetDesc,
	t.ProviderAccess,
	t.TaxAddrRequired,
	t.AllowDummyProviders,
	t.CascadeUpdatesOnImport,
	t.RootExtIDOverrideDelimiter
FROM src.ProviderSys t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderSubset,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderSys
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderSubset) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderSubset = s.ProviderSubset
WHERE t.DmlOperation <> 'D';

GO


