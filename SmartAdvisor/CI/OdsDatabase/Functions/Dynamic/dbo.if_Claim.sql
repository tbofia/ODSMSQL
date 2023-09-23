IF OBJECT_ID('dbo.if_Claim', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Claim;
GO

CREATE FUNCTION dbo.if_Claim(
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
	t.ClaimSysSubSet,
	t.ClaimSeq,
	t.ClaimID,
	t.DOI,
	t.PatientSSN,
	t.PatientFirstName,
	t.PatientLastName,
	t.PatientMInitial,
	t.ExternalClaimID,
	t.PolicyCoPayAmount,
	t.PolicyCoPayPct,
	t.PolicyDeductible,
	t.Status,
	t.PolicyLimit,
	t.PolicyID,
	t.PolicyTimeLimit,
	t.Adjuster,
	t.PolicyLimitWarningPct,
	t.FirstDOS,
	t.LastDOS,
	t.LoadDate,
	t.ModDate,
	t.ModUserID,
	t.PatientSex,
	t.PatientCity,
	t.PatientDOB,
	t.PatientStreet2,
	t.PatientState,
	t.PatientZip,
	t.PatientStreet1,
	t.MMIDate,
	t.BodyPart1,
	t.BodyPart2,
	t.BodyPart3,
	t.BodyPart4,
	t.BodyPart5,
	t.Location,
	t.NatureInj,
	t.URFlag,
	t.CarKnowDate,
	t.ClaimType,
	t.CtrlDay,
	t.MCOChoice,
	t.ClientCodeDefault,
	t.CloseDate,
	t.ReopenDate,
	t.MedCloseDate,
	t.MedStipDate,
	t.LegalStatus1,
	t.LegalStatus2,
	t.LegalStatus3,
	t.Jurisdiction,
	t.ProductCode,
	t.PlaintiffAttorneySeq,
	t.DefendantAttorneySeq,
	t.BranchID,
	t.OccCode,
	t.ClaimSeverity,
	t.DateLostBegan,
	t.AccidentEmployment,
	t.RelationToInsured,
	t.Policy5Days,
	t.Policy90Days,
	t.Job5Days,
	t.Job90Days,
	t.LostDays,
	t.ActualRTWDate,
	t.MCOTransInd,
	t.QualifiedInjWorkInd,
	t.PermStationaryInd,
	t.HospitalAdmit,
	t.QualifiedInjWorkDate,
	t.RetToWorkDate,
	t.PermStationaryDate,
	t.MCOFein,
	t.CreateUserID,
	t.IDCode,
	t.IDType,
	t.MPNOptOutEffectiveDate,
	t.MPNOptOutTerminationDate,
	t.MPNOptOutPhysicianName,
	t.MPNOptOutPhysicianTIN,
	t.MPNChoice,
	t.JurisdictionClaimID,
	t.PolicyLimitResult,
	t.PatientPrimaryPhone,
	t.PatientWorkPhone,
	t.PatientAlternatePhone,
	t.ICDVersion,
	t.LastDateofTrauma,
	t.ClaimAdminClaimNum,
	t.PatientCountryCode
FROM src.Claim t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		ClaimSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Claim
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		ClaimSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.ClaimSeq = s.ClaimSeq
WHERE t.DmlOperation <> 'D';

GO


