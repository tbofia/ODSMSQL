IF OBJECT_ID('dbo.if_CTG_Endnotes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CTG_Endnotes;
GO

CREATE FUNCTION dbo.if_CTG_Endnotes(
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
	t.Endnote,
	t.ShortDesc,
	t.LongDesc
FROM src.CTG_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CTG_Endnotes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D';

GO


