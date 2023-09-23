IF OBJECT_ID('dbo.if_TableLookUp', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_TableLookUp;
GO

CREATE FUNCTION dbo.if_TableLookUp(
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
	t.TableCode,
	t.TypeCode,
	t.Code,
	t.SiteCode,
	t.OldCode,
	t.ShortDesc,
	t.Source,
	t.Priority,
	t.LongDesc,
	t.OwnerApp,
	t.RecordStatus,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.TableLookUp t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TableCode,
		TypeCode,
		Code,
		SiteCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.TableLookUp
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TableCode,
		TypeCode,
		Code,
		SiteCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TableCode = s.TableCode
	AND t.TypeCode = s.TypeCode
	AND t.Code = s.Code
	AND t.SiteCode = s.SiteCode
WHERE t.DmlOperation <> 'D';

GO


