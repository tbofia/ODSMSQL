IF OBJECT_ID('dbo.PPORateType', 'V') IS NOT NULL
    DROP VIEW dbo.PPORateType;
GO

CREATE VIEW dbo.PPORateType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RateTypeCode
	,PPONetworkID
	,Category
	,Priority
	,VBColor
	,RateTypeDescription
	,Explanation
FROM src.PPORateType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


