IF OBJECT_ID('dbo.lkp_SPC', 'V') IS NOT NULL
    DROP VIEW dbo.lkp_SPC;
GO

CREATE VIEW dbo.lkp_SPC
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,lkp_SpcId
	,LongName
	,ShortName
	,Mult
	,NCD92
	,NCD93
	,PlusFour
	,CbreSpecialtyCode
FROM src.lkp_SPC
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


