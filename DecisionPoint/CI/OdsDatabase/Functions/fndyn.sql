IF OBJECT_ID('aw.if_AcceptedTreatmentDate', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_AcceptedTreatmentDate;
GO

CREATE FUNCTION aw.if_AcceptedTreatmentDate(
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
	t.AcceptedTreatmentDateId,
	t.DemandClaimantId,
	t.TreatmentDate,
	t.Comments,
	t.TreatmentCategoryId,
	t.LastUpdatedBy,
	t.LastUpdatedDate
FROM src.AcceptedTreatmentDate t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AcceptedTreatmentDateId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AcceptedTreatmentDate
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AcceptedTreatmentDateId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AcceptedTreatmentDateId = s.AcceptedTreatmentDateId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_AnalysisGroup', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_AnalysisGroup;
GO

CREATE FUNCTION aw.if_AnalysisGroup(
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
	t.AnalysisGroupId,
	t.GroupName
FROM src.AnalysisGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisGroup
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisGroupId = s.AnalysisGroupId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_AnalysisRule', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_AnalysisRule;
GO

CREATE FUNCTION aw.if_AnalysisRule(
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
	t.AnalysisRuleId,
	t.Title,
	t.AssemblyQualifiedName,
	t.MethodToInvoke,
	t.DisplayMessage,
	t.DisplayOrder,
	t.IsActive,
	t.CreateDate,
	t.LastChangedOn,
	t.MessageToken
FROM src.AnalysisRule t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisRuleId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisRule
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisRuleId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisRuleId = s.AnalysisRuleId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_AnalysisRuleGroup', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_AnalysisRuleGroup;
GO

CREATE FUNCTION aw.if_AnalysisRuleGroup(
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
	t.AnalysisRuleGroupId,
	t.AnalysisRuleId,
	t.AnalysisGroupId
FROM src.AnalysisRuleGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisRuleGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisRuleGroup
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisRuleGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisRuleGroupId = s.AnalysisRuleGroupId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_AnalysisRuleThreshold', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_AnalysisRuleThreshold;
GO

CREATE FUNCTION aw.if_AnalysisRuleThreshold(
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
	t.AnalysisRuleThresholdId,
	t.AnalysisRuleId,
	t.ThresholdKey,
	t.ThresholdValue,
	t.CreateDate,
	t.LastChangedOn
FROM src.AnalysisRuleThreshold t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisRuleThresholdId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisRuleThreshold
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisRuleThresholdId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisRuleThresholdId = s.AnalysisRuleThresholdId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_ClaimantManualProviderSummary', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_ClaimantManualProviderSummary;
GO

CREATE FUNCTION aw.if_ClaimantManualProviderSummary(
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
	t.ManualProviderId,
	t.DemandClaimantId,
	t.FirstDateOfService,
	t.LastDateOfService,
	t.Visits,
	t.ChargedAmount,
	t.EvaluatedAmount,
	t.MinimumEvaluatedAmount,
	t.MaximumEvaluatedAmount,
	t.Comments
FROM src.ClaimantManualProviderSummary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ManualProviderId,
		DemandClaimantId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimantManualProviderSummary
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ManualProviderId,
		DemandClaimantId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ManualProviderId = s.ManualProviderId
	AND t.DemandClaimantId = s.DemandClaimantId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_ClaimantProviderSummaryEvaluation', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_ClaimantProviderSummaryEvaluation;
GO

CREATE FUNCTION aw.if_ClaimantProviderSummaryEvaluation(
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
	t.ClaimantProviderSummaryEvaluationId,
	t.ClaimantHeaderId,
	t.EvaluatedAmount,
	t.MinimumEvaluatedAmount,
	t.MaximumEvaluatedAmount,
	t.Comments
FROM src.ClaimantProviderSummaryEvaluation t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimantProviderSummaryEvaluationId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimantProviderSummaryEvaluation
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimantProviderSummaryEvaluationId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimantProviderSummaryEvaluationId = s.ClaimantProviderSummaryEvaluationId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_DemandClaimant', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_DemandClaimant;
GO

CREATE FUNCTION aw.if_DemandClaimant(
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
	t.DemandClaimantId,
	t.ExternalClaimantId,
	t.OrganizationId,
	t.HeightInInches,
	t.Weight,
	t.Occupation,
	t.BiReportStatus,
	t.HasDemandPackage,
	t.FactsOfLoss,
	t.PreExistingConditions,
	t.Archived
FROM src.DemandClaimant t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandClaimantId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandClaimant
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandClaimantId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandClaimantId = s.DemandClaimantId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_DemandPackage', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_DemandPackage;
GO

CREATE FUNCTION aw.if_DemandPackage(
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
	t.DemandPackageId,
	t.DemandClaimantId,
	t.RequestedByUserName,
	t.DateTimeReceived,
	t.CorrelationId,
	t.PageCount
FROM src.DemandPackage t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandPackageId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandPackage
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandPackageId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandPackageId = s.DemandPackageId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_DemandPackageRequestedService', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_DemandPackageRequestedService;
GO

CREATE FUNCTION aw.if_DemandPackageRequestedService(
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
	t.DemandPackageRequestedServiceId,
	t.DemandPackageId,
	t.ReviewRequestOptions
FROM src.DemandPackageRequestedService t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandPackageRequestedServiceId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandPackageRequestedService
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandPackageRequestedServiceId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandPackageRequestedServiceId = s.DemandPackageRequestedServiceId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_DemandPackageUploadedFile', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_DemandPackageUploadedFile;
GO

CREATE FUNCTION aw.if_DemandPackageUploadedFile(
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
	t.DemandPackageUploadedFileId,
	t.DemandPackageId,
	t.FileName,
	t.Size,
	t.DocStoreId
FROM src.DemandPackageUploadedFile t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandPackageUploadedFileId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandPackageUploadedFile
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandPackageUploadedFileId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandPackageUploadedFileId = s.DemandPackageUploadedFileId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_EvaluationSummary', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_EvaluationSummary;
GO

CREATE FUNCTION aw.if_EvaluationSummary(
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
	t.DemandClaimantId,
	t.Details,
	t.CreatedBy,
	t.CreatedDate,
	t.ModifiedBy,
	t.ModifiedDate,
	t.EvaluationSummaryTemplateVersionId
FROM src.EvaluationSummary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandClaimantId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EvaluationSummary
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandClaimantId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandClaimantId = s.DemandClaimantId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_EvaluationSummaryHistory', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_EvaluationSummaryHistory;
GO

CREATE FUNCTION aw.if_EvaluationSummaryHistory(
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
	t.EvaluationSummaryHistoryId,
	t.DemandClaimantId,
	t.EvaluationSummary,
	t.CreatedBy,
	t.CreatedDate
FROM src.EvaluationSummaryHistory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EvaluationSummaryHistoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EvaluationSummaryHistory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EvaluationSummaryHistoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EvaluationSummaryHistoryId = s.EvaluationSummaryHistoryId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_EvaluationSummaryTemplateVersion', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_EvaluationSummaryTemplateVersion;
GO

CREATE FUNCTION aw.if_EvaluationSummaryTemplateVersion(
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
	t.EvaluationSummaryTemplateVersionId,
	t.Template,
	t.TemplateHash,
	t.CreatedDate
FROM src.EvaluationSummaryTemplateVersion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EvaluationSummaryTemplateVersionId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EvaluationSummaryTemplateVersion
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EvaluationSummaryTemplateVersionId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EvaluationSummaryTemplateVersionId = s.EvaluationSummaryTemplateVersionId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_EventLog', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_EventLog;
GO

CREATE FUNCTION aw.if_EventLog(
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
	t.EventLogId,
	t.ObjectName,
	t.ObjectId,
	t.UserName,
	t.LogDate,
	t.ActionName,
	t.OrganizationId
FROM src.EventLog t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EventLogId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EventLog
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EventLogId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EventLogId = s.EventLogId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_EventLogDetail', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_EventLogDetail;
GO

CREATE FUNCTION aw.if_EventLogDetail(
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
	t.EventLogDetailId,
	t.EventLogId,
	t.PropertyName,
	t.OldValue,
	t.NewValue
FROM src.EventLogDetail t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EventLogDetailId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EventLogDetail
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EventLogDetailId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EventLogDetailId = s.EventLogDetailId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_ManualProvider', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_ManualProvider;
GO

CREATE FUNCTION aw.if_ManualProvider(
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
	t.ManualProviderId,
	t.TIN,
	t.LastName,
	t.FirstName,
	t.GroupName,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.Zip
FROM src.ManualProvider t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ManualProviderId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ManualProvider
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ManualProviderId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ManualProviderId = s.ManualProviderId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_ManualProviderSpecialty', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_ManualProviderSpecialty;
GO

CREATE FUNCTION aw.if_ManualProviderSpecialty(
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
	t.ManualProviderId,
	t.Specialty
FROM src.ManualProviderSpecialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ManualProviderId,
		Specialty,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ManualProviderSpecialty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ManualProviderId,
		Specialty) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ManualProviderId = s.ManualProviderId
	AND t.Specialty = s.Specialty
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_Note', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_Note;
GO

CREATE FUNCTION aw.if_Note(
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
	t.NoteId,
	t.DateCreated,
	t.DateModified,
	t.CreatedBy,
	t.ModifiedBy,
	t.Flag,
	t.Content,
	t.NoteContext,
	t.DemandClaimantId
FROM src.Note t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NoteId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Note
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NoteId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NoteId = s.NoteId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_ProvidedLink', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_ProvidedLink;
GO

CREATE FUNCTION aw.if_ProvidedLink(
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
	t.ProvidedLinkId,
	t.Title,
	t.URL,
	t.OrderIndex
FROM src.ProvidedLink t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProvidedLinkId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProvidedLink
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProvidedLinkId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProvidedLinkId = s.ProvidedLinkId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_Tag', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_Tag;
GO

CREATE FUNCTION aw.if_Tag(
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
	t.TagId,
	t.NAME,
	t.DateCreated,
	t.DateModified,
	t.CreatedBy,
	t.ModifiedBy
FROM src.Tag t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TagId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Tag
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TagId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TagId = s.TagId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_TreatmentCategory', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_TreatmentCategory;
GO

CREATE FUNCTION aw.if_TreatmentCategory(
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
	t.TreatmentCategoryId,
	t.Category,
	t.Metadata
FROM src.TreatmentCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TreatmentCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.TreatmentCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TreatmentCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TreatmentCategoryId = s.TreatmentCategoryId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('aw.if_TreatmentCategoryRange', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_TreatmentCategoryRange;
GO

CREATE FUNCTION aw.if_TreatmentCategoryRange(
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
	t.TreatmentCategoryRangeId,
	t.TreatmentCategoryId,
	t.StartRange,
	t.EndRange
FROM src.TreatmentCategoryRange t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TreatmentCategoryRangeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.TreatmentCategoryRange
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TreatmentCategoryRangeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TreatmentCategoryRangeId = s.TreatmentCategoryRangeId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Adjustment3603rdPartyEndNoteSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjustment3603rdPartyEndNoteSubCategory;
GO

CREATE FUNCTION dbo.if_Adjustment3603rdPartyEndNoteSubCategory(
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
	t.ReasonNumber,
	t.SubCategoryId
FROM src.Adjustment3603rdPartyEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment3603rdPartyEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Adjustment360ApcEndNoteSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjustment360ApcEndNoteSubCategory;
GO

CREATE FUNCTION dbo.if_Adjustment360ApcEndNoteSubCategory(
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
	t.ReasonNumber,
	t.SubCategoryId
FROM src.Adjustment360ApcEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360ApcEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Adjustment360Category', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjustment360Category;
GO

CREATE FUNCTION dbo.if_Adjustment360Category(
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
	t.Adjustment360CategoryId,
	t.Name
FROM src.Adjustment360Category t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Adjustment360CategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360Category
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Adjustment360CategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Adjustment360CategoryId = s.Adjustment360CategoryId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Adjustment360EndNoteSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjustment360EndNoteSubCategory;
GO

CREATE FUNCTION dbo.if_Adjustment360EndNoteSubCategory(
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
	t.ReasonNumber,
	t.SubCategoryId,
	t.EndnoteTypeId
FROM src.Adjustment360EndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		EndnoteTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360EndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber,
		EndnoteTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
	AND t.EndnoteTypeId = s.EndnoteTypeId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Adjustment360OverrideEndNoteSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjustment360OverrideEndNoteSubCategory;
GO

CREATE FUNCTION dbo.if_Adjustment360OverrideEndNoteSubCategory(
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
	t.ReasonNumber,
	t.SubCategoryId
FROM src.Adjustment360OverrideEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360OverrideEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Adjustment360SubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjustment360SubCategory;
GO

CREATE FUNCTION dbo.if_Adjustment360SubCategory(
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
	t.Adjustment360SubCategoryId,
	t.Name,
	t.Adjustment360CategoryId
FROM src.Adjustment360SubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Adjustment360SubCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment360SubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Adjustment360SubCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Adjustment360SubCategoryId = s.Adjustment360SubCategoryId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Adjustment3rdPartyEndnoteSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjustment3rdPartyEndnoteSubCategory;
GO

CREATE FUNCTION dbo.if_Adjustment3rdPartyEndnoteSubCategory(
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
	t.ReasonNumber,
	t.SubCategoryId
FROM src.Adjustment3rdPartyEndnoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustment3rdPartyEndnoteSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_AdjustmentApcEndNoteSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_AdjustmentApcEndNoteSubCategory;
GO

CREATE FUNCTION dbo.if_AdjustmentApcEndNoteSubCategory(
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
	t.ReasonNumber,
	t.SubCategoryId
FROM src.AdjustmentApcEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AdjustmentApcEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_AdjustmentEndNoteSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_AdjustmentEndNoteSubCategory;
GO

CREATE FUNCTION dbo.if_AdjustmentEndNoteSubCategory(
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
	t.ReasonNumber,
	t.SubCategoryId
FROM src.AdjustmentEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AdjustmentEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_AdjustmentOverrideEndNoteSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_AdjustmentOverrideEndNoteSubCategory;
GO

CREATE FUNCTION dbo.if_AdjustmentOverrideEndNoteSubCategory(
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
	t.ReasonNumber,
	t.SubCategoryId
FROM src.AdjustmentOverrideEndNoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AdjustmentOverrideEndNoteSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Adjustor', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Adjustor;
GO

CREATE FUNCTION dbo.if_Adjustor(
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
	t.lAdjIdNo,
	t.IDNumber,
	t.Lastname,
	t.FirstName,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.ZipCode,
	t.Phone,
	t.Fax,
	t.Office,
	t.EMail,
	t.InUse,
	t.OfficeIdNo,
	t.UserId,
	t.CreateDate,
	t.LastChangedOn
FROM src.Adjustor t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		lAdjIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Adjustor
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		lAdjIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.lAdjIdNo = s.lAdjIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ApportionmentEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ApportionmentEndnote;
GO

CREATE FUNCTION dbo.if_ApportionmentEndnote(
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
	t.ApportionmentEndnote,
	t.ShortDescription,
	t.LongDescription
FROM src.ApportionmentEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ApportionmentEndnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ApportionmentEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ApportionmentEndnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ApportionmentEndnote = s.ApportionmentEndnote
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillAdjustment', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillAdjustment;
GO

CREATE FUNCTION dbo.if_BillAdjustment(
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
	t.BillLineAdjustmentId,
	t.BillIdNo,
	t.LineNumber,
	t.Adjustment,
	t.EndNote,
	t.EndNoteTypeId
FROM src.BillAdjustment t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillLineAdjustmentId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillAdjustment
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillLineAdjustmentId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillLineAdjustmentId = s.BillLineAdjustmentId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillApportionmentEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillApportionmentEndnote;
GO

CREATE FUNCTION dbo.if_BillApportionmentEndnote(
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
	t.BillId,
	t.LineNumber,
	t.Endnote
FROM src.BillApportionmentEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillApportionmentEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillCustomEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillCustomEndnote;
GO

CREATE FUNCTION dbo.if_BillCustomEndnote(
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
	t.BillId,
	t.LineNumber,
	t.Endnote
FROM src.BillCustomEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillCustomEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillExclusionLookUpTable', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillExclusionLookUpTable;
GO

CREATE FUNCTION dbo.if_BillExclusionLookUpTable(
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
	t.ReportID,
	t.ReportName
FROM src.BillExclusionLookUpTable t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReportID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillExclusionLookUpTable
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReportID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReportID = s.ReportID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BILLS', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BILLS;
GO

CREATE FUNCTION dbo.if_BILLS(
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
	t.BillIDNo,
	t.LINE_NO,
	t.LINE_NO_DISP,
	t.OVER_RIDE,
	t.DT_SVC,
	t.PRC_CD,
	t.UNITS,
	t.TS_CD,
	t.CHARGED,
	t.ALLOWED,
	t.ANALYZED,
	t.REASON1,
	t.REASON2,
	t.REASON3,
	t.REASON4,
	t.REASON5,
	t.REASON6,
	t.REASON7,
	t.REASON8,
	t.REF_LINE_NO,
	t.SUBNET,
	t.OverrideReason,
	t.FEE_SCHEDULE,
	t.POS_RevCode,
	t.CTGPenalty,
	t.PrePPOAllowed,
	t.PPODate,
	t.PPOCTGPenalty,
	t.UCRPerUnit,
	t.FSPerUnit,
	t.HCRA_Surcharge,
	t.EligibleAmt,
	t.DPAllowed,
	t.EndDateOfService,
	t.AnalyzedCtgPenalty,
	t.AnalyzedCtgPpoPenalty,
	t.RepackagedNdc,
	t.OriginalNdc,
	t.UnitOfMeasureId,
	t.PackageTypeOriginalNdc,
	t.ServiceCode,
	t.PreApportionedAmount,
	t.DeductibleApplied,
	t.BillReviewResults,
	t.PreOverriddenDeductible,
	t.RemainingBalance,
	t.CtgCoPayPenalty,
	t.PpoCtgCoPayPenaltyPercentage,
	t.AnalyzedCtgCoPayPenalty,
	t.AnalyzedPpoCtgCoPayPenaltyPercentage,
	t.CtgVunPenalty,
	t.PpoCtgVunPenaltyPercentage,
	t.AnalyzedCtgVunPenalty,
	t.AnalyzedPpoCtgVunPenaltyPercentage,
	t.RenderingNpi
FROM src.BILLS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		LINE_NO,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		LINE_NO) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.LINE_NO = s.LINE_NO
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillsOverride', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillsOverride;
GO

CREATE FUNCTION dbo.if_BillsOverride(
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
	t.BillsOverrideID,
	t.BillIDNo,
	t.LINE_NO,
	t.UserId,
	t.DateSaved,
	t.AmountBefore,
	t.AmountAfter,
	t.CodesOverrode,
	t.SeqNo
FROM src.BillsOverride t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillsOverrideID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillsOverride
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillsOverrideID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillsOverrideID = s.BillsOverrideID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BillsProviderNetwork', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillsProviderNetwork;
GO

CREATE FUNCTION dbo.if_BillsProviderNetwork(
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
	t.BillIdNo,
	t.NetworkId,
	t.NetworkName
FROM src.BillsProviderNetwork t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillsProviderNetwork
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BILLS_CTG_Endnotes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BILLS_CTG_Endnotes;
GO

CREATE FUNCTION dbo.if_BILLS_CTG_Endnotes(
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
	t.BillIdNo,
	t.Line_No,
	t.Endnote,
	t.RuleType,
	t.RuleId,
	t.PreCertAction,
	t.PercentDiscount,
	t.ActionId
FROM src.BILLS_CTG_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Line_No,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS_CTG_Endnotes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Line_No,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Line_No = s.Line_No
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BILLS_DRG', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BILLS_DRG;
GO

CREATE FUNCTION dbo.if_BILLS_DRG(
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
	t.BillIdNo,
	t.PricerPassThru,
	t.PricerCapital_Outlier_Amt,
	t.PricerCapital_OldHarm_Amt,
	t.PricerCapital_IME_Amt,
	t.PricerCapital_HSP_Amt,
	t.PricerCapital_FSP_Amt,
	t.PricerCapital_Exceptions_Amt,
	t.PricerCapital_DSH_Amt,
	t.PricerCapitalPayment,
	t.PricerDSH,
	t.PricerIME,
	t.PricerCostOutlier,
	t.PricerHSP,
	t.PricerFSP,
	t.PricerTotalPayment,
	t.PricerReturnMsg,
	t.ReturnDRG,
	t.ReturnDRGDesc,
	t.ReturnMDC,
	t.ReturnMDCDesc,
	t.ReturnDRGWt,
	t.ReturnDRGALOS,
	t.ReturnADX,
	t.ReturnSDX,
	t.ReturnMPR,
	t.ReturnPR2,
	t.ReturnPR3,
	t.ReturnNOR,
	t.ReturnNO2,
	t.ReturnCOM,
	t.ReturnCMI,
	t.ReturnDCC,
	t.ReturnDX1,
	t.ReturnDX2,
	t.ReturnDX3,
	t.ReturnMCI,
	t.ReturnOR1,
	t.ReturnOR2,
	t.ReturnOR3,
	t.ReturnTRI,
	t.SOJ,
	t.OPCERT,
	t.BlendCaseInclMalp,
	t.CapitalCost,
	t.HospBadDebt,
	t.ExcessPhysMalp,
	t.SparcsPerCase,
	t.AltLevelOfCare,
	t.DRGWgt,
	t.TransferCapital,
	t.NYDrgType,
	t.LOS,
	t.TrimPoint,
	t.GroupBlendPercentage,
	t.AdjustmentFactor,
	t.HospLongStayGroupPrice,
	t.TotalDRGCharge,
	t.BlendCaseAdj,
	t.CapitalCostAdj,
	t.NonMedicareCaseMix,
	t.HighCostChargeConverter,
	t.DischargeCasePaymentRate,
	t.DirectMedicalEducation,
	t.CasePaymentCapitalPerDiem,
	t.HighCostOutlierThreshold,
	t.ISAF,
	t.ReturnSOI,
	t.CapitalCostPerDischarge,
	t.ReturnSOIDesc
FROM src.BILLS_DRG t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS_DRG
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BILLS_Endnotes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BILLS_Endnotes;
GO

CREATE FUNCTION dbo.if_BILLS_Endnotes(
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
	t.BillIDNo,
	t.LINE_NO,
	t.EndNote,
	t.Referral,
	t.PercentDiscount,
	t.ActionId,
	t.EndnoteTypeId
FROM src.BILLS_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		EndnoteTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS_Endnotes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		EndnoteTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.LINE_NO = s.LINE_NO
	AND t.EndNote = s.EndNote
	AND t.EndnoteTypeId = s.EndnoteTypeId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Bills_OverrideEndNotes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bills_OverrideEndNotes;
GO

CREATE FUNCTION dbo.if_Bills_OverrideEndNotes(
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
	t.OverrideEndNoteID,
	t.BillIdNo,
	t.Line_No,
	t.OverrideEndNote,
	t.PercentDiscount,
	t.ActionId
FROM src.Bills_OverrideEndNotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OverrideEndNoteID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_OverrideEndNotes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OverrideEndNoteID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OverrideEndNoteID = s.OverrideEndNoteID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Bills_Pharm', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bills_Pharm;
GO

CREATE FUNCTION dbo.if_Bills_Pharm(
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
	t.BillIdNo,
	t.Line_No,
	t.LINE_NO_DISP,
	t.DateOfService,
	t.NDC,
	t.PriceTypeCode,
	t.Units,
	t.Charged,
	t.Allowed,
	t.EndNote,
	t.Override,
	t.Override_Rsn,
	t.Analyzed,
	t.CTGPenalty,
	t.PrePPOAllowed,
	t.PPODate,
	t.POS_RevCode,
	t.DPAllowed,
	t.HCRA_Surcharge,
	t.EndDateOfService,
	t.RepackagedNdc,
	t.OriginalNdc,
	t.UnitOfMeasureId,
	t.PackageTypeOriginalNdc,
	t.PpoCtgPenalty,
	t.ServiceCode,
	t.PreApportionedAmount,
	t.DeductibleApplied,
	t.BillReviewResults,
	t.PreOverriddenDeductible,
	t.RemainingBalance,
	t.CtgCoPayPenalty,
	t.PpoCtgCoPayPenaltyPercentage,
	t.CtgVunPenalty,
	t.PpoCtgVunPenaltyPercentage,
	t.RenderingNpi
FROM src.Bills_Pharm t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Line_No,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Pharm
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Line_No) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Line_No = s.Line_No
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Bills_Pharm_CTG_Endnotes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bills_Pharm_CTG_Endnotes;
GO

CREATE FUNCTION dbo.if_Bills_Pharm_CTG_Endnotes(
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
	t.BillIDNo,
	t.LINE_NO,
	t.EndNote,
	t.RuleType,
	t.RuleId,
	t.PreCertAction,
	t.PercentDiscount,
	t.ActionId
FROM src.Bills_Pharm_CTG_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Pharm_CTG_Endnotes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.LINE_NO = s.LINE_NO
	AND t.EndNote = s.EndNote
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Bills_Pharm_Endnotes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bills_Pharm_Endnotes;
GO

CREATE FUNCTION dbo.if_Bills_Pharm_Endnotes(
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
	t.BillIDNo,
	t.LINE_NO,
	t.EndNote,
	t.Referral,
	t.PercentDiscount,
	t.ActionId,
	t.EndnoteTypeId
FROM src.Bills_Pharm_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		EndnoteTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Pharm_Endnotes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		EndnoteTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.LINE_NO = s.LINE_NO
	AND t.EndNote = s.EndNote
	AND t.EndnoteTypeId = s.EndnoteTypeId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Bills_Pharm_OverrideEndNotes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bills_Pharm_OverrideEndNotes;
GO

CREATE FUNCTION dbo.if_Bills_Pharm_OverrideEndNotes(
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
	t.OverrideEndNoteID,
	t.BillIdNo,
	t.Line_No,
	t.OverrideEndNote,
	t.PercentDiscount,
	t.ActionId
FROM src.Bills_Pharm_OverrideEndNotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OverrideEndNoteID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Pharm_OverrideEndNotes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OverrideEndNoteID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OverrideEndNoteID = s.OverrideEndNoteID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Bills_Tax', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bills_Tax;
GO

CREATE FUNCTION dbo.if_Bills_Tax(
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
	t.BillsTaxId,
	t.TableType,
	t.BillIdNo,
	t.Line_No,
	t.SeqNo,
	t.TaxTypeId,
	t.ImportTaxRate,
	t.Tax,
	t.OverridenTax,
	t.ImportTaxAmount
FROM src.Bills_Tax t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillsTaxId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Tax
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillsTaxId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillsTaxId = s.BillsTaxId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BILL_HDR', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BILL_HDR;
GO

CREATE FUNCTION dbo.if_BILL_HDR(
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
	t.BillIDNo,
	t.CMT_HDR_IDNo,
	t.DateSaved,
	t.DateRcv,
	t.InvoiceNumber,
	t.InvoiceDate,
	t.FileNumber,
	t.Note,
	t.NoLines,
	t.AmtCharged,
	t.AmtAllowed,
	t.ReasonVersion,
	t.Region,
	t.PvdUpdateCounter,
	t.FeatureID,
	t.ClaimDateLoss,
	t.CV_Type,
	t.Flags,
	t.WhoCreate,
	t.WhoLast,
	t.AcceptAssignment,
	t.EmergencyService,
	t.CmtPaidDeductible,
	t.InsPaidLimit,
	t.StatusFlag,
	t.OfficeId,
	t.CmtPaidCoPay,
	t.AmbulanceMethod,
	t.StatusDate,
	t.Category,
	t.CatDesc,
	t.AssignedUser,
	t.CreateDate,
	t.PvdZOS,
	t.PPONumberSent,
	t.AdmissionDate,
	t.DischargeDate,
	t.DischargeStatus,
	t.TypeOfBill,
	t.SentryMessage,
	t.AmbulanceZipOfPickup,
	t.AmbulanceNumberOfPatients,
	t.WhoCreateID,
	t.WhoLastId,
	t.NYRequestDate,
	t.NYReceivedDate,
	t.ImgDocId,
	t.PaymentDecision,
	t.PvdCMSId,
	t.PvdNPINo,
	t.DischargeHour,
	t.PreCertChanged,
	t.DueDate,
	t.AttorneyIDNo,
	t.AssignedGroup,
	t.LastChangedOn,
	t.PrePPOAllowed,
	t.PPSCode,
	t.SOI,
	t.StatementStartDate,
	t.StatementEndDate,
	t.DeductibleOverride,
	t.AdmissionType,
	t.CoverageType,
	t.PricingProfileId,
	t.DesignatedPricingState,
	t.DateAnalyzed,
	t.SentToPpoSysId,
	t.PricingState,
	t.BillVpnEligible,
	t.ApportionmentPercentage,
	t.BillSourceId,
	t.OutOfStateProviderNumber,
	t.FloridaDeductibleRuleEligible
FROM src.BILL_HDR t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILL_HDR
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Bill_History', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bill_History;
GO

CREATE FUNCTION dbo.if_Bill_History(
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
	t.BillIdNo,
	t.SeqNo,
	t.DateCommitted,
	t.AmtCommitted,
	t.UserId,
	t.AmtCoPay,
	t.AmtDeductible,
	t.Flags,
	t.AmtSalesTax,
	t.AmtOtherTax,
	t.DeductibleOverride,
	t.PricingState,
	t.ApportionmentPercentage,
	t.FloridaDeductibleRuleEligible
FROM src.Bill_History t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		SeqNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_History
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		SeqNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.SeqNo = s.SeqNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Bill_Payment_Adjustments', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bill_Payment_Adjustments;
GO

CREATE FUNCTION dbo.if_Bill_Payment_Adjustments(
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
	t.Bill_Payment_Adjustment_ID,
	t.BillIDNo,
	t.SeqNo,
	t.InterestFlags,
	t.DateInterestStarts,
	t.DateInterestEnds,
	t.InterestAdditionalInfoReceived,
	t.Interest,
	t.Comments
FROM src.Bill_Payment_Adjustments t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Bill_Payment_Adjustment_ID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_Payment_Adjustments
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Bill_Payment_Adjustment_ID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Bill_Payment_Adjustment_ID = s.Bill_Payment_Adjustment_ID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Bill_Pharm_ApportionmentEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bill_Pharm_ApportionmentEndnote;
GO

CREATE FUNCTION dbo.if_Bill_Pharm_ApportionmentEndnote(
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
	t.BillId,
	t.LineNumber,
	t.Endnote
FROM src.Bill_Pharm_ApportionmentEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_Pharm_ApportionmentEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Bill_Sentry_Endnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bill_Sentry_Endnote;
GO

CREATE FUNCTION dbo.if_Bill_Sentry_Endnote(
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
	t.BillID,
	t.Line,
	t.RuleID,
	t.PercentDiscount,
	t.ActionId
FROM src.Bill_Sentry_Endnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillID,
		Line,
		RuleID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_Sentry_Endnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillID,
		Line,
		RuleID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillID = s.BillID
	AND t.Line = s.Line
	AND t.RuleID = s.RuleID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BIReportAdjustmentCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BIReportAdjustmentCategory;
GO

CREATE FUNCTION dbo.if_BIReportAdjustmentCategory(
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
	t.BIReportAdjustmentCategoryId,
	t.Name,
	t.Description,
	t.DisplayPriority
FROM src.BIReportAdjustmentCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BIReportAdjustmentCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BIReportAdjustmentCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BIReportAdjustmentCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BIReportAdjustmentCategoryId = s.BIReportAdjustmentCategoryId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_BIReportAdjustmentCategoryMapping', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BIReportAdjustmentCategoryMapping;
GO

CREATE FUNCTION dbo.if_BIReportAdjustmentCategoryMapping(
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
	t.BIReportAdjustmentCategoryId,
	t.Adjustment360SubCategoryId
FROM src.BIReportAdjustmentCategoryMapping t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BIReportAdjustmentCategoryId,
		Adjustment360SubCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BIReportAdjustmentCategoryMapping
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BIReportAdjustmentCategoryId,
		Adjustment360SubCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BIReportAdjustmentCategoryId = s.BIReportAdjustmentCategoryId
	AND t.Adjustment360SubCategoryId = s.Adjustment360SubCategoryId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Bitmasks', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bitmasks;
GO

CREATE FUNCTION dbo.if_Bitmasks(
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
	t.TableProgramUsed,
	t.AttributeUsed,
	t.Decimal,
	t.ConstantName,
	t.Bit,
	t.Hex,
	t.Description
FROM src.Bitmasks t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TableProgramUsed,
		AttributeUsed,
		Decimal,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bitmasks
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TableProgramUsed,
		AttributeUsed,
		Decimal) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TableProgramUsed = s.TableProgramUsed
	AND t.AttributeUsed = s.AttributeUsed
	AND t.Decimal = s.Decimal
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CbreToDpEndnoteMapping', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CbreToDpEndnoteMapping;
GO

CREATE FUNCTION dbo.if_CbreToDpEndnoteMapping(
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
	t.Endnote,
	t.EndnoteTypeId,
	t.CbreEndnote,
	t.PricingState,
	t.PricingMethodId
FROM src.CbreToDpEndnoteMapping t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Endnote,
		EndnoteTypeId,
		CbreEndnote,
		PricingState,
		PricingMethodId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CbreToDpEndnoteMapping
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Endnote,
		EndnoteTypeId,
		CbreEndnote,
		PricingState,
		PricingMethodId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Endnote = s.Endnote
	AND t.EndnoteTypeId = s.EndnoteTypeId
	AND t.CbreEndnote = s.CbreEndnote
	AND t.PricingState = s.PricingState
	AND t.PricingMethodId = s.PricingMethodId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CLAIMANT', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CLAIMANT;
GO

CREATE FUNCTION dbo.if_CLAIMANT(
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
	t.CmtIDNo,
	t.ClaimIDNo,
	t.CmtSSN,
	t.CmtLastName,
	t.CmtFirstName,
	t.CmtMI,
	t.CmtDOB,
	t.CmtSEX,
	t.CmtAddr1,
	t.CmtAddr2,
	t.CmtCity,
	t.CmtState,
	t.CmtZip,
	t.CmtPhone,
	t.CmtOccNo,
	t.CmtAttorneyNo,
	t.CmtPolicyLimit,
	t.CmtStateOfJurisdiction,
	t.CmtDeductible,
	t.CmtCoPaymentPercentage,
	t.CmtCoPaymentMax,
	t.CmtPPO_Eligible,
	t.CmtCoordBenefits,
	t.CmtFLCopay,
	t.CmtCOAExport,
	t.CmtPGFirstName,
	t.CmtPGLastName,
	t.CmtDedType,
	t.ExportToClaimIQ,
	t.CmtInactive,
	t.CmtPreCertOption,
	t.CmtPreCertState,
	t.CreateDate,
	t.LastChangedOn,
	t.OdsParticipant,
	t.CoverageType,
	t.DoNotDisplayCoverageTypeOnEOB,
	t.ShowAllocationsOnEob,
	t.SetPreAllocation,
	t.PharmacyEligible,
	t.SendCardToClaimant,
	t.ShareCoPayMaximum
FROM src.CLAIMANT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CmtIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CLAIMANT
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CmtIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CmtIDNo = s.CmtIDNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Claimant_ClientRef', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Claimant_ClientRef;
GO

CREATE FUNCTION dbo.if_Claimant_ClientRef(
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
	t.CmtIdNo,
	t.CmtSuffix,
	t.ClaimIdNo
FROM src.Claimant_ClientRef t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CmtIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Claimant_ClientRef
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CmtIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CmtIdNo = s.CmtIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CLAIMS', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CLAIMS;
GO

CREATE FUNCTION dbo.if_CLAIMS(
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
	t.ClaimIDNo,
	t.ClaimNo,
	t.DateLoss,
	t.CV_Code,
	t.DiaryIndex,
	t.LastSaved,
	t.PolicyNumber,
	t.PolicyHoldersName,
	t.PaidDeductible,
	t.Status,
	t.InUse,
	t.CompanyID,
	t.OfficeIndex,
	t.AdjIdNo,
	t.PaidCoPay,
	t.AssignedUser,
	t.Privatized,
	t.PolicyEffDate,
	t.Deductible,
	t.LossState,
	t.AssignedGroup,
	t.CreateDate,
	t.LastChangedOn,
	t.AllowMultiCoverage
FROM src.CLAIMS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CLAIMS
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimIDNo = s.ClaimIDNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Claims_ClientRef', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Claims_ClientRef;
GO

CREATE FUNCTION dbo.if_Claims_ClientRef(
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
	t.ClaimIdNo,
	t.ClientRefId
FROM src.Claims_ClientRef t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Claims_ClientRef
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimIdNo = s.ClaimIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CMS_Zip2Region', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CMS_Zip2Region;
GO

CREATE FUNCTION dbo.if_CMS_Zip2Region(
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
	t.StartDate,
	t.EndDate,
	t.ZIP_Code,
	t.State,
	t.Region,
	t.AmbRegion,
	t.RuralFlag,
	t.ASCRegion,
	t.PlusFour,
	t.CarrierId
FROM src.CMS_Zip2Region t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StartDate,
		ZIP_Code,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMS_Zip2Region
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StartDate,
		ZIP_Code) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StartDate = s.StartDate
	AND t.ZIP_Code = s.ZIP_Code
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CMT_DX', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CMT_DX;
GO

CREATE FUNCTION dbo.if_CMT_DX(
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
	t.BillIDNo,
	t.DX,
	t.SeqNum,
	t.POA,
	t.IcdVersion
FROM src.CMT_DX t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		DX,
		IcdVersion,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMT_DX
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		DX,
		IcdVersion) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.DX = s.DX
	AND t.IcdVersion = s.IcdVersion
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CMT_HDR', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CMT_HDR;
GO

CREATE FUNCTION dbo.if_CMT_HDR(
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
	t.CMT_HDR_IDNo,
	t.CmtIDNo,
	t.PvdIDNo,
	t.LastChangedOn
FROM src.CMT_HDR t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CMT_HDR_IDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMT_HDR
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CMT_HDR_IDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CMT_HDR_IDNo = s.CMT_HDR_IDNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CMT_ICD9', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CMT_ICD9;
GO

CREATE FUNCTION dbo.if_CMT_ICD9(
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
	t.BillIDNo,
	t.SeqNo,
	t.ICD9,
	t.IcdVersion
FROM src.CMT_ICD9 t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		SeqNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMT_ICD9
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		SeqNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.SeqNo = s.SeqNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CoverageType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CoverageType;
GO

CREATE FUNCTION dbo.if_CoverageType(
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
	t.LongName,
	t.ShortName,
	t.CbreCoverageTypeCode,
	t.CoverageTypeCategoryCode,
	t.PricingMethodId
FROM src.CoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ShortName,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CoverageType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ShortName) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ShortName = s.ShortName
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_cpt_DX_DICT', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_cpt_DX_DICT;
GO

CREATE FUNCTION dbo.if_cpt_DX_DICT(
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
	t.ICD9,
	t.StartDate,
	t.EndDate,
	t.Flags,
	t.NonSpecific,
	t.AdditionalDigits,
	t.Traumatic,
	t.DX_DESC,
	t.Duration,
	t.Colossus,
	t.DiagnosisFamilyId
FROM src.cpt_DX_DICT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ICD9,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.cpt_DX_DICT
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ICD9,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ICD9 = s.ICD9
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_cpt_PRC_DICT', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_cpt_PRC_DICT;
GO

CREATE FUNCTION dbo.if_cpt_PRC_DICT(
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
	t.PRC_CD,
	t.StartDate,
	t.EndDate,
	t.PRC_DESC,
	t.Flags,
	t.Vague,
	t.PerVisit,
	t.PerClaimant,
	t.PerProvider,
	t.BodyFlags,
	t.Colossus,
	t.CMS_Status,
	t.DrugFlag,
	t.CurativeFlag,
	t.ExclPolicyLimit,
	t.SpecNetFlag
FROM src.cpt_PRC_DICT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PRC_CD,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.cpt_PRC_DICT
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PRC_CD,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PRC_CD = s.PRC_CD
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CreditReason', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CreditReason;
GO

CREATE FUNCTION dbo.if_CreditReason(
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
	t.CreditReasonId,
	t.CreditReasonDesc,
	t.IsVisible
FROM src.CreditReason t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CreditReasonId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CreditReason
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CreditReasonId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CreditReasonId = s.CreditReasonId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CreditReasonOverrideENMap', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CreditReasonOverrideENMap;
GO

CREATE FUNCTION dbo.if_CreditReasonOverrideENMap(
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
	t.CreditReasonOverrideENMapId,
	t.CreditReasonId,
	t.OverrideEndnoteId
FROM src.CreditReasonOverrideENMap t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CreditReasonOverrideENMapId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CreditReasonOverrideENMap
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CreditReasonOverrideENMapId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CreditReasonOverrideENMapId = s.CreditReasonOverrideENMapId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CriticalAccessHospitalInpatientRevenueCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CriticalAccessHospitalInpatientRevenueCode;
GO

CREATE FUNCTION dbo.if_CriticalAccessHospitalInpatientRevenueCode(
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
	t.RevenueCode
FROM src.CriticalAccessHospitalInpatientRevenueCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CriticalAccessHospitalInpatientRevenueCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCode = s.RevenueCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CTG_Endnotes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CTG_Endnotes;
GO

CREATE FUNCTION dbo.if_CTG_Endnotes(
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
	t.Endnote,
	t.ShortDesc,
	t.LongDesc
FROM src.CTG_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CTG_Endnotes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CustomBillStatuses', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CustomBillStatuses;
GO

CREATE FUNCTION dbo.if_CustomBillStatuses(
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
	t.StatusId,
	t.StatusName,
	t.StatusDescription
FROM src.CustomBillStatuses t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StatusId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CustomBillStatuses
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StatusId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StatusId = s.StatusId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CustomEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CustomEndnote;
GO

CREATE FUNCTION dbo.if_CustomEndnote(
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
	t.CustomEndnote,
	t.ShortDescription,
	t.LongDescription
FROM src.CustomEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CustomEndnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CustomEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CustomEndnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CustomEndnote = s.CustomEndnote
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_CustomerBillExclusion', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CustomerBillExclusion;
GO

CREATE FUNCTION dbo.if_CustomerBillExclusion(
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
	t.BillIdNo,
	t.Customer,
	t.ReportID,
	t.CreateDate
FROM src.CustomerBillExclusion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Customer,
		ReportID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CustomerBillExclusion
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Customer,
		ReportID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Customer = s.Customer
	AND t.ReportID = s.ReportID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_DeductibleRuleCriteria', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_DeductibleRuleCriteria;
GO

CREATE FUNCTION dbo.if_DeductibleRuleCriteria(
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
	t.DeductibleRuleCriteriaId,
	t.PricingRuleDateCriteriaId,
	t.StartDate,
	t.EndDate
FROM src.DeductibleRuleCriteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DeductibleRuleCriteriaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DeductibleRuleCriteria
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DeductibleRuleCriteriaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DeductibleRuleCriteriaId = s.DeductibleRuleCriteriaId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_DeductibleRuleCriteriaCoverageType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_DeductibleRuleCriteriaCoverageType;
GO

CREATE FUNCTION dbo.if_DeductibleRuleCriteriaCoverageType(
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
	t.DeductibleRuleCriteriaId,
	t.CoverageType
FROM src.DeductibleRuleCriteriaCoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DeductibleRuleCriteriaId,
		CoverageType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DeductibleRuleCriteriaCoverageType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DeductibleRuleCriteriaId,
		CoverageType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DeductibleRuleCriteriaId = s.DeductibleRuleCriteriaId
	AND t.CoverageType = s.CoverageType
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_DeductibleRuleExemptEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_DeductibleRuleExemptEndnote;
GO

CREATE FUNCTION dbo.if_DeductibleRuleExemptEndnote(
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
	t.Endnote,
	t.EndnoteTypeId
FROM src.DeductibleRuleExemptEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Endnote,
		EndnoteTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DeductibleRuleExemptEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Endnote,
		EndnoteTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Endnote = s.Endnote
	AND t.EndnoteTypeId = s.EndnoteTypeId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_DiagnosisCodeGroup', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_DiagnosisCodeGroup;
GO

CREATE FUNCTION dbo.if_DiagnosisCodeGroup(
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
	t.DiagnosisCode,
	t.StartDate,
	t.EndDate,
	t.MajorCategory,
	t.MinorCategory
FROM src.DiagnosisCodeGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DiagnosisCodeGroup
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_EncounterType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_EncounterType;
GO

CREATE FUNCTION dbo.if_EncounterType(
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
	t.EncounterTypeId,
	t.EncounterTypePriority,
	t.Description,
	t.NarrativeInformation
FROM src.EncounterType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EncounterTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EncounterType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EncounterTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EncounterTypeId = s.EncounterTypeId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_EndnoteSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_EndnoteSubCategory;
GO

CREATE FUNCTION dbo.if_EndnoteSubCategory(
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
	t.EndnoteSubCategoryId,
	t.Description
FROM src.EndnoteSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EndnoteSubCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EndnoteSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EndnoteSubCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EndnoteSubCategoryId = s.EndnoteSubCategoryId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Esp_Ppo_Billing_Data_Self_Bill', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Esp_Ppo_Billing_Data_Self_Bill;
GO

CREATE FUNCTION dbo.if_Esp_Ppo_Billing_Data_Self_Bill(
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
	t.COMPANYCODE,
	t.TRANSACTIONTYPE,
	t.BILL_HDR_AMTALLOWED,
	t.BILL_HDR_AMTCHARGED,
	t.BILL_HDR_BILLIDNO,
	t.BILL_HDR_CMT_HDR_IDNO,
	t.BILL_HDR_CREATEDATE,
	t.BILL_HDR_CV_TYPE,
	t.BILL_HDR_FORM_TYPE,
	t.BILL_HDR_NOLINES,
	t.BILLS_ALLOWED,
	t.BILLS_ANALYZED,
	t.BILLS_CHARGED,
	t.BILLS_DT_SVC,
	t.BILLS_LINE_NO,
	t.CLAIMANT_CLIENTREF_CMTSUFFIX,
	t.CLAIMANT_CMTFIRST_NAME,
	t.CLAIMANT_CMTIDNO,
	t.CLAIMANT_CMTLASTNAME,
	t.CMTSTATEOFJURISDICTION,
	t.CLAIMS_COMPANYID,
	t.CLAIMS_CLAIMNO,
	t.CLAIMS_DATELOSS,
	t.CLAIMS_OFFICEINDEX,
	t.CLAIMS_POLICYHOLDERSNAME,
	t.CLAIMS_POLICYNUMBER,
	t.PNETWKEVENTLOG_EVENTID,
	t.PNETWKEVENTLOG_LOGDATE,
	t.PNETWKEVENTLOG_NETWORKID,
	t.ACTIVITY_FLAG,
	t.PPO_AMTALLOWED,
	t.PREPPO_AMTALLOWED,
	t.PREPPO_ALLOWED_FS,
	t.PRF_COMPANY_COMPANYNAME,
	t.PRF_OFFICE_OFCNAME,
	t.PRF_OFFICE_OFCNO,
	t.PROVIDER_PVDFIRSTNAME,
	t.PROVIDER_PVDGROUP,
	t.PROVIDER_PVDLASTNAME,
	t.PROVIDER_PVDTIN,
	t.PROVIDER_STATE,
	t.UDFCLAIM_UDFVALUETEXT,
	t.ENTRY_DATE,
	t.UDFCLAIMANT_UDFVALUETEXT,
	t.SOURCE_DB,
	t.CLAIMS_CV_CODE,
	t.VPN_TRANSACTIONID,
	t.VPN_TRANSACTIONTYPEID,
	t.VPN_BILLIDNO,
	t.VPN_LINE_NO,
	t.VPN_CHARGED,
	t.VPN_DPALLOWED,
	t.VPN_VPNALLOWED,
	t.VPN_SAVINGS,
	t.VPN_CREDITS,
	t.VPN_HASOVERRIDE,
	t.VPN_ENDNOTES,
	t.VPN_NETWORKIDNO,
	t.VPN_PROCESSFLAG,
	t.VPN_LINETYPE,
	t.VPN_DATETIMESTAMP,
	t.VPN_SEQNO,
	t.VPN_VPN_REF_LINE_NO,
	t.VPN_NETWORKNAME,
	t.VPN_SOJ,
	t.VPN_CAT3,
	t.VPN_PPODATESTAMP,
	t.VPN_NINTEYDAYS,
	t.VPN_BILL_TYPE,
	t.VPN_NET_SAVINGS,
	t.CREDIT,
	t.RECON,
	t.DELETED,
	t.STATUS_FLAG,
	t.DATE_SAVED,
	t.SUB_NETWORK,
	t.INVALID_CREDIT,
	t.PROVIDER_SPECIALTY,
	t.ADJUSTOR_IDNUMBER,
	t.ACP_FLAG,
	t.OVERRIDE_ENDNOTES,
	t.OVERRIDE_ENDNOTES_DESC
FROM src.Esp_Ppo_Billing_Data_Self_Bill t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VPN_TRANSACTIONID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Esp_Ppo_Billing_Data_Self_Bill
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VPN_TRANSACTIONID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VPN_TRANSACTIONID = s.VPN_TRANSACTIONID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ExtractCat', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ExtractCat;
GO

CREATE FUNCTION dbo.if_ExtractCat(
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
	t.CatIdNo,
	t.Description
FROM src.ExtractCat t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CatIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ExtractCat
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CatIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CatIdNo = s.CatIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_GeneralInterestRuleBaseType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_GeneralInterestRuleBaseType;
GO

CREATE FUNCTION dbo.if_GeneralInterestRuleBaseType(
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
	t.GeneralInterestRuleBaseTypeId,
	t.GeneralInterestRuleBaseTypeName
FROM src.GeneralInterestRuleBaseType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		GeneralInterestRuleBaseTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.GeneralInterestRuleBaseType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		GeneralInterestRuleBaseTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.GeneralInterestRuleBaseTypeId = s.GeneralInterestRuleBaseTypeId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_GeneralInterestRuleSetting', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_GeneralInterestRuleSetting;
GO

CREATE FUNCTION dbo.if_GeneralInterestRuleSetting(
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
	t.GeneralInterestRuleBaseTypeId
FROM src.GeneralInterestRuleSetting t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		GeneralInterestRuleBaseTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.GeneralInterestRuleSetting
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		GeneralInterestRuleBaseTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.GeneralInterestRuleBaseTypeId = s.GeneralInterestRuleBaseTypeId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Icd10DiagnosisVersion', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Icd10DiagnosisVersion;
GO

CREATE FUNCTION dbo.if_Icd10DiagnosisVersion(
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
	t.DiagnosisCode,
	t.StartDate,
	t.EndDate,
	t.NonSpecific,
	t.Traumatic,
	t.Duration,
	t.Description,
	t.DiagnosisFamilyId,
	t.TotalCharactersRequired,
	t.PlaceholderRequired
FROM src.Icd10DiagnosisVersion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Icd10DiagnosisVersion
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ICD10ProcedureCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ICD10ProcedureCode;
GO

CREATE FUNCTION dbo.if_ICD10ProcedureCode(
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
	t.ICDProcedureCode,
	t.StartDate,
	t.EndDate,
	t.Description,
	t.PASGrpNo
FROM src.ICD10ProcedureCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ICDProcedureCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ICD10ProcedureCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ICDProcedureCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ICDProcedureCode = s.ICDProcedureCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_IcdDiagnosisCodeDictionary', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_IcdDiagnosisCodeDictionary;
GO

CREATE FUNCTION dbo.if_IcdDiagnosisCodeDictionary(
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
	t.DiagnosisCode,
	t.IcdVersion,
	t.StartDate,
	t.EndDate,
	t.NonSpecific,
	t.Traumatic,
	t.Duration,
	t.Description,
	t.DiagnosisFamilyId,
	t.DiagnosisSeverityId,
	t.LateralityId,
	t.TotalCharactersRequired,
	t.PlaceholderRequired,
	t.Flags,
	t.AdditionalDigits,
	t.Colossus,
	t.InjuryNatureId,
	t.EncounterSubcategoryId
FROM src.IcdDiagnosisCodeDictionary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.IcdDiagnosisCodeDictionary
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.IcdVersion = s.IcdVersion
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_IcdDiagnosisCodeDictionaryBodyPart', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_IcdDiagnosisCodeDictionaryBodyPart;
GO

CREATE FUNCTION dbo.if_IcdDiagnosisCodeDictionaryBodyPart(
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
	t.DiagnosisCode,
	t.IcdVersion,
	t.StartDate,
	t.NcciBodyPartId
FROM src.IcdDiagnosisCodeDictionaryBodyPart t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate,
		NcciBodyPartId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.IcdDiagnosisCodeDictionaryBodyPart
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate,
		NcciBodyPartId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.IcdVersion = s.IcdVersion
	AND t.StartDate = s.StartDate
	AND t.NcciBodyPartId = s.NcciBodyPartId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_InjuryNature', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_InjuryNature;
GO

CREATE FUNCTION dbo.if_InjuryNature(
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
	t.InjuryNatureId,
	t.InjuryNaturePriority,
	t.Description,
	t.NarrativeInformation
FROM src.InjuryNature t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		InjuryNatureId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.InjuryNature
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		InjuryNatureId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.InjuryNatureId = s.InjuryNatureId
WHERE t.DmlOperation <> 'D';

GO


 
IF OBJECT_ID('dbo.if_lkp_SPC', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_lkp_SPC;
GO

CREATE FUNCTION dbo.if_lkp_SPC(
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
	t.lkp_SpcId,
	t.LongName,
	t.ShortName,
	t.Mult,
	t.NCD92,
	t.NCD93,
	t.PlusFour,
	t.CbreSpecialtyCode
FROM src.lkp_SPC t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		lkp_SpcId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.lkp_SPC
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		lkp_SpcId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.lkp_SpcId = s.lkp_SpcId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_lkp_TS', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_lkp_TS;
GO

CREATE FUNCTION dbo.if_lkp_TS(
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
	t.ShortName,
	t.StartDate,
	t.EndDate,
	t.LongName,
	t.Global,
	t.AnesMedDirect,
	t.AffectsPricing,
	t.IsAssistantSurgery,
	t.IsCoSurgeon
FROM src.lkp_TS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ShortName,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.lkp_TS
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ShortName,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ShortName = s.ShortName
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_MedicalCodeCutOffs', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicalCodeCutOffs;
GO

CREATE FUNCTION dbo.if_MedicalCodeCutOffs(
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
	t.CodeTypeID,
	t.CodeType,
	t.Code,
	t.FormType,
	t.MaxChargedPerUnit,
	t.MaxUnitsPerEncounter
FROM src.MedicalCodeCutOffs t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CodeTypeID,
		Code,
		FormType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicalCodeCutOffs
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CodeTypeID,
		Code,
		FormType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CodeTypeID = s.CodeTypeID
	AND t.Code = s.Code
	AND t.FormType = s.FormType
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_MedicareStatusIndicatorRule', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicareStatusIndicatorRule;
GO

CREATE FUNCTION dbo.if_MedicareStatusIndicatorRule(
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
	t.MedicareStatusIndicatorRuleId,
	t.MedicareStatusIndicatorRuleName,
	t.StatusIndicator,
	t.StartDate,
	t.EndDate,
	t.Endnote,
	t.EditActionId,
	t.Comments
FROM src.MedicareStatusIndicatorRule t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRule
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_MedicareStatusIndicatorRuleCoverageType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicareStatusIndicatorRuleCoverageType;
GO

CREATE FUNCTION dbo.if_MedicareStatusIndicatorRuleCoverageType(
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
	t.MedicareStatusIndicatorRuleId,
	t.ShortName
FROM src.MedicareStatusIndicatorRuleCoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ShortName,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRuleCoverageType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ShortName) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
	AND t.ShortName = s.ShortName
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_MedicareStatusIndicatorRulePlaceOfService', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicareStatusIndicatorRulePlaceOfService;
GO

CREATE FUNCTION dbo.if_MedicareStatusIndicatorRulePlaceOfService(
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
	t.MedicareStatusIndicatorRuleId,
	t.PlaceOfService
FROM src.MedicareStatusIndicatorRulePlaceOfService t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		PlaceOfService,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRulePlaceOfService
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		PlaceOfService) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
	AND t.PlaceOfService = s.PlaceOfService
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_MedicareStatusIndicatorRuleProcedureCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicareStatusIndicatorRuleProcedureCode;
GO

CREATE FUNCTION dbo.if_MedicareStatusIndicatorRuleProcedureCode(
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
	t.MedicareStatusIndicatorRuleId,
	t.ProcedureCode
FROM src.MedicareStatusIndicatorRuleProcedureCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProcedureCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRuleProcedureCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProcedureCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
	AND t.ProcedureCode = s.ProcedureCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_MedicareStatusIndicatorRuleProviderSpecialty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_MedicareStatusIndicatorRuleProviderSpecialty;
GO

CREATE FUNCTION dbo.if_MedicareStatusIndicatorRuleProviderSpecialty(
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
	t.MedicareStatusIndicatorRuleId,
	t.ProviderSpecialty
FROM src.MedicareStatusIndicatorRuleProviderSpecialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProviderSpecialty,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRuleProviderSpecialty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		ProviderSpecialty) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
	AND t.ProviderSpecialty = s.ProviderSpecialty
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ModifierByState', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ModifierByState;
GO

CREATE FUNCTION dbo.if_ModifierByState(
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
	t.State,
	t.ProcedureServiceCategoryId,
	t.ModifierDictionaryId
FROM src.ModifierByState t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		State,
		ProcedureServiceCategoryId,
		ModifierDictionaryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ModifierByState
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		State,
		ProcedureServiceCategoryId,
		ModifierDictionaryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.State = s.State
	AND t.ProcedureServiceCategoryId = s.ProcedureServiceCategoryId
	AND t.ModifierDictionaryId = s.ModifierDictionaryId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ModifierDictionary', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ModifierDictionary;
GO

CREATE FUNCTION dbo.if_ModifierDictionary(
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
	t.ModifierDictionaryId,
	t.Modifier,
	t.StartDate,
	t.EndDate,
	t.Description,
	t.Global,
	t.AnesMedDirect,
	t.AffectsPricing,
	t.IsCoSurgeon,
	t.IsAssistantSurgery
FROM src.ModifierDictionary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ModifierDictionaryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ModifierDictionary
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ModifierDictionaryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ModifierDictionaryId = s.ModifierDictionaryId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ModifierToProcedureCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ModifierToProcedureCode;
GO

CREATE FUNCTION dbo.if_ModifierToProcedureCode(
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
	t.ProcedureCode,
	t.Modifier,
	t.StartDate,
	t.EndDate,
	t.SojFlag,
	t.RequiresGuidelineReview,
	t.Reference,
	t.Comments
FROM src.ModifierToProcedureCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProcedureCode,
		Modifier,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ModifierToProcedureCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProcedureCode,
		Modifier,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProcedureCode = s.ProcedureCode
	AND t.Modifier = s.Modifier
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_NcciBodyPart', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_NcciBodyPart;
GO

CREATE FUNCTION dbo.if_NcciBodyPart(
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
	t.NcciBodyPartId,
	t.Description,
	t.NarrativeInformation
FROM src.NcciBodyPart t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NcciBodyPartId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.NcciBodyPart
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NcciBodyPartId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NcciBodyPartId = s.NcciBodyPartId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_NcciBodyPartToHybridBodyPartTranslation', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_NcciBodyPartToHybridBodyPartTranslation;
GO

CREATE FUNCTION dbo.if_NcciBodyPartToHybridBodyPartTranslation(
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
	t.NcciBodyPartId,
	t.HybridBodyPartId
FROM src.NcciBodyPartToHybridBodyPartTranslation t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NcciBodyPartId,
		HybridBodyPartId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.NcciBodyPartToHybridBodyPartTranslation
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NcciBodyPartId,
		HybridBodyPartId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NcciBodyPartId = s.NcciBodyPartId
	AND t.HybridBodyPartId = s.HybridBodyPartId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ny_pharmacy', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ny_pharmacy;
GO

CREATE FUNCTION dbo.if_ny_pharmacy(
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
	t.NDCCode,
	t.StartDate,
	t.EndDate,
	t.Description,
	t.Fee,
	t.TypeOfDrug
FROM src.ny_pharmacy t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NDCCode,
		StartDate,
		TypeOfDrug,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ny_pharmacy
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NDCCode,
		StartDate,
		TypeOfDrug) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NDCCode = s.NDCCode
	AND t.StartDate = s.StartDate
	AND t.TypeOfDrug = s.TypeOfDrug
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ny_specialty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ny_specialty;
GO

CREATE FUNCTION dbo.if_ny_specialty(
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
	t.RatingCode,
	t.Desc_,
	t.CbreSpecialtyCode
FROM src.ny_specialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RatingCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ny_specialty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RatingCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RatingCode = s.RatingCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_pa_PlaceOfService', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_pa_PlaceOfService;
GO

CREATE FUNCTION dbo.if_pa_PlaceOfService(
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
	t.POS,
	t.Description,
	t.Facility,
	t.MHL,
	t.PlusFour,
	t.Institution
FROM src.pa_PlaceOfService t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		POS,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.pa_PlaceOfService
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		POS) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.POS = s.POS
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_PlaceOfServiceDictionary', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PlaceOfServiceDictionary;
GO

CREATE FUNCTION dbo.if_PlaceOfServiceDictionary(
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
	t.PlaceOfServiceCode,
	t.Description,
	t.Facility,
	t.MHL,
	t.PlusFour,
	t.Institution,
	t.StartDate,
	t.EndDate
FROM src.PlaceOfServiceDictionary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PlaceOfServiceCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PlaceOfServiceDictionary
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PlaceOfServiceCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PlaceOfServiceCode = s.PlaceOfServiceCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_PrePpoBillInfo', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PrePpoBillInfo;
GO

CREATE FUNCTION dbo.if_PrePpoBillInfo(
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
	t.DateSentToPPO,
	t.ClaimNo,
	t.ClaimIDNo,
	t.CompanyID,
	t.OfficeIndex,
	t.CV_Code,
	t.DateLoss,
	t.Deductible,
	t.PaidCoPay,
	t.PaidDeductible,
	t.LossState,
	t.CmtIDNo,
	t.CmtCoPaymentMax,
	t.CmtCoPaymentPercentage,
	t.CmtDedType,
	t.CmtDeductible,
	t.CmtFLCopay,
	t.CmtPolicyLimit,
	t.CmtStateOfJurisdiction,
	t.PvdIDNo,
	t.PvdTIN,
	t.PvdSPC_List,
	t.PvdTitle,
	t.PvdFlags,
	t.DateSaved,
	t.DateRcv,
	t.InvoiceDate,
	t.NoLines,
	t.AmtCharged,
	t.AmtAllowed,
	t.Region,
	t.FeatureID,
	t.Flags,
	t.WhoCreate,
	t.WhoLast,
	t.CmtPaidDeductible,
	t.InsPaidLimit,
	t.StatusFlag,
	t.CmtPaidCoPay,
	t.Category,
	t.CatDesc,
	t.CreateDate,
	t.PvdZOS,
	t.AdmissionDate,
	t.DischargeDate,
	t.DischargeStatus,
	t.TypeOfBill,
	t.PaymentDecision,
	t.PPONumberSent,
	t.BillIDNo,
	t.LINE_NO,
	t.LINE_NO_DISP,
	t.OVER_RIDE,
	t.DT_SVC,
	t.PRC_CD,
	t.UNITS,
	t.TS_CD,
	t.CHARGED,
	t.ALLOWED,
	t.ANALYZED,
	t.REF_LINE_NO,
	t.SUBNET,
	t.FEE_SCHEDULE,
	t.POS_RevCode,
	t.CTGPenalty,
	t.PrePPOAllowed,
	t.PPODate,
	t.PPOCTGPenalty,
	t.UCRPerUnit,
	t.FSPerUnit,
	t.HCRA_Surcharge,
	t.NDC,
	t.PriceTypeCode,
	t.PharmacyLine,
	t.Endnotes,
	t.SentryEN,
	t.CTGEN,
	t.CTGRuleType,
	t.CTGRuleID,
	t.OverrideEN,
	t.UserId,
	t.DateOverriden,
	t.AmountBeforeOverride,
	t.AmountAfterOverride,
	t.CodesOverriden,
	t.NetworkID,
	t.BillSnapshot,
	t.PPOSavings,
	t.RevisedDate,
	t.ReconsideredDate,
	t.TierNumber,
	t.PPOBillInfoID,
	t.PrePPOBillInfoID,
	t.CtgCoPayPenalty,
	t.PpoCtgCoPayPenaltyPercentage,
	t.CtgVunPenalty,
	t.PpoCtgVunPenaltyPercentage
FROM src.PrePpoBillInfo t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PrePPOBillInfoID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PrePpoBillInfo
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PrePPOBillInfoID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PrePPOBillInfoID = s.PrePPOBillInfoID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_prf_COMPANY', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_COMPANY;
GO

CREATE FUNCTION dbo.if_prf_COMPANY(
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
	t.CompanyId,
	t.CompanyName,
	t.LastChangedOn
FROM src.prf_COMPANY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CompanyId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_COMPANY
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CompanyId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CompanyId = s.CompanyId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_prf_CTGMaxPenaltyLines', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_CTGMaxPenaltyLines;
GO

CREATE FUNCTION dbo.if_prf_CTGMaxPenaltyLines(
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
	t.CTGMaxPenLineID,
	t.ProfileId,
	t.DatesBasedOn,
	t.MaxPenaltyPercent,
	t.StartDate,
	t.EndDate
FROM src.prf_CTGMaxPenaltyLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGMaxPenLineID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGMaxPenaltyLines
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGMaxPenLineID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGMaxPenLineID = s.CTGMaxPenLineID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_prf_CTGPenalty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_CTGPenalty;
GO

CREATE FUNCTION dbo.if_prf_CTGPenalty(
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
	t.CTGPenID,
	t.ProfileId,
	t.ApplyPreCerts,
	t.NoPrecertLogged,
	t.MaxTotalPenalty,
	t.TurnTimeForAppeals,
	t.ApplyEndnoteForPercert,
	t.ApplyEndnoteForCarePath,
	t.ExemptPrecertPenalty,
	t.ApplyNetworkPenalty
FROM src.prf_CTGPenalty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGPenID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGPenalty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGPenID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGPenID = s.CTGPenID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_prf_CTGPenaltyHdr', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_CTGPenaltyHdr;
GO

CREATE FUNCTION dbo.if_prf_CTGPenaltyHdr(
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
	t.CTGPenHdrID,
	t.ProfileId,
	t.PenaltyType,
	t.PayNegRate,
	t.PayPPORate,
	t.DatesBasedOn,
	t.ApplyPenaltyToPharmacy,
	t.ApplyPenaltyCondition
FROM src.prf_CTGPenaltyHdr t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGPenHdrID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGPenaltyHdr
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGPenHdrID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGPenHdrID = s.CTGPenHdrID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_prf_CTGPenaltyLines', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_CTGPenaltyLines;
GO

CREATE FUNCTION dbo.if_prf_CTGPenaltyLines(
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
	t.CTGPenLineID,
	t.ProfileId,
	t.PenaltyType,
	t.FeeSchedulePercent,
	t.StartDate,
	t.EndDate,
	t.TurnAroundTime
FROM src.prf_CTGPenaltyLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGPenLineID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGPenaltyLines
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGPenLineID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGPenLineID = s.CTGPenLineID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Prf_CustomIcdAction', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Prf_CustomIcdAction;
GO

CREATE FUNCTION dbo.if_Prf_CustomIcdAction(
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
	t.CustomIcdActionId,
	t.ProfileId,
	t.IcdVersionId,
	t.Action,
	t.StartDate,
	t.EndDate
FROM src.Prf_CustomIcdAction t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CustomIcdActionId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Prf_CustomIcdAction
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CustomIcdActionId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CustomIcdActionId = s.CustomIcdActionId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_prf_Office', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_Office;
GO

CREATE FUNCTION dbo.if_prf_Office(
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
	t.CompanyId,
	t.OfficeId,
	t.OfcNo,
	t.OfcName,
	t.OfcAddr1,
	t.OfcAddr2,
	t.OfcCity,
	t.OfcState,
	t.OfcZip,
	t.OfcPhone,
	t.OfcDefault,
	t.OfcClaimMask,
	t.OfcTinMask,
	t.Version,
	t.OfcEdits,
	t.OfcCOAEnabled,
	t.CTGEnabled,
	t.LastChangedOn,
	t.AllowMultiCoverage
FROM src.prf_Office t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OfficeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_Office
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OfficeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OfficeId = s.OfficeId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Prf_OfficeUDF', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Prf_OfficeUDF;
GO

CREATE FUNCTION dbo.if_Prf_OfficeUDF(
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
	t.OfficeId,
	t.UDFIdNo
FROM src.Prf_OfficeUDF t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OfficeId,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Prf_OfficeUDF
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OfficeId,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OfficeId = s.OfficeId
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_prf_PPO', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_PPO;
GO

CREATE FUNCTION dbo.if_prf_PPO(
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
	t.PPOSysId,
	t.ProfileId,
	t.PPOId,
	t.bStatus,
	t.StartDate,
	t.EndDate,
	t.AutoSend,
	t.AutoResend,
	t.BypassMatching,
	t.UseProviderNetworkEnrollment,
	t.TieredTypeId,
	t.Priority,
	t.PolicyEffectiveDate,
	t.BillFormType
FROM src.prf_PPO t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPOSysId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_PPO
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPOSysId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPOSysId = s.PPOSysId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_prf_Profile', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_Profile;
GO

CREATE FUNCTION dbo.if_prf_Profile(
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
	t.ProfileId,
	t.OfficeId,
	t.CoverageId,
	t.StateId,
	t.AnHeader,
	t.AnFooter,
	t.ExHeader,
	t.ExFooter,
	t.AnalystEdits,
	t.DxEdits,
	t.DxNonTraumaDays,
	t.DxNonSpecDays,
	t.PrintCopies,
	t.NewPvdState,
	t.bDuration,
	t.bLimits,
	t.iDurPct,
	t.iLimitPct,
	t.PolicyLimit,
	t.CoPayPercent,
	t.CoPayMax,
	t.Deductible,
	t.PolicyWarn,
	t.PolicyWarnPerc,
	t.FeeSchedules,
	t.DefaultProfile,
	t.FeeAncillaryPct,
	t.iGapdol,
	t.iGapTreatmnt,
	t.bGapTreatmnt,
	t.bGapdol,
	t.bPrintAdjustor,
	t.sPrinterName,
	t.ErEdits,
	t.ErAllowedDays,
	t.UcrFsRules,
	t.LogoIdNo,
	t.LogoJustify,
	t.BillLine,
	t.Version,
	t.ClaimDeductible,
	t.IncludeCommitted,
	t.FLMedicarePercent,
	t.UseLevelOfServiceUrl,
	t.LevelOfServiceURL,
	t.CCIPrimary,
	t.CCISecondary,
	t.CCIMutuallyExclusive,
	t.CCIComprehensiveComponent,
	t.PayDRGAllowance,
	t.FLHospEmPriceOn,
	t.EnableBillRelease,
	t.DisableSubmitBill,
	t.MaxPaymentsPerBill,
	t.NoOfPmtPerBill,
	t.DefaultDueDate,
	t.CheckForNJCarePaths,
	t.NJCarePathPercentFS,
	t.ApplyEndnoteForNJCarePaths,
	t.FLMedicarePercent2008,
	t.RequireEndnoteDuringOverride,
	t.StorePerUnitFSandUCR,
	t.UseProviderNetworkEnrollment,
	t.UseASCRule,
	t.AsstCoSurgeonEligible,
	t.LastChangedOn,
	t.IsNJPhysMedCapAfterCTG,
	t.IsEligibleAmtFeeBased,
	t.HideClaimTreeTotalsGrid,
	t.SortBillsBy,
	t.SortBillsByOrder,
	t.ApplyNJEmergencyRoomBenchmarkFee,
	t.AllowIcd10ForNJCarePaths,
	t.EnableOverrideDeductible,
	t.AnalyzeDiagnosisPointers,
	t.MedicareFeePercent,
	t.EnableSupplementalNdcData,
	t.ApplyOriginalNdcAwp,
	t.NdcAwpNotAvailable,
	t.PayEapgAllowance,
	t.MedicareInpatientApcEnabled,
	t.MedicareOutpatientAscEnabled,
	t.MedicareAscEnabled,
	t.UseMedicareInpatientApcFee,
	t.MedicareInpatientDrgEnabled,
	t.MedicareInpatientDrgPricingType,
	t.MedicarePhysicianEnabled,
	t.MedicareAmbulanceEnabled,
	t.MedicareDmeposEnabled,
	t.MedicareAspDrugAndClinicalEnabled,
	t.MedicareInpatientPricingType,
	t.MedicareOutpatientPricingRulesEnabled,
	t.MedicareAscPricingRulesEnabled,
	t.NjUseAdmitTypeEnabled,
	t.MedicareClinicalLabEnabled,
	t.MedicareInpatientEnabled,
	t.MedicareOutpatientApcEnabled,
	t.MedicareAspDrugEnabled,
	t.ShowAllocationsOnEob,
	t.EmergencyCarePricingRuleId,
	t.OutOfStatePricingEffectiveDateId,
	t.PreAllocation,
	t.AssistantCoSurgeonModifiers,
	t.AssistantSurgeryModifierNotMedicallyNecessary,
	t.AssistantSurgeryModifierRequireAdditionalDocument,
	t.CoSurgeryModifierNotMedicallyNecessary,
	t.CoSurgeryModifierRequireAdditionalDocument,
	t.DxNoDiagnosisDays,
	t.ModifierExempted
FROM src.prf_Profile t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProfileId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_Profile
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProfileId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProfileId = s.ProfileId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProcedureCodeGroup', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProcedureCodeGroup;
GO

CREATE FUNCTION dbo.if_ProcedureCodeGroup(
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
	t.ProcedureCode,
	t.MajorCategory,
	t.MinorCategory
FROM src.ProcedureCodeGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProcedureCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProcedureCodeGroup
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProcedureCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProcedureCode = s.ProcedureCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProcedureServiceCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProcedureServiceCategory;
GO

CREATE FUNCTION dbo.if_ProcedureServiceCategory(
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
	t.ProcedureServiceCategoryId,
	t.ProcedureServiceCategoryName,
	t.ProcedureServiceCategoryDescription,
	t.LegacyTableName,
	t.LegacyBitValue
FROM src.ProcedureServiceCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProcedureServiceCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProcedureServiceCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProcedureServiceCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProcedureServiceCategoryId = s.ProcedureServiceCategoryId
WHERE t.DmlOperation <> 'D';

GO


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


IF OBJECT_ID('dbo.if_ProviderCluster', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderCluster;
GO

CREATE FUNCTION dbo.if_ProviderCluster(
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
	t.OrgOdsCustomerId,
	t.MitchellProviderKey,
	t.ProviderClusterKey,
	t.ProviderType
FROM src.ProviderCluster t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIDNo,
		OrgOdsCustomerId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderCluster
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIDNo,
		OrgOdsCustomerId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIDNo = s.PvdIDNo
	AND t.OrgOdsCustomerId = s.OrgOdsCustomerId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProviderNetworkEventLog', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderNetworkEventLog;
GO

CREATE FUNCTION dbo.if_ProviderNetworkEventLog(
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
	t.IDField,
	t.LogDate,
	t.EventId,
	t.ClaimIdNo,
	t.BillIdNo,
	t.UserId,
	t.NetworkId,
	t.FileName,
	t.ExtraText,
	t.ProcessInfo,
	t.TieredTypeID,
	t.TierNumber
FROM src.ProviderNetworkEventLog t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		IDField,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNetworkEventLog
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		IDField) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.IDField = s.IDField
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProviderNumberCriteria', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderNumberCriteria;
GO

CREATE FUNCTION dbo.if_ProviderNumberCriteria(
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
	t.ProviderNumberCriteriaId,
	t.ProviderNumber,
	t.Priority,
	t.FeeScheduleTable,
	t.StartDate,
	t.EndDate
FROM src.ProviderNumberCriteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderNumberCriteriaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNumberCriteria
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderNumberCriteriaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderNumberCriteriaId = s.ProviderNumberCriteriaId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProviderNumberCriteriaRevenueCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderNumberCriteriaRevenueCode;
GO

CREATE FUNCTION dbo.if_ProviderNumberCriteriaRevenueCode(
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
	t.ProviderNumberCriteriaId,
	t.RevenueCode,
	t.MatchingProfileNumber,
	t.AttributeMatchTypeId
FROM src.ProviderNumberCriteriaRevenueCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderNumberCriteriaId,
		RevenueCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNumberCriteriaRevenueCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderNumberCriteriaId,
		RevenueCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderNumberCriteriaId = s.ProviderNumberCriteriaId
	AND t.RevenueCode = s.RevenueCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProviderNumberCriteriaTypeOfBill', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderNumberCriteriaTypeOfBill;
GO

CREATE FUNCTION dbo.if_ProviderNumberCriteriaTypeOfBill(
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
	t.ProviderNumberCriteriaId,
	t.TypeOfBill,
	t.MatchingProfileNumber,
	t.AttributeMatchTypeId
FROM src.ProviderNumberCriteriaTypeOfBill t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderNumberCriteriaId,
		TypeOfBill,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNumberCriteriaTypeOfBill
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderNumberCriteriaId,
		TypeOfBill) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderNumberCriteriaId = s.ProviderNumberCriteriaId
	AND t.TypeOfBill = s.TypeOfBill
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProviderSpecialty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderSpecialty;
GO

CREATE FUNCTION dbo.if_ProviderSpecialty(
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
	t.ProviderId,
	t.SpecialtyCode
FROM src.ProviderSpecialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderId,
		SpecialtyCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderSpecialty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderId,
		SpecialtyCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderId = s.ProviderId
	AND t.SpecialtyCode = s.SpecialtyCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ProviderSpecialtyToProvType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ProviderSpecialtyToProvType;
GO

CREATE FUNCTION dbo.if_ProviderSpecialtyToProvType(
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
	t.ProviderType,
	t.ProviderType_Desc,
	t.Specialty,
	t.Specialty_Desc,
	t.CreateDate,
	t.ModifyDate,
	t.LogicalDelete
FROM src.ProviderSpecialtyToProvType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderType,
		Specialty,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderSpecialtyToProvType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderType,
		Specialty) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderType = s.ProviderType
	AND t.Specialty = s.Specialty
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Provider_ClientRef', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Provider_ClientRef;
GO

CREATE FUNCTION dbo.if_Provider_ClientRef(
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
	t.PvdIdNo,
	t.ClientRefId,
	t.ClientRefId2
FROM src.Provider_ClientRef t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Provider_ClientRef
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIdNo = s.PvdIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Provider_Rendering', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Provider_Rendering;
GO

CREATE FUNCTION dbo.if_Provider_Rendering(
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
	t.RenderingAddr1,
	t.RenderingAddr2,
	t.RenderingCity,
	t.RenderingState,
	t.RenderingZip
FROM src.Provider_Rendering t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Provider_Rendering
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIDNo = s.PvdIDNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ReferenceBillApcLines', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ReferenceBillApcLines;
GO

CREATE FUNCTION dbo.if_ReferenceBillApcLines(
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
	t.BillIdNo,
	t.Line_No,
	t.PaymentAPC,
	t.ServiceIndicator,
	t.PaymentIndicator,
	t.OutlierAmount,
	t.PricerAllowed,
	t.MedicareAmount
FROM src.ReferenceBillApcLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Line_No,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ReferenceBillApcLines
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Line_No) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Line_No = s.Line_No
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ReferenceSupplementBillApcLines', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ReferenceSupplementBillApcLines;
GO

CREATE FUNCTION dbo.if_ReferenceSupplementBillApcLines(
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
	t.BillIdNo,
	t.SeqNo,
	t.Line_No,
	t.PaymentAPC,
	t.ServiceIndicator,
	t.PaymentIndicator,
	t.OutlierAmount,
	t.PricerAllowed,
	t.MedicareAmount
FROM src.ReferenceSupplementBillApcLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		SeqNo,
		Line_No,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ReferenceSupplementBillApcLines
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		SeqNo,
		Line_No) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.SeqNo = s.SeqNo
	AND t.Line_No = s.Line_No
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_RenderingNpiStates', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_RenderingNpiStates;
GO

CREATE FUNCTION dbo.if_RenderingNpiStates(
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
	t.ApplicationSettingsId,
	t.State
FROM src.RenderingNpiStates t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ApplicationSettingsId,
		State,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RenderingNpiStates
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ApplicationSettingsId,
		State) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ApplicationSettingsId = s.ApplicationSettingsId
	AND t.State = s.State
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_RevenueCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_RevenueCode;
GO

CREATE FUNCTION dbo.if_RevenueCode(
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
	t.RevenueCode,
	t.RevenueCodeSubCategoryId
FROM src.RevenueCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RevenueCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCode = s.RevenueCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_RevenueCodeCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_RevenueCodeCategory;
GO

CREATE FUNCTION dbo.if_RevenueCodeCategory(
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
	t.RevenueCodeCategoryId,
	t.Description,
	t.NarrativeInformation
FROM src.RevenueCodeCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCodeCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RevenueCodeCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCodeCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCodeCategoryId = s.RevenueCodeCategoryId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_RevenueCodeSubCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_RevenueCodeSubCategory;
GO

CREATE FUNCTION dbo.if_RevenueCodeSubCategory(
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
	t.RevenueCodeSubcategoryId,
	t.RevenueCodeCategoryId,
	t.Description,
	t.NarrativeInformation
FROM src.RevenueCodeSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCodeSubcategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RevenueCodeSubCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCodeSubcategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCodeSubcategoryId = s.RevenueCodeSubcategoryId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_RPT_RsnCategories', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_RPT_RsnCategories;
GO

CREATE FUNCTION dbo.if_RPT_RsnCategories(
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
	t.CategoryIdNo,
	t.CatDesc,
	t.Priority
FROM src.RPT_RsnCategories t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CategoryIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RPT_RsnCategories
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CategoryIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CategoryIdNo = s.CategoryIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Rsn_Override', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Rsn_Override;
GO

CREATE FUNCTION dbo.if_Rsn_Override(
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
	t.ReasonNumber,
	t.ShortDesc,
	t.LongDesc,
	t.CategoryIdNo,
	t.ClientSpec,
	t.COAIndex,
	t.NJPenaltyPct,
	t.NetworkID,
	t.SpecialProcessing
FROM src.Rsn_Override t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Rsn_Override
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_rsn_REASONS', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_rsn_REASONS;
GO

CREATE FUNCTION dbo.if_rsn_REASONS(
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
	t.ReasonNumber,
	t.CV_Type,
	t.ShortDesc,
	t.LongDesc,
	t.CategoryIdNo,
	t.COAIndex,
	t.OverrideEndnote,
	t.HardEdit,
	t.SpecialProcessing,
	t.EndnoteActionId,
	t.RetainForEapg
FROM src.rsn_REASONS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.rsn_REASONS
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Rsn_Reasons_3rdParty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Rsn_Reasons_3rdParty;
GO

CREATE FUNCTION dbo.if_Rsn_Reasons_3rdParty(
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
	t.ReasonNumber,
	t.ShortDesc,
	t.LongDesc
FROM src.Rsn_Reasons_3rdParty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Rsn_Reasons_3rdParty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_RuleType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_RuleType;
GO

CREATE FUNCTION dbo.if_RuleType(
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
	t.RuleTypeID,
	t.Name,
	t.Description
FROM src.RuleType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleTypeID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RuleType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleTypeID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleTypeID = s.RuleTypeID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ScriptAdvisorBillSource', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ScriptAdvisorBillSource;
GO

CREATE FUNCTION dbo.if_ScriptAdvisorBillSource(
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
	t.BillSourceId,
	t.BillSource
FROM src.ScriptAdvisorBillSource t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillSourceId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ScriptAdvisorBillSource
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillSourceId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillSourceId = s.BillSourceId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ScriptAdvisorSettings', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ScriptAdvisorSettings;
GO

CREATE FUNCTION dbo.if_ScriptAdvisorSettings(
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
	t.ScriptAdvisorSettingsId,
	t.IsPharmacyEligible,
	t.EnableSendCardToClaimant,
	t.EnableBillSource
FROM src.ScriptAdvisorSettings t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ScriptAdvisorSettingsId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ScriptAdvisorSettings
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ScriptAdvisorSettingsId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ScriptAdvisorSettingsId = s.ScriptAdvisorSettingsId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ScriptAdvisorSettingsCoverageType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ScriptAdvisorSettingsCoverageType;
GO

CREATE FUNCTION dbo.if_ScriptAdvisorSettingsCoverageType(
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
	t.ScriptAdvisorSettingsId,
	t.CoverageType
FROM src.ScriptAdvisorSettingsCoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ScriptAdvisorSettingsId,
		CoverageType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ScriptAdvisorSettingsCoverageType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ScriptAdvisorSettingsId,
		CoverageType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ScriptAdvisorSettingsId = s.ScriptAdvisorSettingsId
	AND t.CoverageType = s.CoverageType
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SEC_RightGroups', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SEC_RightGroups;
GO

CREATE FUNCTION dbo.if_SEC_RightGroups(
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
	t.RightGroupId,
	t.RightGroupName,
	t.RightGroupDescription,
	t.CreatedDate,
	t.CreatedBy
FROM src.SEC_RightGroups t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RightGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_RightGroups
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RightGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RightGroupId = s.RightGroupId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SEC_Users', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SEC_Users;
GO

CREATE FUNCTION dbo.if_SEC_Users(
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
	t.UserId,
	t.LoginName,
	t.Password,
	t.CreatedBy,
	t.CreatedDate,
	t.UserStatus,
	t.FirstName,
	t.LastName,
	t.AccountLocked,
	t.LockedCounter,
	t.PasswordCreateDate,
	t.PasswordCaseFlag,
	t.ePassword,
	t.CurrentSettings
FROM src.SEC_Users t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UserId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_Users
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UserId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UserId = s.UserId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SEC_User_OfficeGroups', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SEC_User_OfficeGroups;
GO

CREATE FUNCTION dbo.if_SEC_User_OfficeGroups(
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
	t.SECUserOfficeGroupId,
	t.UserId,
	t.OffcGroupId
FROM src.SEC_User_OfficeGroups t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SECUserOfficeGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_User_OfficeGroups
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SECUserOfficeGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SECUserOfficeGroupId = s.SECUserOfficeGroupId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SEC_User_RightGroups', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SEC_User_RightGroups;
GO

CREATE FUNCTION dbo.if_SEC_User_RightGroups(
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
	t.SECUserRightGroupId,
	t.UserId,
	t.RightGroupId
FROM src.SEC_User_RightGroups t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SECUserRightGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_User_RightGroups
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SECUserRightGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SECUserRightGroupId = s.SECUserRightGroupId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SentryRuleTypeCriteria', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SentryRuleTypeCriteria;
GO

CREATE FUNCTION dbo.if_SentryRuleTypeCriteria(
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
	t.RuleTypeId,
	t.CriteriaId
FROM src.SentryRuleTypeCriteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleTypeId,
		CriteriaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SentryRuleTypeCriteria
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleTypeId,
		CriteriaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleTypeId = s.RuleTypeId
	AND t.CriteriaId = s.CriteriaId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SENTRY_ACTION', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_ACTION;
GO

CREATE FUNCTION dbo.if_SENTRY_ACTION(
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
	t.ActionID,
	t.Name,
	t.Description,
	t.CompatibilityKey,
	t.PredefinedValues,
	t.ValueDataType,
	t.ValueFormat,
	t.BillLineAction,
	t.AnalyzeFlag,
	t.ActionCategoryIDNo
FROM src.SENTRY_ACTION t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ActionID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_ACTION
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ActionID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ActionID = s.ActionID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SENTRY_ACTION_CATEGORY', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_ACTION_CATEGORY;
GO

CREATE FUNCTION dbo.if_SENTRY_ACTION_CATEGORY(
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
	t.ActionCategoryIDNo,
	t.Description
FROM src.SENTRY_ACTION_CATEGORY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ActionCategoryIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_ACTION_CATEGORY
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ActionCategoryIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ActionCategoryIDNo = s.ActionCategoryIDNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SENTRY_CRITERIA', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_CRITERIA;
GO

CREATE FUNCTION dbo.if_SENTRY_CRITERIA(
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
	t.CriteriaID,
	t.ParentName,
	t.Name,
	t.Description,
	t.Operators,
	t.PredefinedValues,
	t.ValueDataType,
	t.ValueFormat,
	t.NullAllowed
FROM src.SENTRY_CRITERIA t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CriteriaID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_CRITERIA
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CriteriaID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CriteriaID = s.CriteriaID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SENTRY_PROFILE_RULE', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_PROFILE_RULE;
GO

CREATE FUNCTION dbo.if_SENTRY_PROFILE_RULE(
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
	t.ProfileID,
	t.RuleID,
	t.Priority
FROM src.SENTRY_PROFILE_RULE t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProfileID,
		RuleID,
		Priority,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_PROFILE_RULE
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProfileID,
		RuleID,
		Priority) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProfileID = s.ProfileID
	AND t.RuleID = s.RuleID
	AND t.Priority = s.Priority
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SENTRY_RULE', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_RULE;
GO

CREATE FUNCTION dbo.if_SENTRY_RULE(
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
	t.RuleID,
	t.Name,
	t.Description,
	t.CreatedBy,
	t.CreationDate,
	t.PostFixNotation,
	t.Priority,
	t.RuleTypeID
FROM src.SENTRY_RULE t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_RULE
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleID = s.RuleID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SENTRY_RULE_ACTION_DETAIL', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_RULE_ACTION_DETAIL;
GO

CREATE FUNCTION dbo.if_SENTRY_RULE_ACTION_DETAIL(
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
	t.RuleID,
	t.LineNumber,
	t.ActionID,
	t.ActionValue
FROM src.SENTRY_RULE_ACTION_DETAIL t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleID,
		LineNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_RULE_ACTION_DETAIL
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleID,
		LineNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleID = s.RuleID
	AND t.LineNumber = s.LineNumber
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SENTRY_RULE_ACTION_HEADER', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_RULE_ACTION_HEADER;
GO

CREATE FUNCTION dbo.if_SENTRY_RULE_ACTION_HEADER(
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
	t.RuleID,
	t.EndnoteShort,
	t.EndnoteLong
FROM src.SENTRY_RULE_ACTION_HEADER t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_RULE_ACTION_HEADER
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleID = s.RuleID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SENTRY_RULE_CONDITION', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SENTRY_RULE_CONDITION;
GO

CREATE FUNCTION dbo.if_SENTRY_RULE_CONDITION(
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
	t.RuleID,
	t.LineNumber,
	t.GroupFlag,
	t.CriteriaID,
	t.Operator,
	t.ConditionValue,
	t.AndOr,
	t.UdfConditionId
FROM src.SENTRY_RULE_CONDITION t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleID,
		LineNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_RULE_CONDITION
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleID,
		LineNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleID = s.RuleID
	AND t.LineNumber = s.LineNumber
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SPECIALTY', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SPECIALTY;
GO

CREATE FUNCTION dbo.if_SPECIALTY(
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
	t.SpcIdNo,
	t.Code,
	t.Description,
	t.PayeeSubTypeID,
	t.TieredTypeID
FROM src.SPECIALTY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Code,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SPECIALTY
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Code) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Code = s.Code
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_StateSettingMedicare', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingMedicare;
GO

CREATE FUNCTION dbo.if_StateSettingMedicare(
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
	t.StateSettingMedicareId,
	t.PayPercentOfMedicareFee
FROM src.StateSettingMedicare t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingMedicareId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingMedicare
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingMedicareId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingMedicareId = s.StateSettingMedicareId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_StateSettingsFlorida', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsFlorida;
GO

CREATE FUNCTION dbo.if_StateSettingsFlorida(
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
	t.StateSettingsFloridaId,
	t.ClaimantInitialServiceOption,
	t.ClaimantInitialServiceDays
FROM src.StateSettingsFlorida t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsFloridaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsFlorida
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsFloridaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsFloridaId = s.StateSettingsFloridaId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_StateSettingsHawaii', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsHawaii;
GO

CREATE FUNCTION dbo.if_StateSettingsHawaii(
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
	t.StateSettingsHawaiiId,
	t.PhysicalMedicineLimitOption
FROM src.StateSettingsHawaii t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsHawaiiId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsHawaii
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsHawaiiId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsHawaiiId = s.StateSettingsHawaiiId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_StateSettingsNewJersey', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsNewJersey;
GO

CREATE FUNCTION dbo.if_StateSettingsNewJersey(
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
	t.StateSettingsNewJerseyId,
	t.ByPassEmergencyServices
FROM src.StateSettingsNewJersey t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsNewJerseyId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNewJersey
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsNewJerseyId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsNewJerseyId = s.StateSettingsNewJerseyId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_StateSettingsNewJerseyPolicyPreference', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsNewJerseyPolicyPreference;
GO

CREATE FUNCTION dbo.if_StateSettingsNewJerseyPolicyPreference(
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
	t.PolicyPreferenceId,
	t.ShareCoPayMaximum
FROM src.StateSettingsNewJerseyPolicyPreference t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PolicyPreferenceId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNewJerseyPolicyPreference
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PolicyPreferenceId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PolicyPreferenceId = s.PolicyPreferenceId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_StateSettingsNewYorkPolicyPreference', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsNewYorkPolicyPreference;
GO

CREATE FUNCTION dbo.if_StateSettingsNewYorkPolicyPreference(
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
	t.PolicyPreferenceId,
	t.ShareCoPayMaximum
FROM src.StateSettingsNewYorkPolicyPreference t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PolicyPreferenceId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNewYorkPolicyPreference
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PolicyPreferenceId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PolicyPreferenceId = s.PolicyPreferenceId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_StateSettingsNY', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsNY;
GO

CREATE FUNCTION dbo.if_StateSettingsNY(
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
	t.StateSettingsNYID,
	t.NF10PrintDate,
	t.NF10CheckBox1,
	t.NF10CheckBox18,
	t.NF10UseUnderwritingCompany,
	t.UnderwritingCompanyUdfId,
	t.NaicUdfId,
	t.DisplayNYPrintOptionsWhenZosOrSojIsNY,
	t.NF10DuplicatePrint
FROM src.StateSettingsNY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsNYID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNY
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsNYID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsNYID = s.StateSettingsNYID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_StateSettingsNyRoomRate', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsNyRoomRate;
GO

CREATE FUNCTION dbo.if_StateSettingsNyRoomRate(
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
	t.StateSettingsNyRoomRateId,
	t.StartDate,
	t.EndDate,
	t.RoomRate
FROM src.StateSettingsNyRoomRate t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsNyRoomRateId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNyRoomRate
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsNyRoomRateId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsNyRoomRateId = s.StateSettingsNyRoomRateId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_StateSettingsOregon', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsOregon;
GO

CREATE FUNCTION dbo.if_StateSettingsOregon(
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
	t.StateSettingsOregonId,
	t.ApplyOregonFeeSchedule
FROM src.StateSettingsOregon t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsOregonId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsOregon
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsOregonId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsOregonId = s.StateSettingsOregonId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_StateSettingsOregonCoverageType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_StateSettingsOregonCoverageType;
GO

CREATE FUNCTION dbo.if_StateSettingsOregonCoverageType(
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
	t.StateSettingsOregonId,
	t.CoverageType
FROM src.StateSettingsOregonCoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsOregonId,
		CoverageType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsOregonCoverageType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsOregonId,
		CoverageType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsOregonId = s.StateSettingsOregonId
	AND t.CoverageType = s.CoverageType
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SupplementBillApportionmentEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SupplementBillApportionmentEndnote;
GO

CREATE FUNCTION dbo.if_SupplementBillApportionmentEndnote(
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
	t.BillId,
	t.SequenceNumber,
	t.LineNumber,
	t.Endnote
FROM src.SupplementBillApportionmentEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SupplementBillApportionmentEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.SequenceNumber = s.SequenceNumber
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SupplementBillCustomEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SupplementBillCustomEndnote;
GO

CREATE FUNCTION dbo.if_SupplementBillCustomEndnote(
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
	t.BillId,
	t.SequenceNumber,
	t.LineNumber,
	t.Endnote
FROM src.SupplementBillCustomEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SupplementBillCustomEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.SequenceNumber = s.SequenceNumber
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SupplementBill_Pharm_ApportionmentEndnote', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SupplementBill_Pharm_ApportionmentEndnote;
GO

CREATE FUNCTION dbo.if_SupplementBill_Pharm_ApportionmentEndnote(
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
	t.BillId,
	t.SequenceNumber,
	t.LineNumber,
	t.Endnote
FROM src.SupplementBill_Pharm_ApportionmentEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SupplementBill_Pharm_ApportionmentEndnote
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillId,
		SequenceNumber,
		LineNumber,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillId = s.BillId
	AND t.SequenceNumber = s.SequenceNumber
	AND t.LineNumber = s.LineNumber
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SupplementPreCtgDeniedLinesEligibleToPenalty', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SupplementPreCtgDeniedLinesEligibleToPenalty;
GO

CREATE FUNCTION dbo.if_SupplementPreCtgDeniedLinesEligibleToPenalty(
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
	t.BillIdNo,
	t.LineNumber,
	t.CtgPenaltyTypeId,
	t.SeqNo
FROM src.SupplementPreCtgDeniedLinesEligibleToPenalty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		LineNumber,
		CtgPenaltyTypeId,
		SeqNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SupplementPreCtgDeniedLinesEligibleToPenalty
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		LineNumber,
		CtgPenaltyTypeId,
		SeqNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.LineNumber = s.LineNumber
	AND t.CtgPenaltyTypeId = s.CtgPenaltyTypeId
	AND t.SeqNo = s.SeqNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_SurgicalModifierException', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_SurgicalModifierException;
GO

CREATE FUNCTION dbo.if_SurgicalModifierException(
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
	t.Modifier,
	t.State,
	t.CoverageType,
	t.StartDate,
	t.EndDate
FROM src.SurgicalModifierException t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Modifier,
		State,
		CoverageType,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SurgicalModifierException
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Modifier,
		State,
		CoverageType,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Modifier = s.Modifier
	AND t.State = s.State
	AND t.CoverageType = s.CoverageType
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UB_APC_DICT', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UB_APC_DICT;
GO

CREATE FUNCTION dbo.if_UB_APC_DICT(
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
	t.StartDate,
	t.EndDate,
	t.APC,
	t.Description
FROM src.UB_APC_DICT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		APC,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UB_APC_DICT
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		APC,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.APC = s.APC
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UB_BillType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UB_BillType;
GO

CREATE FUNCTION dbo.if_UB_BillType(
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
	t.TOB,
	t.Description,
	t.Flag,
	t.UB_BillTypeID
FROM src.UB_BillType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TOB,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UB_BillType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TOB) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TOB = s.TOB
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UB_RevenueCodes', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UB_RevenueCodes;
GO

CREATE FUNCTION dbo.if_UB_RevenueCodes(
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
	t.RevenueCode,
	t.StartDate,
	t.EndDate,
	t.PRC_DESC,
	t.Flags,
	t.Vague,
	t.PerVisit,
	t.PerClaimant,
	t.PerProvider,
	t.BodyFlags,
	t.DrugFlag,
	t.CurativeFlag,
	t.RevenueCodeSubCategoryId
FROM src.UB_RevenueCodes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UB_RevenueCodes
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCode = s.RevenueCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UDFBill', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFBill;
GO

CREATE FUNCTION dbo.if_UDFBill(
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
	t.BillIdNo,
	t.UDFIdNo,
	t.UDFValueText,
	t.UDFValueDecimal,
	t.UDFValueDate
FROM src.UDFBill t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFBill
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UDFClaim', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFClaim;
GO

CREATE FUNCTION dbo.if_UDFClaim(
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
	t.ClaimIdNo,
	t.UDFIdNo,
	t.UDFValueText,
	t.UDFValueDecimal,
	t.UDFValueDate
FROM src.UDFClaim t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimIdNo,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFClaim
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimIdNo,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimIdNo = s.ClaimIdNo
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UDFClaimant', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFClaimant;
GO

CREATE FUNCTION dbo.if_UDFClaimant(
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
	t.CmtIdNo,
	t.UDFIdNo,
	t.UDFValueText,
	t.UDFValueDecimal,
	t.UDFValueDate
FROM src.UDFClaimant t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CmtIdNo,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFClaimant
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CmtIdNo,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CmtIdNo = s.CmtIdNo
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UdfDataFormat', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UdfDataFormat;
GO

CREATE FUNCTION dbo.if_UdfDataFormat(
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
	t.UdfDataFormatId,
	t.DataFormatName
FROM src.UdfDataFormat t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UdfDataFormatId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UdfDataFormat
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UdfDataFormatId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UdfDataFormatId = s.UdfDataFormatId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UDFLevelChangeTracking', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFLevelChangeTracking;
GO

CREATE FUNCTION dbo.if_UDFLevelChangeTracking(
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
	t.UDFLevelChangeTrackingId,
	t.EntityType,
	t.EntityId,
	t.CorrelationId,
	t.UDFId,
	t.PreviousValue,
	t.UpdatedValue,
	t.UserId,
	t.ChangeDate
FROM src.UDFLevelChangeTracking t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UDFLevelChangeTrackingId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFLevelChangeTracking
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UDFLevelChangeTrackingId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UDFLevelChangeTrackingId = s.UDFLevelChangeTrackingId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UDFLibrary', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFLibrary;
GO

CREATE FUNCTION dbo.if_UDFLibrary(
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
	t.UDFIdNo,
	t.UDFName,
	t.ScreenType,
	t.UDFDescription,
	t.DataFormat,
	t.RequiredField,
	t.ReadOnly,
	t.Invisible,
	t.TextMaxLength,
	t.TextMask,
	t.TextEnforceLength,
	t.RestrictRange,
	t.MinValDecimal,
	t.MaxValDecimal,
	t.MinValDate,
	t.MaxValDate,
	t.ListAllowMultiple,
	t.DefaultValueText,
	t.DefaultValueDecimal,
	t.DefaultValueDate,
	t.UseDefault,
	t.ReqOnSubmit,
	t.IncludeDateButton
FROM src.UDFLibrary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFLibrary
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UDFListValues', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFListValues;
GO

CREATE FUNCTION dbo.if_UDFListValues(
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
	t.ListValueIdNo,
	t.UDFIdNo,
	t.SeqNo,
	t.ListValue,
	t.DefaultValue
FROM src.UDFListValues t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ListValueIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFListValues
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ListValueIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ListValueIdNo = s.ListValueIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UDFProvider', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFProvider;
GO

CREATE FUNCTION dbo.if_UDFProvider(
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
	t.PvdIdNo,
	t.UDFIdNo,
	t.UDFValueText,
	t.UDFValueDecimal,
	t.UDFValueDate
FROM src.UDFProvider t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIdNo,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFProvider
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIdNo,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIdNo = s.PvdIdNo
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UDFViewOrder', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDFViewOrder;
GO

CREATE FUNCTION dbo.if_UDFViewOrder(
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
	t.OfficeId,
	t.UDFIdNo,
	t.ViewOrder
FROM src.UDFViewOrder t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OfficeId,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFViewOrder
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OfficeId,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OfficeId = s.OfficeId
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_UDF_Sentry_Criteria', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_UDF_Sentry_Criteria;
GO

CREATE FUNCTION dbo.if_UDF_Sentry_Criteria(
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
	t.UdfIdNo,
	t.CriteriaID,
	t.ParentName,
	t.Name,
	t.Description,
	t.Operators,
	t.PredefinedValues,
	t.ValueDataType,
	t.ValueFormat
FROM src.UDF_Sentry_Criteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CriteriaID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDF_Sentry_Criteria
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CriteriaID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CriteriaID = s.CriteriaID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Vpn', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Vpn;
GO

CREATE FUNCTION dbo.if_Vpn(
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
	t.VpnId,
	t.NetworkName,
	t.PendAndSend,
	t.BypassMatching,
	t.AllowsResends,
	t.OdsEligible
FROM src.Vpn t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Vpn
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnId = s.VpnId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_VPNActivityFlag', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_VPNActivityFlag;
GO

CREATE FUNCTION dbo.if_VPNActivityFlag(
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
	t.Activity_Flag,
	t.AF_Description,
	t.AF_ShortDesc,
	t.Data_Source,
	t.Default_Billable,
	t.Credit
FROM src.VPNActivityFlag t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Activity_Flag,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VPNActivityFlag
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Activity_Flag) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Activity_Flag = s.Activity_Flag
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_VpnBillableFlags', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_VpnBillableFlags;
GO

CREATE FUNCTION dbo.if_VpnBillableFlags(
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
	t.SOJ,
	t.NetworkID,
	t.ActivityFlag,
	t.Billable,
	t.CompanyCode,
	t.CompanyName
FROM src.VpnBillableFlags t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CompanyCode,
		SOJ,
		NetworkID,
		ActivityFlag,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnBillableFlags
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CompanyCode,
		SOJ,
		NetworkID,
		ActivityFlag) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CompanyCode = s.CompanyCode
	AND t.SOJ = s.SOJ
	AND t.NetworkID = s.NetworkID
	AND t.ActivityFlag = s.ActivityFlag
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_VpnBillingCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_VpnBillingCategory;
GO

CREATE FUNCTION dbo.if_VpnBillingCategory(
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
	t.VpnBillingCategoryCode,
	t.VpnBillingCategoryDescription
FROM src.VpnBillingCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnBillingCategoryCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnBillingCategory
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnBillingCategoryCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnBillingCategoryCode = s.VpnBillingCategoryCode
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_VpnLedger', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_VpnLedger;
GO

CREATE FUNCTION dbo.if_VpnLedger(
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
	t.TransactionID,
	t.TransactionTypeID,
	t.BillIdNo,
	t.Line_No,
	t.Charged,
	t.DPAllowed,
	t.VPNAllowed,
	t.Savings,
	t.Credits,
	t.HasOverride,
	t.EndNotes,
	t.NetworkIdNo,
	t.ProcessFlag,
	t.LineType,
	t.DateTimeStamp,
	t.SeqNo,
	t.VPN_Ref_Line_No,
	t.SpecialProcessing,
	t.CreateDate,
	t.LastChangedOn,
	t.AdjustedCharged
FROM src.VpnLedger t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TransactionID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnLedger
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TransactionID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TransactionID = s.TransactionID
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_VpnProcessFlagType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_VpnProcessFlagType;
GO

CREATE FUNCTION dbo.if_VpnProcessFlagType(
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
	t.VpnProcessFlagTypeId,
	t.VpnProcessFlagType
FROM src.VpnProcessFlagType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnProcessFlagTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnProcessFlagType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnProcessFlagTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnProcessFlagTypeId = s.VpnProcessFlagTypeId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_VpnSavingTransactionType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_VpnSavingTransactionType;
GO

CREATE FUNCTION dbo.if_VpnSavingTransactionType(
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
	t.VpnSavingTransactionTypeId,
	t.VpnSavingTransactionType
FROM src.VpnSavingTransactionType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnSavingTransactionTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnSavingTransactionType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnSavingTransactionTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnSavingTransactionTypeId = s.VpnSavingTransactionTypeId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Vpn_Billing_History', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Vpn_Billing_History;
GO

CREATE FUNCTION dbo.if_Vpn_Billing_History(
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
	t.Customer,
	t.TransactionID,
	t.Period,
	t.ActivityFlag,
	t.BillableFlag,
	t.Void,
	t.CreditType,
	t.Network,
	t.BillIdNo,
	t.Line_No,
	t.TransactionDate,
	t.RepriceDate,
	t.ClaimNo,
	t.ProviderCharges,
	t.DPAllowed,
	t.VPNAllowed,
	t.Savings,
	t.Credits,
	t.NetSavings,
	t.SOJ,
	t.seqno,
	t.CompanyCode,
	t.VpnId,
	t.ProcessFlag,
	t.SK,
	t.DATABASE_NAME,
	t.SubmittedToFinance,
	t.IsInitialLoad,
	t.VpnBillingCategoryCode
FROM src.Vpn_Billing_History t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TransactionID,
		Period,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Vpn_Billing_History
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TransactionID,
		Period) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TransactionID = s.TransactionID
	AND t.Period = s.Period
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_WeekEndsAndHolidays', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_WeekEndsAndHolidays;
GO

CREATE FUNCTION dbo.if_WeekEndsAndHolidays(
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
	t.DayOfWeekDate,
	t.DayName,
	t.WeekEndsAndHolidayId
FROM src.WeekEndsAndHolidays t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		WeekEndsAndHolidayId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.WeekEndsAndHolidays
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		WeekEndsAndHolidayId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.WeekEndsAndHolidayId = s.WeekEndsAndHolidayId
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_Zip2County', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Zip2County;
GO

CREATE FUNCTION dbo.if_Zip2County(
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
	t.Zip,
	t.County,
	t.State
FROM src.Zip2County t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Zip,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Zip2County
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Zip) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Zip = s.Zip
WHERE t.DmlOperation <> 'D';

GO


IF OBJECT_ID('dbo.if_ZipCode', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ZipCode;
GO

CREATE FUNCTION dbo.if_ZipCode(
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
	t.ZipCode,
	t.PrimaryRecord,
	t.STATE,
	t.City,
	t.CityAlias,
	t.County,
	t.Cbsa,
	t.CbsaType,
	t.ZipCodeRegionId
FROM src.ZipCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ZipCode,
		CityAlias,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ZipCode
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ZipCode,
		CityAlias) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ZipCode = s.ZipCode
	AND t.CityAlias = s.CityAlias
WHERE t.DmlOperation <> 'D';

GO


 
 
