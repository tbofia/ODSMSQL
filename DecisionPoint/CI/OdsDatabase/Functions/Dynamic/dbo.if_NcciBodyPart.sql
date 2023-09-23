IF OBJECT_ID('dbo.if_NcciBodyPart', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_NcciBodyPart;
GO

CREATE FUNCTION dbo.if_NcciBodyPart(
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
	t.NcciBodyPartId,
	t.Description,
	t.NarrativeInformation
FROM src.NcciBodyPart t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NcciBodyPartId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.NcciBodyPart
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NcciBodyPartId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NcciBodyPartId = s.NcciBodyPartId
WHERE t.DmlOperation <> 'D';

GO


