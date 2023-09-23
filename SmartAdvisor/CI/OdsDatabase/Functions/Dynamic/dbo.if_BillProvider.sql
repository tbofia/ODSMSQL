IF OBJECT_ID('dbo.if_BillProvider', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillProvider;
GO

CREATE FUNCTION dbo.if_BillProvider(
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
	t.ClientCode,
	t.BillSeq,
	t.BillProviderSeq,
	t.Qualifier,
	t.LastName,
	t.FirstName,
	t.MiddleName,
	t.Suffix,
	t.NPI,
	t.LicenseNum,
	t.DEANum
FROM src.BillProvider t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		BillSeq,
		BillProviderSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillProvider
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		BillSeq,
		BillProviderSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.BillSeq = s.BillSeq
	AND t.BillProviderSeq = s.BillProviderSeq
WHERE t.DmlOperation <> 'D';

GO


