IF OBJECT_ID('dbo.FSProcedureMV', 'V') IS NOT NULL
    DROP VIEW dbo.FSProcedureMV;
GO

CREATE VIEW dbo.FSProcedureMV
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
	,Extension
	,ProcedureCode
	,EffectiveDate
	,TerminationDate
	,FSProcDescription
	,Sv
	,Star
	,Panel
	,Ip
	,Mult
	,AsstSurgeon
	,SectionFlag
	,Fup
	,Bav
	,ProcGroup
	,ViewType
	,UnitValue
	,ProUnitValue
	,TechUnitValue
	,SiteCode
FROM src.FSProcedureMV
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


