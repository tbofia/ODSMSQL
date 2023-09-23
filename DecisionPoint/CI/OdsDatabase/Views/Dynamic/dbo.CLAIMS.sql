IF OBJECT_ID('dbo.CLAIMS', 'V') IS NOT NULL
    DROP VIEW dbo.CLAIMS;
GO

CREATE VIEW dbo.CLAIMS
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimIDNo
	,ClaimNo
	,DateLoss
	,CV_Code
	,DiaryIndex
	,LastSaved
	,PolicyNumber
	,PolicyHoldersName
	,PaidDeductible
	,Status
	,InUse
	,CompanyID
	,OfficeIndex
	,AdjIdNo
	,PaidCoPay
	,AssignedUser
	,Privatized
	,PolicyEffDate
	,Deductible
	,LossState
	,AssignedGroup
	,CreateDate
	,LastChangedOn
	,AllowMultiCoverage
FROM src.CLAIMS
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


