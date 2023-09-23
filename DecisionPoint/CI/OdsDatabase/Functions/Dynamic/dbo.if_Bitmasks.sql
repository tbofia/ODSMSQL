IF OBJECT_ID('dbo.if_Bitmasks', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bitmasks;
GO

CREATE FUNCTION dbo.if_Bitmasks(
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
	t.TableProgramUsed,
	t.AttributeUsed,
	t.Decimal,
	t.ConstantName,
	t.Bit,
	t.Hex,
	t.Description
FROM src.Bitmasks t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TableProgramUsed,
		AttributeUsed,
		Decimal,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bitmasks
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TableProgramUsed,
		AttributeUsed,
		Decimal) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TableProgramUsed = s.TableProgramUsed
	AND t.AttributeUsed = s.AttributeUsed
	AND t.Decimal = s.Decimal
WHERE t.DmlOperation <> 'D';

GO


