IF OBJECT_ID('dbo.if_Drugs', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Drugs;
GO

CREATE FUNCTION dbo.if_Drugs(
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
	t.DrugCode,
	t.DrugsDescription,
	t.Disp,
	t.DrugType,
	t.Cat,
	t.UpdateFlag,
	t.Uv,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.Drugs t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DrugCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Drugs
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DrugCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DrugCode = s.DrugCode
WHERE t.DmlOperation <> 'D';

GO


