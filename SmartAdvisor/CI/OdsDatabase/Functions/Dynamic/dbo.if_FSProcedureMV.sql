IF OBJECT_ID('dbo.if_FSProcedureMV', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_FSProcedureMV;
GO

CREATE FUNCTION dbo.if_FSProcedureMV(
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
	t.EffectiveDate,
	t.TerminationDate,
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
	t.UnitValue,
	t.ProUnitValue,
	t.TechUnitValue,
	t.SiteCode
FROM src.FSProcedureMV t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Jurisdiction,
		Extension,
		ProcedureCode,
		EffectiveDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.FSProcedureMV
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Jurisdiction,
		Extension,
		ProcedureCode,
		EffectiveDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Jurisdiction = s.Jurisdiction
	AND t.Extension = s.Extension
	AND t.ProcedureCode = s.ProcedureCode
	AND t.EffectiveDate = s.EffectiveDate
WHERE t.DmlOperation <> 'D';

GO


