IF OBJECT_ID('dbo.cpt_PRC_DICT', 'V') IS NOT NULL
    DROP VIEW dbo.cpt_PRC_DICT;
GO

CREATE VIEW dbo.cpt_PRC_DICT
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PRC_CD
	,StartDate
	,EndDate
	,PRC_DESC
	,Flags
	,Vague
	,PerVisit
	,PerClaimant
	,PerProvider
	,BodyFlags
	,Colossus
	,CMS_Status
	,DrugFlag
	,CurativeFlag
	,ExclPolicyLimit
	,SpecNetFlag
FROM src.cpt_PRC_DICT
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


