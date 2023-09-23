IF OBJECT_ID('dbo.if_UserInfo', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UserInfo;
GO

CREATE FUNCTION dbo.if_UserInfo(
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
	t.UserID,
	t.UserPassword,
	t.Name,
	t.SecurityLevel,
	t.EnableAdjusterMenu,
	t.EnableProvAdds,
	t.AllowPosting,
	t.EnableClaimAdds,
	t.EnablePolicyAdds,
	t.EnableInvoiceCreditVoid,
	t.EnableReevaluations,
	t.EnablePPOAccess,
	t.EnableURCommentView,
	t.EnablePendRelease,
	t.EnableXtableUpdate,
	t.CreateUserID,
	t.CreateDate,
	t.ModUserID,
	t.ModDate,
	t.EnablePPOFastMatchAdds,
	t.ExternalID,
	t.EmailAddress,
	t.EmailNotify,
	t.ActiveStatus,
	t.CompanySeq,
	t.NetworkLogin,
	t.AutomaticNetworkLogin,
	t.LastLoggedInDate,
	t.PromptToCreateMCC,
	t.AccessAllWorkQueues,
	t.LandingZoneAccess,
	t.ReviewLevel,
	t.EnableUserMaintenance,
	t.EnableHistoryMaintenance,
	t.EnableClientMaintenance,
	t.FeeAccess,
	t.EnableSalesTaxMaintenance,
	t.BESalesTaxZipCodeAccess,
	t.InvoiceGenAccess,
	t.BEPermitAllowOver,
	t.PermitRereviews,
	t.EditBillControl,
	t.RestrictEORNotes,
	t.UWQAutoNextBill,
	t.UWQDisableOptions,
	t.UWQDisableRules,
	t.PermitCheckReissue,
	t.EnableEDIAutomationMaintenance,
	t.RestrictDiaryNotes,
	t.RestrictExternalDiaryNotes,
	t.BEDeferManualModeMsg,
	t.UserRoleID,
	t.EraseBillTempHistory,
	t.EditPPOProfile,
	t.EnableUrAccess,
	t.CapstoneConfigurationAccess,
	t.PermitUDFDefinition,
	t.EnablePPOProfileEdit,
	t.EnableSupervisorRole
FROM src.UserInfo t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UserID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UserInfo
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UserID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UserID = s.UserID
WHERE t.DmlOperation <> 'D';

GO


