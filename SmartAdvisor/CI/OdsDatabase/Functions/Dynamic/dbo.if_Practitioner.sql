IF OBJECT_ID('dbo.if_Practitioner', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Practitioner;
GO

CREATE FUNCTION dbo.if_Practitioner(
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
	t.SiteCode,
	t.NPI,
	t.EntityTypeCode,
	t.Name,
	t.FirstName,
	t.LastName,
	t.MiddleName,
	t.Suffix,
	t.NameOther,
	t.MailingAddress1,
	t.MailingAddress2,
	t.MailingCity,
	t.MailingState,
	t.MailingZip,
	t.PracticeAddress1,
	t.PracticeAddress2,
	t.PracticeCity,
	t.PracticeState,
	t.PracticeZip,
	t.EnumerationDate,
	t.DeactivationReasonCode,
	t.DeactivationDate,
	t.ReactivationDate,
	t.Gender,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.Practitioner t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SiteCode,
		NPI,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Practitioner
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SiteCode,
		NPI) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SiteCode = s.SiteCode
	AND t.NPI = s.NPI
WHERE t.DmlOperation <> 'D';

GO


