IF OBJECT_ID('dbo.prf_CTGPenaltyHdr', 'V') IS NOT NULL
    DROP VIEW dbo.prf_CTGPenaltyHdr;
GO

CREATE VIEW dbo.prf_CTGPenaltyHdr
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CTGPenHdrID
	,ProfileId
	,PenaltyType
	,PayNegRate
	,PayPPORate
	,DatesBasedOn
	,ApplyPenaltyToPharmacy
	,ApplyPenaltyCondition
FROM src.prf_CTGPenaltyHdr
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


