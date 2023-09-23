IF OBJECT_ID('dbo.if_PROVIDER', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PROVIDER;
GO

CREATE FUNCTION dbo.if_PROVIDER(
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
	t.PvdIDNo,
	t.PvdMID,
	t.PvdSource,
	t.PvdTIN,
	t.PvdLicNo,
	t.PvdCertNo,
	t.PvdLastName,
	t.PvdFirstName,
	t.PvdMI,
	t.PvdTitle,
	t.PvdGroup,
	t.PvdAddr1,
	t.PvdAddr2,
	t.PvdCity,
	t.PvdState,
	t.PvdZip,
	t.PvdZipPerf,
	t.PvdPhone,
	t.PvdFAX,
	t.PvdSPC_List,
	t.PvdAuthNo,
	t.PvdSPC_ACD,
	t.PvdUpdateCounter,
	t.PvdPPO_Provider,
	t.PvdFlags,
	t.PvdERRate,
	t.PvdSubNet,
	t.InUse,
	t.PvdStatus,
	t.PvdElectroStartDate,
	t.PvdElectroEndDate,
	t.PvdAccredStartDate,
	t.PvdAccredEndDate,
	t.PvdRehabStartDate,
	t.PvdRehabEndDate,
	t.PvdTraumaStartDate,
	t.PvdTraumaEndDate,
	t.OPCERT,
	t.PvdDentalStartDate,
	t.PvdDentalEndDate,
	t.PvdNPINo,
	t.PvdCMSId,
	t.CreateDate,
	t.LastChangedOn
FROM src.PROVIDER t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PROVIDER
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIDNo = s.PvdIDNo
WHERE t.DmlOperation <> 'D';

GO


