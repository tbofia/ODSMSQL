IF OBJECT_ID('dbo.if_AttorneyAddress', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_AttorneyAddress;
GO

CREATE FUNCTION dbo.if_AttorneyAddress(
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
	t.AttorneyAddressSeq,
	t.RecType,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.Zip,
	t.PhoneNum,
	t.FaxNum,
	t.ContactFirstName,
	t.ContactLastName,
	t.ContactMiddleInitial,
	t.URFirstName,
	t.URLastName,
	t.URMiddleInitial,
	t.FacilityName,
	t.CountryCode,
	t.MailCode
FROM src.AttorneyAddress t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		AttorneyAddressSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AttorneyAddress
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		AttorneyAddressSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.AttorneyAddressSeq = s.AttorneyAddressSeq
WHERE t.DmlOperation <> 'D';

GO


