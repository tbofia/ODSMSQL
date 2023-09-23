IF OBJECT_ID('dbo.EDIXmit', 'V') IS NOT NULL
    DROP VIEW dbo.EDIXmit;
GO

CREATE VIEW dbo.EDIXmit
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EDIXmitSeq
	,FileSpec
	,FileLocation
	,RecommendedPayment
	,UserID
	,XmitDate
	,DateFrom
	,DateTo
	,EDIType
	,EDIPartnerID
	,DBVersion
	,EDIMapToolSiteCode
	,EDIPortType
	,EDIMapToolID
	,TransmissionStatus
	,BatchNumber
	,SenderID
	,ReceiverID
	,ExternalBatchID
	,SARelatedBatchID
	,AckNoteCode
	,AckNote
	,ExternalBatchDate
	,UserNotes
	,ResubmitDate
	,ResubmitUserID
	,ModDate
	,ModUserID
FROM src.EDIXmit
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


