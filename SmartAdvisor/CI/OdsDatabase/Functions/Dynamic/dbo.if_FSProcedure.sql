IF OBJECT_ID('dbo.if_FSProcedure', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_FSProcedure;
GO

CREATE FUNCTION dbo.if_FSProcedure(
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
	t.Jurisdiction,
	t.Extension,
	t.ProcedureCode,
	t.FSProcDescription,
	t.Sv,
	t.Star,
	t.Panel,
	t.Ip,
	t.Mult,
	t.AsstSurgeon,
	t.SectionFlag,
	t.Fup,
	t.Bav,
	t.ProcGroup,
	t.ViewType,
	t.UnitValue1,
	t.UnitValue2,
	t.UnitValue3,
	t.UnitValue4,
	t.UnitValue5,
	t.UnitValue6,
	t.UnitValue7,
	t.UnitValue8,
	t.UnitValue9,
	t.UnitValue10,
	t.UnitValue11,
	t.UnitValue12,
	t.ProUnitValue1,
	t.ProUnitValue2,
	t.ProUnitValue3,
	t.ProUnitValue4,
	t.ProUnitValue5,
	t.ProUnitValue6,
	t.ProUnitValue7,
	t.ProUnitValue8,
	t.ProUnitValue9,
	t.ProUnitValue10,
	t.ProUnitValue11,
	t.ProUnitValue12,
	t.TechUnitValue1,
	t.TechUnitValue2,
	t.TechUnitValue3,
	t.TechUnitValue4,
	t.TechUnitValue5,
	t.TechUnitValue6,
	t.TechUnitValue7,
	t.TechUnitValue8,
	t.TechUnitValue9,
	t.TechUnitValue10,
	t.TechUnitValue11,
	t.TechUnitValue12,
	t.SiteCode
FROM src.FSProcedure t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Jurisdiction,
		Extension,
		ProcedureCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.FSProcedure
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Jurisdiction,
		Extension,
		ProcedureCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Jurisdiction = s.Jurisdiction
	AND t.Extension = s.Extension
	AND t.ProcedureCode = s.ProcedureCode
WHERE t.DmlOperation <> 'D';

GO


