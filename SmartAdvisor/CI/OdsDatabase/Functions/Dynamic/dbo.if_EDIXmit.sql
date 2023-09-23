IF OBJECT_ID('dbo.if_EDIXmit', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_EDIXmit;
GO

CREATE FUNCTION dbo.if_EDIXmit(
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
	t.EDIXmitSeq,
	t.FileSpec,
	t.FileLocation,
	t.RecommendedPayment,
	t.UserID,
	t.XmitDate,
	t.DateFrom,
	t.DateTo,
	t.EDIType,
	t.EDIPartnerID,
	t.DBVersion,
	t.EDIMapToolSiteCode,
	t.EDIPortType,
	t.EDIMapToolID,
	t.TransmissionStatus,
	t.BatchNumber,
	t.SenderID,
	t.ReceiverID,
	t.ExternalBatchID,
	t.SARelatedBatchID,
	t.AckNoteCode,
	t.AckNote,
	t.ExternalBatchDate,
	t.UserNotes,
	t.ResubmitDate,
	t.ResubmitUserID,
	t.ModDate,
	t.ModUserID
FROM src.EDIXmit t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EDIXmitSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EDIXmit
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EDIXmitSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EDIXmitSeq = s.EDIXmitSeq
WHERE t.DmlOperation <> 'D';

GO


