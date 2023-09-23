IF OBJECT_ID('dbo.if_MedicareICQM', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicareICQM;
GO

CREATE FUNCTION dbo.if_MedicareICQM(
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
	t.Jurisdiction,
	t.MdicqmSeq,
	t.ProviderNum,
	t.ProvSuffix,
	t.ServiceCode,
	t.HCPCS,
	t.Revenue,
	t.MedicareICQMDescription,
	t.IP1995,
	t.OP1995,
	t.IP1996,
	t.OP1996,
	t.IP1997,
	t.OP1997,
	t.IP1998,
	t.OP1998,
	t.NPI
FROM src.MedicareICQM t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Jurisdiction,
		MdicqmSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareICQM
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Jurisdiction,
		MdicqmSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Jurisdiction = s.Jurisdiction
	AND t.MdicqmSeq = s.MdicqmSeq
WHERE t.DmlOperation <> 'D';

GO


