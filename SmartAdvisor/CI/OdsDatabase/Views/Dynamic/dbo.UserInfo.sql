IF OBJECT_ID('dbo.UserInfo', 'V') IS NOT NULL
    DROP VIEW dbo.UserInfo;
GO

CREATE VIEW dbo.UserInfo
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,UserID
	,UserPassword
	,Name
	,SecurityLevel
	,EnableAdjusterMenu
	,EnableProvAdds
	,AllowPosting
	,EnableClaimAdds
	,EnablePolicyAdds
	,EnableInvoiceCreditVoid
	,EnableReevaluations
	,EnablePPOAccess
	,EnableURCommentView
	,EnablePendRelease
	,EnableXtableUpdate
	,CreateUserID
	,CreateDate
	,ModUserID
	,ModDate
	,EnablePPOFastMatchAdds
	,ExternalID
	,EmailAddress
	,EmailNotify
	,ActiveStatus
	,CompanySeq
	,NetworkLogin
	,AutomaticNetworkLogin
	,LastLoggedInDate
	,PromptToCreateMCC
	,AccessAllWorkQueues
	,LandingZoneAccess
	,ReviewLevel
	,EnableUserMaintenance
	,EnableHistoryMaintenance
	,EnableClientMaintenance
	,FeeAccess
	,EnableSalesTaxMaintenance
	,BESalesTaxZipCodeAccess
	,InvoiceGenAccess
	,BEPermitAllowOver
	,PermitRereviews
	,EditBillControl
	,RestrictEORNotes
	,UWQAutoNextBill
	,UWQDisableOptions
	,UWQDisableRules
	,PermitCheckReissue
	,EnableEDIAutomationMaintenance
	,RestrictDiaryNotes
	,RestrictExternalDiaryNotes
	,BEDeferManualModeMsg
	,UserRoleID
	,EraseBillTempHistory
	,EditPPOProfile
	,EnableUrAccess
	,CapstoneConfigurationAccess
	,PermitUDFDefinition
	,EnablePPOProfileEdit
	,EnableSupervisorRole
FROM src.UserInfo
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


