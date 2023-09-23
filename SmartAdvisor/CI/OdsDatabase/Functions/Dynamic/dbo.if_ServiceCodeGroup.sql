IF OBJECT_ID('dbo.if_ServiceCodeGroup', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ServiceCodeGroup;
GO

CREATE FUNCTION dbo.if_ServiceCodeGroup(
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
	t.SiteCode,
	t.GroupType,
	t.Family,
	t.Revision,
	t.GroupCode,
	t.CodeOrder,
	t.ServiceCode,
	t.ServiceCodeType,
	t.LinkGroupType,
	t.LinkGroupFamily,
	t.CodeLevel,
	t.GlobalPriority,
	t.Active,
	t.Comment,
	t.CustomParameters,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.ServiceCodeGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SiteCode,
		GroupType,
		Family,
		Revision,
		GroupCode,
		CodeOrder,
		ServiceCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ServiceCodeGroup
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SiteCode,
		GroupType,
		Family,
		Revision,
		GroupCode,
		CodeOrder,
		ServiceCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SiteCode = s.SiteCode
	AND t.GroupType = s.GroupType
	AND t.Family = s.Family
	AND t.Revision = s.Revision
	AND t.GroupCode = s.GroupCode
	AND t.CodeOrder = s.CodeOrder
	AND t.ServiceCode = s.ServiceCode
WHERE t.DmlOperation <> 'D';

GO


