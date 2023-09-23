IF OBJECT_ID('dbo.MedicareICQM', 'V') IS NOT NULL
    DROP VIEW dbo.MedicareICQM;
GO

CREATE VIEW dbo.MedicareICQM
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Jurisdiction
	,MdicqmSeq
	,ProviderNum
	,ProvSuffix
	,ServiceCode
	,HCPCS
	,Revenue
	,MedicareICQMDescription
	,IP1995
	,OP1995
	,IP1996
	,OP1996
	,IP1997
	,OP1997
	,IP1998
	,OP1998
	,NPI
FROM src.MedicareICQM
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


