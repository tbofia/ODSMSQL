IF OBJECT_ID('dbo.if_ReductionType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ReductionType;
GO

CREATE FUNCTION dbo.if_ReductionType(
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
	t.ReductionCode,
	t.ReductionDescription,
	t.BEOverride,
	t.BEMsg,
	t.Abbreviation,
	t.DefaultMessageCode,
	t.DefaultDenialMessageCode
FROM src.ReductionType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReductionCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ReductionType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReductionCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReductionCode = s.ReductionCode
WHERE t.DmlOperation <> 'D';

GO


