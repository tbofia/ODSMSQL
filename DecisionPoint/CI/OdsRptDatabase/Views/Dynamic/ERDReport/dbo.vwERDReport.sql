IF OBJECT_ID ('dbo.vwERDReport', 'V') IS NOT NULL
DROP VIEW dbo.vwERDReport
GO

CREATE VIEW dbo.vwERDReport
AS
SELECT ReportName
	,CustomerName
	,ClaimIDNo
	,ClaimNo
	,ClaimantIDNo
	,CoverageType
	,CoverageTypeDesc
	,SOJ
	,County
	,AdjustorFirstName
	,AdjustorLastName
	,ClaimDateLoss
	,LastDateOfService
	,InjuryNatureId
	,InjuryNatureDesc
	,ERDDuration_Weeks
	,ERDDuration_Days
	,Company
	,Office
	,AllowedTreatmentDuration_Days
	,AllowedTreatmentDuration_Weeks
	,Charged
	,Allowed
	,ChargedAfterERD
	,AllowedAfterERD
	,RunDate
FROM dbo.ERDReport
WHERE ERDDuration_Weeks > 0


GO



