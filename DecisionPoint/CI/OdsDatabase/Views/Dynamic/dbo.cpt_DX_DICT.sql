IF OBJECT_ID('dbo.cpt_DX_DICT', 'V') IS NOT NULL
    DROP VIEW dbo.cpt_DX_DICT;
GO

CREATE VIEW dbo.cpt_DX_DICT
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ICD9
	,StartDate
	,EndDate
	,Flags
	,NonSpecific
	,AdditionalDigits
	,Traumatic
	,DX_DESC
	,Duration
	,Colossus
	,DiagnosisFamilyId
FROM src.cpt_DX_DICT
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


