IF OBJECT_ID('dbo.if_Adjustor', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjustor;
GO

CREATE FUNCTION dbo.if_Adjustor(
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
	t.lAdjIdNo,
	t.IDNumber,
	t.Lastname,
	t.FirstName,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.ZipCode,
	t.Phone,
	t.Fax,
	t.Office,
	t.EMail,
	t.InUse,
	t.OfficeIdNo,
	t.UserId,
	t.CreateDate,
	t.LastChangedOn
FROM src.Adjustor t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		lAdjIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustor
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		lAdjIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.lAdjIdNo = s.lAdjIdNo
WHERE t.DmlOperation <> 'D';

GO


