IF OBJECT_ID('dbo.if_Insurer', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Insurer;
GO

CREATE FUNCTION dbo.if_Insurer(
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
	t.InsurerType,
	t.InsurerSeq,
	t.Jurisdiction,
	t.StateID,
	t.TIN,
	t.AltID,
	t.Name,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.Zip,
	t.PhoneNum,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.FaxNum,
	t.NAICCoCode,
	t.NAICGpCode,
	t.NCCICarrierCode,
	t.NCCIGroupCode
FROM src.Insurer t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		InsurerType,
		InsurerSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Insurer
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		InsurerType,
		InsurerSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.InsurerType = s.InsurerType
	AND t.InsurerSeq = s.InsurerSeq
WHERE t.DmlOperation <> 'D';

GO


