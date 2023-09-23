IF OBJECT_ID('dbo.if_UDFLibrary', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFLibrary;
GO

CREATE FUNCTION dbo.if_UDFLibrary(
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
	t.UDFIdNo,
	t.UDFName,
	t.ScreenType,
	t.UDFDescription,
	t.DataFormat,
	t.RequiredField,
	t.ReadOnly,
	t.Invisible,
	t.TextMaxLength,
	t.TextMask,
	t.TextEnforceLength,
	t.RestrictRange,
	t.MinValDecimal,
	t.MaxValDecimal,
	t.MinValDate,
	t.MaxValDate,
	t.ListAllowMultiple,
	t.DefaultValueText,
	t.DefaultValueDecimal,
	t.DefaultValueDate,
	t.UseDefault,
	t.ReqOnSubmit,
	t.IncludeDateButton
FROM src.UDFLibrary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFLibrary
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


