IF OBJECT_ID('dbo.if_StateSettingsNY', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsNY;
GO

CREATE FUNCTION dbo.if_StateSettingsNY(
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
	t.StateSettingsNYID,
	t.NF10PrintDate,
	t.NF10CheckBox1,
	t.NF10CheckBox18,
	t.NF10UseUnderwritingCompany,
	t.UnderwritingCompanyUdfId,
	t.NaicUdfId,
	t.DisplayNYPrintOptionsWhenZosOrSojIsNY,
	t.NF10DuplicatePrint
FROM src.StateSettingsNY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsNYID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNY
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsNYID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsNYID = s.StateSettingsNYID
WHERE t.DmlOperation <> 'D';

GO


