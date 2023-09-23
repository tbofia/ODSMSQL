IF OBJECT_ID('dbo.if_ProviderAddress', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderAddress;
GO

CREATE FUNCTION dbo.if_ProviderAddress(
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
	t.ProviderSubSet,
	t.ProviderAddressSeq,
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
FROM src.ProviderAddress t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderSubSet,
		ProviderAddressSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderAddress
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderSubSet,
		ProviderAddressSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderSubSet = s.ProviderSubSet
	AND t.ProviderAddressSeq = s.ProviderAddressSeq
WHERE t.DmlOperation <> 'D';

GO


