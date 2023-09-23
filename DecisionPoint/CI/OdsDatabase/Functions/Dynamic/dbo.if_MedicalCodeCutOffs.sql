IF OBJECT_ID('dbo.if_MedicalCodeCutOffs', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicalCodeCutOffs;
GO

CREATE FUNCTION dbo.if_MedicalCodeCutOffs(
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
	t.CodeTypeID,
	t.CodeType,
	t.Code,
	t.FormType,
	t.MaxChargedPerUnit,
	t.MaxUnitsPerEncounter
FROM src.MedicalCodeCutOffs t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CodeTypeID,
		Code,
		FormType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicalCodeCutOffs
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CodeTypeID,
		Code,
		FormType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CodeTypeID = s.CodeTypeID
	AND t.Code = s.Code
	AND t.FormType = s.FormType
WHERE t.DmlOperation <> 'D';

GO


