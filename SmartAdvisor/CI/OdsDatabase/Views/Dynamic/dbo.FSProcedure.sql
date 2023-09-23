IF OBJECT_ID('dbo.FSProcedure', 'V') IS NOT NULL
    DROP VIEW dbo.FSProcedure;
GO

CREATE VIEW dbo.FSProcedure
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
	,UnitValue1
	,UnitValue2
	,UnitValue3
	,UnitValue4
	,UnitValue5
	,UnitValue6
	,UnitValue7
	,UnitValue8
	,UnitValue9
	,UnitValue10
	,UnitValue11
	,UnitValue12
	,ProUnitValue1
	,ProUnitValue2
	,ProUnitValue3
	,ProUnitValue4
	,ProUnitValue5
	,ProUnitValue6
	,ProUnitValue7
	,ProUnitValue8
	,ProUnitValue9
	,ProUnitValue10
	,ProUnitValue11
	,ProUnitValue12
	,TechUnitValue1
	,TechUnitValue2
	,TechUnitValue3
	,TechUnitValue4
	,TechUnitValue5
	,TechUnitValue6
	,TechUnitValue7
	,TechUnitValue8
	,TechUnitValue9
	,TechUnitValue10
	,TechUnitValue11
	,TechUnitValue12
	,SiteCode
FROM src.FSProcedure
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


