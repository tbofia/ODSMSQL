IF OBJECT_ID('dbo.if_CMT_HDR', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CMT_HDR;
GO

CREATE FUNCTION dbo.if_CMT_HDR(
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
	t.CMT_HDR_IDNo,
	t.CmtIDNo,
	t.PvdIDNo,
	t.LastChangedOn
FROM src.CMT_HDR t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CMT_HDR_IDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMT_HDR
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CMT_HDR_IDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CMT_HDR_IDNo = s.CMT_HDR_IDNo
WHERE t.DmlOperation <> 'D';

GO


