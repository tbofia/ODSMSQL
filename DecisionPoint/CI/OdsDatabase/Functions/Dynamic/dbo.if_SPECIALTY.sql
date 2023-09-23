IF OBJECT_ID('dbo.if_SPECIALTY', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SPECIALTY;
GO

CREATE FUNCTION dbo.if_SPECIALTY(
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
	t.SpcIdNo,
	t.Code,
	t.Description,
	t.PayeeSubTypeID,
	t.TieredTypeID
FROM src.SPECIALTY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Code,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SPECIALTY
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Code) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Code = s.Code
WHERE t.DmlOperation <> 'D';

GO


