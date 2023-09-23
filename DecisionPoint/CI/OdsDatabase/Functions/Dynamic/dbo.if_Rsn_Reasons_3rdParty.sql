IF OBJECT_ID('dbo.if_Rsn_Reasons_3rdParty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Rsn_Reasons_3rdParty;
GO

CREATE FUNCTION dbo.if_Rsn_Reasons_3rdParty(
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
	t.ReasonNumber,
	t.ShortDesc,
	t.LongDesc
FROM src.Rsn_Reasons_3rdParty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Rsn_Reasons_3rdParty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


