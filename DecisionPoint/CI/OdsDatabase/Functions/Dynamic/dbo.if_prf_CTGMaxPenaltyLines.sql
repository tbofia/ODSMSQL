IF OBJECT_ID('dbo.if_prf_CTGMaxPenaltyLines', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_CTGMaxPenaltyLines;
GO

CREATE FUNCTION dbo.if_prf_CTGMaxPenaltyLines(
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
	t.CTGMaxPenLineID,
	t.ProfileId,
	t.DatesBasedOn,
	t.MaxPenaltyPercent,
	t.StartDate,
	t.EndDate
FROM src.prf_CTGMaxPenaltyLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGMaxPenLineID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGMaxPenaltyLines
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGMaxPenLineID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGMaxPenLineID = s.CTGMaxPenLineID
WHERE t.DmlOperation <> 'D';

GO


