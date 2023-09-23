IF OBJECT_ID('aw.AcceptedTreatmentDate', 'V') IS NOT NULL
    DROP VIEW aw.AcceptedTreatmentDate;
GO

CREATE VIEW aw.AcceptedTreatmentDate
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,AcceptedTreatmentDateId
	,DemandClaimantId
	,TreatmentDate
	,Comments
	,TreatmentCategoryId
	,LastUpdatedBy
	,LastUpdatedDate
FROM src.AcceptedTreatmentDate
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.AnalysisGroup', 'V') IS NOT NULL
    DROP VIEW aw.AnalysisGroup;
GO

CREATE VIEW aw.AnalysisGroup
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,AnalysisGroupId
	,GroupName
FROM src.AnalysisGroup
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.AnalysisRule', 'V') IS NOT NULL
    DROP VIEW aw.AnalysisRule;
GO

CREATE VIEW aw.AnalysisRule
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,AnalysisRuleId
	,Title
	,AssemblyQualifiedName
	,MethodToInvoke
	,DisplayMessage
	,DisplayOrder
	,IsActive
	,CreateDate
	,LastChangedOn
	,MessageToken
FROM src.AnalysisRule
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.AnalysisRuleGroup', 'V') IS NOT NULL
    DROP VIEW aw.AnalysisRuleGroup;
GO

CREATE VIEW aw.AnalysisRuleGroup
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,AnalysisRuleGroupId
	,AnalysisRuleId
	,AnalysisGroupId
FROM src.AnalysisRuleGroup
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.AnalysisRuleThreshold', 'V') IS NOT NULL
    DROP VIEW aw.AnalysisRuleThreshold;
GO

CREATE VIEW aw.AnalysisRuleThreshold
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,AnalysisRuleThresholdId
	,AnalysisRuleId
	,ThresholdKey
	,ThresholdValue
	,CreateDate
	,LastChangedOn
FROM src.AnalysisRuleThreshold
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.ClaimantManualProviderSummary', 'V') IS NOT NULL
    DROP VIEW aw.ClaimantManualProviderSummary;
GO

CREATE VIEW aw.ClaimantManualProviderSummary
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ManualProviderId
	,DemandClaimantId
	,FirstDateOfService
	,LastDateOfService
	,Visits
	,ChargedAmount
	,EvaluatedAmount
	,MinimumEvaluatedAmount
	,MaximumEvaluatedAmount
	,Comments
FROM src.ClaimantManualProviderSummary
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.ClaimantProviderSummaryEvaluation', 'V') IS NOT NULL
    DROP VIEW aw.ClaimantProviderSummaryEvaluation;
GO

CREATE VIEW aw.ClaimantProviderSummaryEvaluation
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimantProviderSummaryEvaluationId
	,ClaimantHeaderId
	,EvaluatedAmount
	,MinimumEvaluatedAmount
	,MaximumEvaluatedAmount
	,Comments
FROM src.ClaimantProviderSummaryEvaluation
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.DemandClaimant', 'V') IS NOT NULL
    DROP VIEW aw.DemandClaimant;
GO

CREATE VIEW aw.DemandClaimant
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DemandClaimantId
	,ExternalClaimantId
	,OrganizationId
	,HeightInInches
	,Weight
	,Occupation
	,BiReportStatus
	,HasDemandPackage
	,FactsOfLoss
	,PreExistingConditions
	,Archived
FROM src.DemandClaimant
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.DemandPackage', 'V') IS NOT NULL
    DROP VIEW aw.DemandPackage;
GO

CREATE VIEW aw.DemandPackage
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DemandPackageId
	,DemandClaimantId
	,RequestedByUserName
	,DateTimeReceived
	,CorrelationId
	,PageCount
FROM src.DemandPackage
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.DemandPackageRequestedService', 'V') IS NOT NULL
    DROP VIEW aw.DemandPackageRequestedService;
GO

CREATE VIEW aw.DemandPackageRequestedService
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DemandPackageRequestedServiceId
	,DemandPackageId
	,ReviewRequestOptions
FROM src.DemandPackageRequestedService
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.DemandPackageUploadedFile', 'V') IS NOT NULL
    DROP VIEW aw.DemandPackageUploadedFile;
GO

CREATE VIEW aw.DemandPackageUploadedFile
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DemandPackageUploadedFileId
	,DemandPackageId
	,FileName
	,Size
	,DocStoreId
FROM src.DemandPackageUploadedFile
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.EvaluationSummary', 'V') IS NOT NULL
    DROP VIEW aw.EvaluationSummary;
GO

CREATE VIEW aw.EvaluationSummary
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DemandClaimantId
	,Details
	,CreatedBy
	,CreatedDate
	,ModifiedBy
	,ModifiedDate
	,EvaluationSummaryTemplateVersionId
FROM src.EvaluationSummary
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.EvaluationSummaryHistory', 'V') IS NOT NULL
    DROP VIEW aw.EvaluationSummaryHistory;
GO

CREATE VIEW aw.EvaluationSummaryHistory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EvaluationSummaryHistoryId
	,DemandClaimantId
	,EvaluationSummary
	,CreatedBy
	,CreatedDate
FROM src.EvaluationSummaryHistory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.EvaluationSummaryTemplateVersion', 'V') IS NOT NULL
    DROP VIEW aw.EvaluationSummaryTemplateVersion;
GO

CREATE VIEW aw.EvaluationSummaryTemplateVersion
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EvaluationSummaryTemplateVersionId
	,Template
	,TemplateHash
	,CreatedDate
FROM src.EvaluationSummaryTemplateVersion
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.EventLog', 'V') IS NOT NULL
    DROP VIEW aw.EventLog;
GO

CREATE VIEW aw.EventLog
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EventLogId
	,ObjectName
	,ObjectId
	,UserName
	,LogDate
	,ActionName
	,OrganizationId
FROM src.EventLog
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.EventLogDetail', 'V') IS NOT NULL
    DROP VIEW aw.EventLogDetail;
GO

CREATE VIEW aw.EventLogDetail
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EventLogDetailId
	,EventLogId
	,PropertyName
	,OldValue
	,NewValue
FROM src.EventLogDetail
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.ManualProvider', 'V') IS NOT NULL
    DROP VIEW aw.ManualProvider;
GO

CREATE VIEW aw.ManualProvider
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ManualProviderId
	,TIN
	,LastName
	,FirstName
	,GroupName
	,Address1
	,Address2
	,City
	,State
	,Zip
FROM src.ManualProvider
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.ManualProviderSpecialty', 'V') IS NOT NULL
    DROP VIEW aw.ManualProviderSpecialty;
GO

CREATE VIEW aw.ManualProviderSpecialty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ManualProviderId
	,Specialty
FROM src.ManualProviderSpecialty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.Note', 'V') IS NOT NULL
    DROP VIEW aw.Note;
GO

CREATE VIEW aw.Note
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,NoteId
	,DateCreated
	,DateModified
	,CreatedBy
	,ModifiedBy
	,Flag
	,Content
	,NoteContext
	,DemandClaimantId
FROM src.Note
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.ProvidedLink', 'V') IS NOT NULL
    DROP VIEW aw.ProvidedLink;
GO

CREATE VIEW aw.ProvidedLink
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProvidedLinkId
	,Title
	,URL
	,OrderIndex
FROM src.ProvidedLink
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.Tag', 'V') IS NOT NULL
    DROP VIEW aw.Tag;
GO

CREATE VIEW aw.Tag
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TagId
	,NAME
	,DateCreated
	,DateModified
	,CreatedBy
	,ModifiedBy
FROM src.Tag
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.TreatmentCategory', 'V') IS NOT NULL
    DROP VIEW aw.TreatmentCategory;
GO

CREATE VIEW aw.TreatmentCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TreatmentCategoryId
	,Category
	,Metadata
FROM src.TreatmentCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('aw.TreatmentCategoryRange', 'V') IS NOT NULL
    DROP VIEW aw.TreatmentCategoryRange;
GO

CREATE VIEW aw.TreatmentCategoryRange
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TreatmentCategoryRangeId
	,TreatmentCategoryId
	,StartRange
	,EndRange
FROM src.TreatmentCategoryRange
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Adjustment3603rdPartyEndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment3603rdPartyEndNoteSubCategory;
GO

CREATE VIEW dbo.Adjustment3603rdPartyEndNoteSubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,SubCategoryId
FROM src.Adjustment3603rdPartyEndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Adjustment360ApcEndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment360ApcEndNoteSubCategory;
GO

CREATE VIEW dbo.Adjustment360ApcEndNoteSubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,SubCategoryId
FROM src.Adjustment360ApcEndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Adjustment360Category', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment360Category;
GO

CREATE VIEW dbo.Adjustment360Category
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Adjustment360CategoryId
	,Name
FROM src.Adjustment360Category
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Adjustment360EndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment360EndNoteSubCategory;
GO

CREATE VIEW dbo.Adjustment360EndNoteSubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,SubCategoryId
	,EndnoteTypeId
FROM src.Adjustment360EndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Adjustment360OverrideEndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment360OverrideEndNoteSubCategory;
GO

CREATE VIEW dbo.Adjustment360OverrideEndNoteSubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,SubCategoryId
FROM src.Adjustment360OverrideEndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Adjustment360SubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment360SubCategory;
GO

CREATE VIEW dbo.Adjustment360SubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Adjustment360SubCategoryId
	,Name
	,Adjustment360CategoryId
FROM src.Adjustment360SubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Adjustment3rdPartyEndnoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustment3rdPartyEndnoteSubCategory;
GO

CREATE VIEW dbo.Adjustment3rdPartyEndnoteSubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,SubCategoryId
FROM src.Adjustment3rdPartyEndnoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.AdjustmentApcEndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.AdjustmentApcEndNoteSubCategory;
GO

CREATE VIEW dbo.AdjustmentApcEndNoteSubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,SubCategoryId
FROM src.AdjustmentApcEndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.AdjustmentEndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.AdjustmentEndNoteSubCategory;
GO

CREATE VIEW dbo.AdjustmentEndNoteSubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,SubCategoryId
FROM src.AdjustmentEndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.AdjustmentOverrideEndNoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.AdjustmentOverrideEndNoteSubCategory;
GO

CREATE VIEW dbo.AdjustmentOverrideEndNoteSubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,SubCategoryId
FROM src.AdjustmentOverrideEndNoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Adjustor', 'V') IS NOT NULL
    DROP VIEW dbo.Adjustor;
GO

CREATE VIEW dbo.Adjustor
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,lAdjIdNo
	,IDNumber
	,Lastname
	,FirstName
	,Address1
	,Address2
	,City
	,State
	,ZipCode
	,Phone
	,Fax
	,Office
	,EMail
	,InUse
	,OfficeIdNo
	,UserId
	,CreateDate
	,LastChangedOn
FROM src.Adjustor
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ApportionmentEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.ApportionmentEndnote;
GO

CREATE VIEW dbo.ApportionmentEndnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ApportionmentEndnote
	,ShortDescription
	,LongDescription
FROM src.ApportionmentEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillAdjustment', 'V') IS NOT NULL
    DROP VIEW dbo.BillAdjustment;
GO

CREATE VIEW dbo.BillAdjustment
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillLineAdjustmentId
	,BillIdNo
	,LineNumber
	,Adjustment
	,EndNote
	,EndNoteTypeId
FROM src.BillAdjustment
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillApportionmentEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.BillApportionmentEndnote;
GO

CREATE VIEW dbo.BillApportionmentEndnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillId
	,LineNumber
	,Endnote
FROM src.BillApportionmentEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillCustomEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.BillCustomEndnote;
GO

CREATE VIEW dbo.BillCustomEndnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillId
	,LineNumber
	,Endnote
FROM src.BillCustomEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillExclusionLookUpTable', 'V') IS NOT NULL
    DROP VIEW dbo.BillExclusionLookUpTable;
GO

CREATE VIEW dbo.BillExclusionLookUpTable
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReportID
	,ReportName
FROM src.BillExclusionLookUpTable
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BILLS', 'V') IS NOT NULL
    DROP VIEW dbo.BILLS;
GO

CREATE VIEW dbo.BILLS
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIDNo
	,LINE_NO
	,LINE_NO_DISP
	,OVER_RIDE
	,DT_SVC
	,PRC_CD
	,UNITS
	,TS_CD
	,CHARGED
	,ALLOWED
	,ANALYZED
	,REASON1
	,REASON2
	,REASON3
	,REASON4
	,REASON5
	,REASON6
	,REASON7
	,REASON8
	,REF_LINE_NO
	,SUBNET
	,OverrideReason
	,FEE_SCHEDULE
	,POS_RevCode
	,CTGPenalty
	,PrePPOAllowed
	,PPODate
	,PPOCTGPenalty
	,UCRPerUnit
	,FSPerUnit
	,HCRA_Surcharge
	,EligibleAmt
	,DPAllowed
	,EndDateOfService
	,AnalyzedCtgPenalty
	,AnalyzedCtgPpoPenalty
	,RepackagedNdc
	,OriginalNdc
	,UnitOfMeasureId
	,PackageTypeOriginalNdc
	,ServiceCode
	,PreApportionedAmount
	,DeductibleApplied
	,BillReviewResults
	,PreOverriddenDeductible
	,RemainingBalance
	,CtgCoPayPenalty
	,PpoCtgCoPayPenaltyPercentage
	,AnalyzedCtgCoPayPenalty
	,AnalyzedPpoCtgCoPayPenaltyPercentage
	,CtgVunPenalty
	,PpoCtgVunPenaltyPercentage
	,AnalyzedCtgVunPenalty
	,AnalyzedPpoCtgVunPenaltyPercentage
	,RenderingNpi
FROM src.BILLS
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillsOverride', 'V') IS NOT NULL
    DROP VIEW dbo.BillsOverride;
GO

CREATE VIEW dbo.BillsOverride
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillsOverrideID
	,BillIDNo
	,LINE_NO
	,UserId
	,DateSaved
	,AmountBefore
	,AmountAfter
	,CodesOverrode
	,SeqNo
FROM src.BillsOverride
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BillsProviderNetwork', 'V') IS NOT NULL
    DROP VIEW dbo.BillsProviderNetwork;
GO

CREATE VIEW dbo.BillsProviderNetwork
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,NetworkId
	,NetworkName
FROM src.BillsProviderNetwork
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BILLS_CTG_Endnotes', 'V') IS NOT NULL
    DROP VIEW dbo.BILLS_CTG_Endnotes;
GO

CREATE VIEW dbo.BILLS_CTG_Endnotes
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,Line_No
	,Endnote
	,RuleType
	,RuleId
	,PreCertAction
	,PercentDiscount
	,ActionId
FROM src.BILLS_CTG_Endnotes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BILLS_DRG', 'V') IS NOT NULL
    DROP VIEW dbo.BILLS_DRG;
GO

CREATE VIEW dbo.BILLS_DRG
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,PricerPassThru
	,PricerCapital_Outlier_Amt
	,PricerCapital_OldHarm_Amt
	,PricerCapital_IME_Amt
	,PricerCapital_HSP_Amt
	,PricerCapital_FSP_Amt
	,PricerCapital_Exceptions_Amt
	,PricerCapital_DSH_Amt
	,PricerCapitalPayment
	,PricerDSH
	,PricerIME
	,PricerCostOutlier
	,PricerHSP
	,PricerFSP
	,PricerTotalPayment
	,PricerReturnMsg
	,ReturnDRG
	,ReturnDRGDesc
	,ReturnMDC
	,ReturnMDCDesc
	,ReturnDRGWt
	,ReturnDRGALOS
	,ReturnADX
	,ReturnSDX
	,ReturnMPR
	,ReturnPR2
	,ReturnPR3
	,ReturnNOR
	,ReturnNO2
	,ReturnCOM
	,ReturnCMI
	,ReturnDCC
	,ReturnDX1
	,ReturnDX2
	,ReturnDX3
	,ReturnMCI
	,ReturnOR1
	,ReturnOR2
	,ReturnOR3
	,ReturnTRI
	,SOJ
	,OPCERT
	,BlendCaseInclMalp
	,CapitalCost
	,HospBadDebt
	,ExcessPhysMalp
	,SparcsPerCase
	,AltLevelOfCare
	,DRGWgt
	,TransferCapital
	,NYDrgType
	,LOS
	,TrimPoint
	,GroupBlendPercentage
	,AdjustmentFactor
	,HospLongStayGroupPrice
	,TotalDRGCharge
	,BlendCaseAdj
	,CapitalCostAdj
	,NonMedicareCaseMix
	,HighCostChargeConverter
	,DischargeCasePaymentRate
	,DirectMedicalEducation
	,CasePaymentCapitalPerDiem
	,HighCostOutlierThreshold
	,ISAF
	,ReturnSOI
	,CapitalCostPerDischarge
	,ReturnSOIDesc
FROM src.BILLS_DRG
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BILLS_Endnotes', 'V') IS NOT NULL
    DROP VIEW dbo.BILLS_Endnotes;
GO

CREATE VIEW dbo.BILLS_Endnotes
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIDNo
	,LINE_NO
	,EndNote
	,Referral
	,PercentDiscount
	,ActionId
	,EndnoteTypeId
FROM src.BILLS_Endnotes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Bills_OverrideEndNotes', 'V') IS NOT NULL
    DROP VIEW dbo.Bills_OverrideEndNotes;
GO

CREATE VIEW dbo.Bills_OverrideEndNotes
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,OverrideEndNoteID
	,BillIdNo
	,Line_No
	,OverrideEndNote
	,PercentDiscount
	,ActionId
FROM src.Bills_OverrideEndNotes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Bills_Pharm', 'V') IS NOT NULL
    DROP VIEW dbo.Bills_Pharm;
GO

CREATE VIEW dbo.Bills_Pharm
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,Line_No
	,LINE_NO_DISP
	,DateOfService
	,NDC
	,PriceTypeCode
	,Units
	,Charged
	,Allowed
	,EndNote
	,Override
	,Override_Rsn
	,Analyzed
	,CTGPenalty
	,PrePPOAllowed
	,PPODate
	,POS_RevCode
	,DPAllowed
	,HCRA_Surcharge
	,EndDateOfService
	,RepackagedNdc
	,OriginalNdc
	,UnitOfMeasureId
	,PackageTypeOriginalNdc
	,PpoCtgPenalty
	,ServiceCode
	,PreApportionedAmount
	,DeductibleApplied
	,BillReviewResults
	,PreOverriddenDeductible
	,RemainingBalance
	,CtgCoPayPenalty
	,PpoCtgCoPayPenaltyPercentage
	,CtgVunPenalty
	,PpoCtgVunPenaltyPercentage
	,RenderingNpi
FROM src.Bills_Pharm
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Bills_Pharm_CTG_Endnotes', 'V') IS NOT NULL
    DROP VIEW dbo.Bills_Pharm_CTG_Endnotes;
GO

CREATE VIEW dbo.Bills_Pharm_CTG_Endnotes
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIDNo
	,LINE_NO
	,EndNote
	,RuleType
	,RuleId
	,PreCertAction
	,PercentDiscount
	,ActionId
FROM src.Bills_Pharm_CTG_Endnotes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Bills_Pharm_Endnotes', 'V') IS NOT NULL
    DROP VIEW dbo.Bills_Pharm_Endnotes;
GO

CREATE VIEW dbo.Bills_Pharm_Endnotes
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIDNo
	,LINE_NO
	,EndNote
	,Referral
	,PercentDiscount
	,ActionId
	,EndnoteTypeId
FROM src.Bills_Pharm_Endnotes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Bills_Pharm_OverrideEndNotes', 'V') IS NOT NULL
    DROP VIEW dbo.Bills_Pharm_OverrideEndNotes;
GO

CREATE VIEW dbo.Bills_Pharm_OverrideEndNotes
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,OverrideEndNoteID
	,BillIdNo
	,Line_No
	,OverrideEndNote
	,PercentDiscount
	,ActionId
FROM src.Bills_Pharm_OverrideEndNotes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Bills_Tax', 'V') IS NOT NULL
    DROP VIEW dbo.Bills_Tax;
GO

CREATE VIEW dbo.Bills_Tax
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillsTaxId
	,TableType
	,BillIdNo
	,Line_No
	,SeqNo
	,TaxTypeId
	,ImportTaxRate
	,Tax
	,OverridenTax
	,ImportTaxAmount
FROM src.Bills_Tax
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BILL_HDR', 'V') IS NOT NULL
    DROP VIEW dbo.BILL_HDR;
GO

CREATE VIEW dbo.BILL_HDR
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIDNo
	,CMT_HDR_IDNo
	,DateSaved
	,DateRcv
	,InvoiceNumber
	,InvoiceDate
	,FileNumber
	,Note
	,NoLines
	,AmtCharged
	,AmtAllowed
	,ReasonVersion
	,Region
	,PvdUpdateCounter
	,FeatureID
	,ClaimDateLoss
	,CV_Type
	,Flags
	,WhoCreate
	,WhoLast
	,AcceptAssignment
	,EmergencyService
	,CmtPaidDeductible
	,InsPaidLimit
	,StatusFlag
	,OfficeId
	,CmtPaidCoPay
	,AmbulanceMethod
	,StatusDate
	,Category
	,CatDesc
	,AssignedUser
	,CreateDate
	,PvdZOS
	,PPONumberSent
	,AdmissionDate
	,DischargeDate
	,DischargeStatus
	,TypeOfBill
	,SentryMessage
	,AmbulanceZipOfPickup
	,AmbulanceNumberOfPatients
	,WhoCreateID
	,WhoLastId
	,NYRequestDate
	,NYReceivedDate
	,ImgDocId
	,PaymentDecision
	,PvdCMSId
	,PvdNPINo
	,DischargeHour
	,PreCertChanged
	,DueDate
	,AttorneyIDNo
	,AssignedGroup
	,LastChangedOn
	,PrePPOAllowed
	,PPSCode
	,SOI
	,StatementStartDate
	,StatementEndDate
	,DeductibleOverride
	,AdmissionType
	,CoverageType
	,PricingProfileId
	,DesignatedPricingState
	,DateAnalyzed
	,SentToPpoSysId
	,PricingState
	,BillVpnEligible
	,ApportionmentPercentage
	,BillSourceId
	,OutOfStateProviderNumber
	,FloridaDeductibleRuleEligible
FROM src.BILL_HDR
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Bill_History', 'V') IS NOT NULL
    DROP VIEW dbo.Bill_History;
GO

CREATE VIEW dbo.Bill_History
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,SeqNo
	,DateCommitted
	,AmtCommitted
	,UserId
	,AmtCoPay
	,AmtDeductible
	,Flags
	,AmtSalesTax
	,AmtOtherTax
	,DeductibleOverride
	,PricingState
	,ApportionmentPercentage
	,FloridaDeductibleRuleEligible
FROM src.Bill_History
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Bill_Payment_Adjustments', 'V') IS NOT NULL
    DROP VIEW dbo.Bill_Payment_Adjustments;
GO

CREATE VIEW dbo.Bill_Payment_Adjustments
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Bill_Payment_Adjustment_ID
	,BillIDNo
	,SeqNo
	,InterestFlags
	,DateInterestStarts
	,DateInterestEnds
	,InterestAdditionalInfoReceived
	,Interest
	,Comments
FROM src.Bill_Payment_Adjustments
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Bill_Pharm_ApportionmentEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.Bill_Pharm_ApportionmentEndnote;
GO

CREATE VIEW dbo.Bill_Pharm_ApportionmentEndnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillId
	,LineNumber
	,Endnote
FROM src.Bill_Pharm_ApportionmentEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Bill_Sentry_Endnote', 'V') IS NOT NULL
    DROP VIEW dbo.Bill_Sentry_Endnote;
GO

CREATE VIEW dbo.Bill_Sentry_Endnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillID
	,Line
	,RuleID
	,PercentDiscount
	,ActionId
FROM src.Bill_Sentry_Endnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BIReportAdjustmentCategory', 'V') IS NOT NULL
    DROP VIEW dbo.BIReportAdjustmentCategory;
GO

CREATE VIEW dbo.BIReportAdjustmentCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BIReportAdjustmentCategoryId
	,Name
	,Description
	,DisplayPriority
FROM src.BIReportAdjustmentCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.BIReportAdjustmentCategoryMapping', 'V') IS NOT NULL
    DROP VIEW dbo.BIReportAdjustmentCategoryMapping;
GO

CREATE VIEW dbo.BIReportAdjustmentCategoryMapping
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BIReportAdjustmentCategoryId
	,Adjustment360SubCategoryId
FROM src.BIReportAdjustmentCategoryMapping
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Bitmasks', 'V') IS NOT NULL
    DROP VIEW dbo.Bitmasks;
GO

CREATE VIEW dbo.Bitmasks
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TableProgramUsed
	,AttributeUsed
	,Decimal
	,ConstantName
	,Bit
	,Hex
	,Description
FROM src.Bitmasks
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CbreToDpEndnoteMapping', 'V') IS NOT NULL
    DROP VIEW dbo.CbreToDpEndnoteMapping;
GO

CREATE VIEW dbo.CbreToDpEndnoteMapping
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Endnote
	,EndnoteTypeId
	,CbreEndnote
	,PricingState
	,PricingMethodId
FROM src.CbreToDpEndnoteMapping
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CLAIMANT', 'V') IS NOT NULL
    DROP VIEW dbo.CLAIMANT;
GO

CREATE VIEW dbo.CLAIMANT
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CmtIDNo
	,ClaimIDNo
	,CmtSSN
	,CmtLastName
	,CmtFirstName
	,CmtMI
	,CmtDOB
	,CmtSEX
	,CmtAddr1
	,CmtAddr2
	,CmtCity
	,CmtState
	,CmtZip
	,CmtPhone
	,CmtOccNo
	,CmtAttorneyNo
	,CmtPolicyLimit
	,CmtStateOfJurisdiction
	,CmtDeductible
	,CmtCoPaymentPercentage
	,CmtCoPaymentMax
	,CmtPPO_Eligible
	,CmtCoordBenefits
	,CmtFLCopay
	,CmtCOAExport
	,CmtPGFirstName
	,CmtPGLastName
	,CmtDedType
	,ExportToClaimIQ
	,CmtInactive
	,CmtPreCertOption
	,CmtPreCertState
	,CreateDate
	,LastChangedOn
	,OdsParticipant
	,CoverageType
	,DoNotDisplayCoverageTypeOnEOB
	,ShowAllocationsOnEob
	,SetPreAllocation
	,PharmacyEligible
	,SendCardToClaimant
	,ShareCoPayMaximum
FROM src.CLAIMANT
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Claimant_ClientRef', 'V') IS NOT NULL
    DROP VIEW dbo.Claimant_ClientRef;
GO

CREATE VIEW dbo.Claimant_ClientRef
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CmtIdNo
	,CmtSuffix
	,ClaimIdNo
FROM src.Claimant_ClientRef
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


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


IF OBJECT_ID('dbo.Claims_ClientRef', 'V') IS NOT NULL
    DROP VIEW dbo.Claims_ClientRef;
GO

CREATE VIEW dbo.Claims_ClientRef
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimIdNo
	,ClientRefId
FROM src.Claims_ClientRef
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CMS_Zip2Region', 'V') IS NOT NULL
    DROP VIEW dbo.CMS_Zip2Region;
GO

CREATE VIEW dbo.CMS_Zip2Region
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StartDate
	,EndDate
	,ZIP_Code
	,State
	,Region
	,AmbRegion
	,RuralFlag
	,ASCRegion
	,PlusFour
	,CarrierId
FROM src.CMS_Zip2Region
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CMT_DX', 'V') IS NOT NULL
    DROP VIEW dbo.CMT_DX;
GO

CREATE VIEW dbo.CMT_DX
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIDNo
	,DX
	,SeqNum
	,POA
	,IcdVersion
FROM src.CMT_DX
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CMT_HDR', 'V') IS NOT NULL
    DROP VIEW dbo.CMT_HDR;
GO

CREATE VIEW dbo.CMT_HDR
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CMT_HDR_IDNo
	,CmtIDNo
	,PvdIDNo
	,LastChangedOn
FROM src.CMT_HDR
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CMT_ICD9', 'V') IS NOT NULL
    DROP VIEW dbo.CMT_ICD9;
GO

CREATE VIEW dbo.CMT_ICD9
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIDNo
	,SeqNo
	,ICD9
	,IcdVersion
FROM src.CMT_ICD9
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CoverageType', 'V') IS NOT NULL
    DROP VIEW dbo.CoverageType;
GO

CREATE VIEW dbo.CoverageType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,LongName
	,ShortName
	,CbreCoverageTypeCode
	,CoverageTypeCategoryCode
	,PricingMethodId
FROM src.CoverageType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.cpt_DX_DICT', 'V') IS NOT NULL
    DROP VIEW dbo.cpt_DX_DICT;
GO

CREATE VIEW dbo.cpt_DX_DICT
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ICD9
	,StartDate
	,EndDate
	,Flags
	,NonSpecific
	,AdditionalDigits
	,Traumatic
	,DX_DESC
	,Duration
	,Colossus
	,DiagnosisFamilyId
FROM src.cpt_DX_DICT
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.cpt_PRC_DICT', 'V') IS NOT NULL
    DROP VIEW dbo.cpt_PRC_DICT;
GO

CREATE VIEW dbo.cpt_PRC_DICT
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PRC_CD
	,StartDate
	,EndDate
	,PRC_DESC
	,Flags
	,Vague
	,PerVisit
	,PerClaimant
	,PerProvider
	,BodyFlags
	,Colossus
	,CMS_Status
	,DrugFlag
	,CurativeFlag
	,ExclPolicyLimit
	,SpecNetFlag
FROM src.cpt_PRC_DICT
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CreditReason', 'V') IS NOT NULL
    DROP VIEW dbo.CreditReason;
GO

CREATE VIEW dbo.CreditReason
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CreditReasonId
	,CreditReasonDesc
	,IsVisible
FROM src.CreditReason
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CreditReasonOverrideENMap', 'V') IS NOT NULL
    DROP VIEW dbo.CreditReasonOverrideENMap;
GO

CREATE VIEW dbo.CreditReasonOverrideENMap
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CreditReasonOverrideENMapId
	,CreditReasonId
	,OverrideEndnoteId
FROM src.CreditReasonOverrideENMap
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CriticalAccessHospitalInpatientRevenueCode', 'V') IS NOT NULL
    DROP VIEW dbo.CriticalAccessHospitalInpatientRevenueCode;
GO

CREATE VIEW dbo.CriticalAccessHospitalInpatientRevenueCode
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RevenueCode
FROM src.CriticalAccessHospitalInpatientRevenueCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CTG_Endnotes', 'V') IS NOT NULL
    DROP VIEW dbo.CTG_Endnotes;
GO

CREATE VIEW dbo.CTG_Endnotes
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Endnote
	,ShortDesc
	,LongDesc
FROM src.CTG_Endnotes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CustomBillStatuses', 'V') IS NOT NULL
    DROP VIEW dbo.CustomBillStatuses;
GO

CREATE VIEW dbo.CustomBillStatuses
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StatusId
	,StatusName
	,StatusDescription
FROM src.CustomBillStatuses
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CustomEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.CustomEndnote;
GO

CREATE VIEW dbo.CustomEndnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CustomEndnote
	,ShortDescription
	,LongDescription
FROM src.CustomEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.CustomerBillExclusion', 'V') IS NOT NULL
    DROP VIEW dbo.CustomerBillExclusion;
GO

CREATE VIEW dbo.CustomerBillExclusion
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,Customer
	,ReportID
	,CreateDate
FROM src.CustomerBillExclusion
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.DeductibleRuleCriteria', 'V') IS NOT NULL
    DROP VIEW dbo.DeductibleRuleCriteria;
GO

CREATE VIEW dbo.DeductibleRuleCriteria
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DeductibleRuleCriteriaId
	,PricingRuleDateCriteriaId
	,StartDate
	,EndDate
FROM src.DeductibleRuleCriteria
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.DeductibleRuleCriteriaCoverageType', 'V') IS NOT NULL
    DROP VIEW dbo.DeductibleRuleCriteriaCoverageType;
GO

CREATE VIEW dbo.DeductibleRuleCriteriaCoverageType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DeductibleRuleCriteriaId
	,CoverageType
FROM src.DeductibleRuleCriteriaCoverageType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.DeductibleRuleExemptEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.DeductibleRuleExemptEndnote;
GO

CREATE VIEW dbo.DeductibleRuleExemptEndnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Endnote
	,EndnoteTypeId
FROM src.DeductibleRuleExemptEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.DiagnosisCodeGroup', 'V') IS NOT NULL
    DROP VIEW dbo.DiagnosisCodeGroup;
GO

CREATE VIEW dbo.DiagnosisCodeGroup
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DiagnosisCode
	,StartDate
	,EndDate
	,MajorCategory
	,MinorCategory
FROM src.DiagnosisCodeGroup
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.EncounterType', 'V') IS NOT NULL
    DROP VIEW dbo.EncounterType;
GO

CREATE VIEW dbo.EncounterType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EncounterTypeId
	,EncounterTypePriority
	,Description
	,NarrativeInformation
FROM src.EncounterType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.EndnoteSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.EndnoteSubCategory;
GO

CREATE VIEW dbo.EndnoteSubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,EndnoteSubCategoryId
	,Description
FROM src.EndnoteSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Esp_Ppo_Billing_Data_Self_Bill', 'V') IS NOT NULL
    DROP VIEW dbo.Esp_Ppo_Billing_Data_Self_Bill;
GO

CREATE VIEW dbo.Esp_Ppo_Billing_Data_Self_Bill
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,COMPANYCODE
	,TRANSACTIONTYPE
	,BILL_HDR_AMTALLOWED
	,BILL_HDR_AMTCHARGED
	,BILL_HDR_BILLIDNO
	,BILL_HDR_CMT_HDR_IDNO
	,BILL_HDR_CREATEDATE
	,BILL_HDR_CV_TYPE
	,BILL_HDR_FORM_TYPE
	,BILL_HDR_NOLINES
	,BILLS_ALLOWED
	,BILLS_ANALYZED
	,BILLS_CHARGED
	,BILLS_DT_SVC
	,BILLS_LINE_NO
	,CLAIMANT_CLIENTREF_CMTSUFFIX
	,CLAIMANT_CMTFIRST_NAME
	,CLAIMANT_CMTIDNO
	,CLAIMANT_CMTLASTNAME
	,CMTSTATEOFJURISDICTION
	,CLAIMS_COMPANYID
	,CLAIMS_CLAIMNO
	,CLAIMS_DATELOSS
	,CLAIMS_OFFICEINDEX
	,CLAIMS_POLICYHOLDERSNAME
	,CLAIMS_POLICYNUMBER
	,PNETWKEVENTLOG_EVENTID
	,PNETWKEVENTLOG_LOGDATE
	,PNETWKEVENTLOG_NETWORKID
	,ACTIVITY_FLAG
	,PPO_AMTALLOWED
	,PREPPO_AMTALLOWED
	,PREPPO_ALLOWED_FS
	,PRF_COMPANY_COMPANYNAME
	,PRF_OFFICE_OFCNAME
	,PRF_OFFICE_OFCNO
	,PROVIDER_PVDFIRSTNAME
	,PROVIDER_PVDGROUP
	,PROVIDER_PVDLASTNAME
	,PROVIDER_PVDTIN
	,PROVIDER_STATE
	,UDFCLAIM_UDFVALUETEXT
	,ENTRY_DATE
	,UDFCLAIMANT_UDFVALUETEXT
	,SOURCE_DB
	,CLAIMS_CV_CODE
	,VPN_TRANSACTIONID
	,VPN_TRANSACTIONTYPEID
	,VPN_BILLIDNO
	,VPN_LINE_NO
	,VPN_CHARGED
	,VPN_DPALLOWED
	,VPN_VPNALLOWED
	,VPN_SAVINGS
	,VPN_CREDITS
	,VPN_HASOVERRIDE
	,VPN_ENDNOTES
	,VPN_NETWORKIDNO
	,VPN_PROCESSFLAG
	,VPN_LINETYPE
	,VPN_DATETIMESTAMP
	,VPN_SEQNO
	,VPN_VPN_REF_LINE_NO
	,VPN_NETWORKNAME
	,VPN_SOJ
	,VPN_CAT3
	,VPN_PPODATESTAMP
	,VPN_NINTEYDAYS
	,VPN_BILL_TYPE
	,VPN_NET_SAVINGS
	,CREDIT
	,RECON
	,DELETED
	,STATUS_FLAG
	,DATE_SAVED
	,SUB_NETWORK
	,INVALID_CREDIT
	,PROVIDER_SPECIALTY
	,ADJUSTOR_IDNUMBER
	,ACP_FLAG
	,OVERRIDE_ENDNOTES
	,OVERRIDE_ENDNOTES_DESC
FROM src.Esp_Ppo_Billing_Data_Self_Bill
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ExtractCat', 'V') IS NOT NULL
    DROP VIEW dbo.ExtractCat;
GO

CREATE VIEW dbo.ExtractCat
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CatIdNo
	,Description
FROM src.ExtractCat
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.GeneralInterestRuleBaseType', 'V') IS NOT NULL
    DROP VIEW dbo.GeneralInterestRuleBaseType;
GO

CREATE VIEW dbo.GeneralInterestRuleBaseType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,GeneralInterestRuleBaseTypeId
	,GeneralInterestRuleBaseTypeName
FROM src.GeneralInterestRuleBaseType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.GeneralInterestRuleSetting', 'V') IS NOT NULL
    DROP VIEW dbo.GeneralInterestRuleSetting;
GO

CREATE VIEW dbo.GeneralInterestRuleSetting
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,GeneralInterestRuleBaseTypeId
FROM src.GeneralInterestRuleSetting
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Icd10DiagnosisVersion', 'V') IS NOT NULL
    DROP VIEW dbo.Icd10DiagnosisVersion;
GO

CREATE VIEW dbo.Icd10DiagnosisVersion
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DiagnosisCode
	,StartDate
	,EndDate
	,NonSpecific
	,Traumatic
	,Duration
	,Description
	,DiagnosisFamilyId
	,TotalCharactersRequired
	,PlaceholderRequired
FROM src.Icd10DiagnosisVersion
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ICD10ProcedureCode', 'V') IS NOT NULL
    DROP VIEW dbo.ICD10ProcedureCode;
GO

CREATE VIEW dbo.ICD10ProcedureCode
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ICDProcedureCode
	,StartDate
	,EndDate
	,Description
	,PASGrpNo
FROM src.ICD10ProcedureCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.IcdDiagnosisCodeDictionary', 'V') IS NOT NULL
    DROP VIEW dbo.IcdDiagnosisCodeDictionary;
GO

CREATE VIEW dbo.IcdDiagnosisCodeDictionary
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DiagnosisCode
	,IcdVersion
	,StartDate
	,EndDate
	,NonSpecific
	,Traumatic
	,Duration
	,Description
	,DiagnosisFamilyId
	,DiagnosisSeverityId
	,LateralityId
	,TotalCharactersRequired
	,PlaceholderRequired
	,Flags
	,AdditionalDigits
	,Colossus
	,InjuryNatureId
	,EncounterSubcategoryId
FROM src.IcdDiagnosisCodeDictionary
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.IcdDiagnosisCodeDictionaryBodyPart', 'V') IS NOT NULL
    DROP VIEW dbo.IcdDiagnosisCodeDictionaryBodyPart;
GO

CREATE VIEW dbo.IcdDiagnosisCodeDictionaryBodyPart
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DiagnosisCode
	,IcdVersion
	,StartDate
	,NcciBodyPartId
FROM src.IcdDiagnosisCodeDictionaryBodyPart
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.InjuryNature', 'V') IS NOT NULL
    DROP VIEW dbo.InjuryNature;
GO

CREATE VIEW dbo.InjuryNature
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,InjuryNatureId
	,InjuryNaturePriority
	,Description
	,NarrativeInformation
FROM src.InjuryNature
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


 
IF OBJECT_ID('dbo.lkp_SPC', 'V') IS NOT NULL
    DROP VIEW dbo.lkp_SPC;
GO

CREATE VIEW dbo.lkp_SPC
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,lkp_SpcId
	,LongName
	,ShortName
	,Mult
	,NCD92
	,NCD93
	,PlusFour
	,CbreSpecialtyCode
FROM src.lkp_SPC
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.lkp_TS', 'V') IS NOT NULL
    DROP VIEW dbo.lkp_TS;
GO

CREATE VIEW dbo.lkp_TS
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ShortName
	,StartDate
	,EndDate
	,LongName
	,Global
	,AnesMedDirect
	,AffectsPricing
	,IsAssistantSurgery
	,IsCoSurgeon
FROM src.lkp_TS
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.MedicalCodeCutOffs', 'V') IS NOT NULL
    DROP VIEW dbo.MedicalCodeCutOffs;
GO

CREATE VIEW dbo.MedicalCodeCutOffs
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CodeTypeID
	,CodeType
	,Code
	,FormType
	,MaxChargedPerUnit
	,MaxUnitsPerEncounter
FROM src.MedicalCodeCutOffs
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.MedicareStatusIndicatorRule', 'V') IS NOT NULL
    DROP VIEW dbo.MedicareStatusIndicatorRule;
GO

CREATE VIEW dbo.MedicareStatusIndicatorRule
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,MedicareStatusIndicatorRuleId
	,MedicareStatusIndicatorRuleName
	,StatusIndicator
	,StartDate
	,EndDate
	,Endnote
	,EditActionId
	,Comments
FROM src.MedicareStatusIndicatorRule
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.MedicareStatusIndicatorRuleCoverageType', 'V') IS NOT NULL
    DROP VIEW dbo.MedicareStatusIndicatorRuleCoverageType;
GO

CREATE VIEW dbo.MedicareStatusIndicatorRuleCoverageType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,MedicareStatusIndicatorRuleId
	,ShortName
FROM src.MedicareStatusIndicatorRuleCoverageType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.MedicareStatusIndicatorRulePlaceOfService', 'V') IS NOT NULL
    DROP VIEW dbo.MedicareStatusIndicatorRulePlaceOfService;
GO

CREATE VIEW dbo.MedicareStatusIndicatorRulePlaceOfService
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,MedicareStatusIndicatorRuleId
	,PlaceOfService
FROM src.MedicareStatusIndicatorRulePlaceOfService
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.MedicareStatusIndicatorRuleProcedureCode', 'V') IS NOT NULL
    DROP VIEW dbo.MedicareStatusIndicatorRuleProcedureCode;
GO

CREATE VIEW dbo.MedicareStatusIndicatorRuleProcedureCode
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,MedicareStatusIndicatorRuleId
	,ProcedureCode
FROM src.MedicareStatusIndicatorRuleProcedureCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.MedicareStatusIndicatorRuleProviderSpecialty', 'V') IS NOT NULL
    DROP VIEW dbo.MedicareStatusIndicatorRuleProviderSpecialty;
GO

CREATE VIEW dbo.MedicareStatusIndicatorRuleProviderSpecialty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,MedicareStatusIndicatorRuleId
	,ProviderSpecialty
FROM src.MedicareStatusIndicatorRuleProviderSpecialty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ModifierByState', 'V') IS NOT NULL
    DROP VIEW dbo.ModifierByState;
GO

CREATE VIEW dbo.ModifierByState
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,State
	,ProcedureServiceCategoryId
	,ModifierDictionaryId
FROM src.ModifierByState
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ModifierDictionary', 'V') IS NOT NULL
    DROP VIEW dbo.ModifierDictionary;
GO

CREATE VIEW dbo.ModifierDictionary
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ModifierDictionaryId
	,Modifier
	,StartDate
	,EndDate
	,Description
	,Global
	,AnesMedDirect
	,AffectsPricing
	,IsCoSurgeon
	,IsAssistantSurgery
FROM src.ModifierDictionary
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ModifierToProcedureCode', 'V') IS NOT NULL
    DROP VIEW dbo.ModifierToProcedureCode;
GO

CREATE VIEW dbo.ModifierToProcedureCode
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProcedureCode
	,Modifier
	,StartDate
	,EndDate
	,SojFlag
	,RequiresGuidelineReview
	,Reference
	,Comments
FROM src.ModifierToProcedureCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.NcciBodyPart', 'V') IS NOT NULL
    DROP VIEW dbo.NcciBodyPart;
GO

CREATE VIEW dbo.NcciBodyPart
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,NcciBodyPartId
	,Description
	,NarrativeInformation
FROM src.NcciBodyPart
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.NcciBodyPartToHybridBodyPartTranslation', 'V') IS NOT NULL
    DROP VIEW dbo.NcciBodyPartToHybridBodyPartTranslation;
GO

CREATE VIEW dbo.NcciBodyPartToHybridBodyPartTranslation
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,NcciBodyPartId
	,HybridBodyPartId
FROM src.NcciBodyPartToHybridBodyPartTranslation
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ny_pharmacy', 'V') IS NOT NULL
    DROP VIEW dbo.ny_pharmacy;
GO

CREATE VIEW dbo.ny_pharmacy
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,NDCCode
	,StartDate
	,EndDate
	,Description
	,Fee
	,TypeOfDrug
FROM src.ny_pharmacy
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ny_specialty', 'V') IS NOT NULL
    DROP VIEW dbo.ny_specialty;
GO

CREATE VIEW dbo.ny_specialty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RatingCode
	,Desc_
	,CbreSpecialtyCode
FROM src.ny_specialty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.pa_PlaceOfService', 'V') IS NOT NULL
    DROP VIEW dbo.pa_PlaceOfService;
GO

CREATE VIEW dbo.pa_PlaceOfService
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,POS
	,Description
	,Facility
	,MHL
	,PlusFour
	,Institution
FROM src.pa_PlaceOfService
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.PlaceOfServiceDictionary', 'V') IS NOT NULL
    DROP VIEW dbo.PlaceOfServiceDictionary;
GO

CREATE VIEW dbo.PlaceOfServiceDictionary
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PlaceOfServiceCode
	,Description
	,Facility
	,MHL
	,PlusFour
	,Institution
	,StartDate
	,EndDate
FROM src.PlaceOfServiceDictionary
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.PrePpoBillInfo', 'V') IS NOT NULL
    DROP VIEW dbo.PrePpoBillInfo;
GO

CREATE VIEW dbo.PrePpoBillInfo
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DateSentToPPO
	,ClaimNo
	,ClaimIDNo
	,CompanyID
	,OfficeIndex
	,CV_Code
	,DateLoss
	,Deductible
	,PaidCoPay
	,PaidDeductible
	,LossState
	,CmtIDNo
	,CmtCoPaymentMax
	,CmtCoPaymentPercentage
	,CmtDedType
	,CmtDeductible
	,CmtFLCopay
	,CmtPolicyLimit
	,CmtStateOfJurisdiction
	,PvdIDNo
	,PvdTIN
	,PvdSPC_List
	,PvdTitle
	,PvdFlags
	,DateSaved
	,DateRcv
	,InvoiceDate
	,NoLines
	,AmtCharged
	,AmtAllowed
	,Region
	,FeatureID
	,Flags
	,WhoCreate
	,WhoLast
	,CmtPaidDeductible
	,InsPaidLimit
	,StatusFlag
	,CmtPaidCoPay
	,Category
	,CatDesc
	,CreateDate
	,PvdZOS
	,AdmissionDate
	,DischargeDate
	,DischargeStatus
	,TypeOfBill
	,PaymentDecision
	,PPONumberSent
	,BillIDNo
	,LINE_NO
	,LINE_NO_DISP
	,OVER_RIDE
	,DT_SVC
	,PRC_CD
	,UNITS
	,TS_CD
	,CHARGED
	,ALLOWED
	,ANALYZED
	,REF_LINE_NO
	,SUBNET
	,FEE_SCHEDULE
	,POS_RevCode
	,CTGPenalty
	,PrePPOAllowed
	,PPODate
	,PPOCTGPenalty
	,UCRPerUnit
	,FSPerUnit
	,HCRA_Surcharge
	,NDC
	,PriceTypeCode
	,PharmacyLine
	,Endnotes
	,SentryEN
	,CTGEN
	,CTGRuleType
	,CTGRuleID
	,OverrideEN
	,UserId
	,DateOverriden
	,AmountBeforeOverride
	,AmountAfterOverride
	,CodesOverriden
	,NetworkID
	,BillSnapshot
	,PPOSavings
	,RevisedDate
	,ReconsideredDate
	,TierNumber
	,PPOBillInfoID
	,PrePPOBillInfoID
	,CtgCoPayPenalty
	,PpoCtgCoPayPenaltyPercentage
	,CtgVunPenalty
	,PpoCtgVunPenaltyPercentage
FROM src.PrePpoBillInfo
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.prf_COMPANY', 'V') IS NOT NULL
    DROP VIEW dbo.prf_COMPANY;
GO

CREATE VIEW dbo.prf_COMPANY
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CompanyId
	,CompanyName
	,LastChangedOn
FROM src.prf_COMPANY
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.prf_CTGMaxPenaltyLines', 'V') IS NOT NULL
    DROP VIEW dbo.prf_CTGMaxPenaltyLines;
GO

CREATE VIEW dbo.prf_CTGMaxPenaltyLines
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CTGMaxPenLineID
	,ProfileId
	,DatesBasedOn
	,MaxPenaltyPercent
	,StartDate
	,EndDate
FROM src.prf_CTGMaxPenaltyLines
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.prf_CTGPenalty', 'V') IS NOT NULL
    DROP VIEW dbo.prf_CTGPenalty;
GO

CREATE VIEW dbo.prf_CTGPenalty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CTGPenID
	,ProfileId
	,ApplyPreCerts
	,NoPrecertLogged
	,MaxTotalPenalty
	,TurnTimeForAppeals
	,ApplyEndnoteForPercert
	,ApplyEndnoteForCarePath
	,ExemptPrecertPenalty
	,ApplyNetworkPenalty
FROM src.prf_CTGPenalty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.prf_CTGPenaltyHdr', 'V') IS NOT NULL
    DROP VIEW dbo.prf_CTGPenaltyHdr;
GO

CREATE VIEW dbo.prf_CTGPenaltyHdr
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CTGPenHdrID
	,ProfileId
	,PenaltyType
	,PayNegRate
	,PayPPORate
	,DatesBasedOn
	,ApplyPenaltyToPharmacy
	,ApplyPenaltyCondition
FROM src.prf_CTGPenaltyHdr
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.prf_CTGPenaltyLines', 'V') IS NOT NULL
    DROP VIEW dbo.prf_CTGPenaltyLines;
GO

CREATE VIEW dbo.prf_CTGPenaltyLines
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CTGPenLineID
	,ProfileId
	,PenaltyType
	,FeeSchedulePercent
	,StartDate
	,EndDate
	,TurnAroundTime
FROM src.prf_CTGPenaltyLines
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Prf_CustomIcdAction', 'V') IS NOT NULL
    DROP VIEW dbo.Prf_CustomIcdAction;
GO

CREATE VIEW dbo.Prf_CustomIcdAction
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CustomIcdActionId
	,ProfileId
	,IcdVersionId
	,Action
	,StartDate
	,EndDate
FROM src.Prf_CustomIcdAction
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.prf_Office', 'V') IS NOT NULL
    DROP VIEW dbo.prf_Office;
GO

CREATE VIEW dbo.prf_Office
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CompanyId
	,OfficeId
	,OfcNo
	,OfcName
	,OfcAddr1
	,OfcAddr2
	,OfcCity
	,OfcState
	,OfcZip
	,OfcPhone
	,OfcDefault
	,OfcClaimMask
	,OfcTinMask
	,Version
	,OfcEdits
	,OfcCOAEnabled
	,CTGEnabled
	,LastChangedOn
	,AllowMultiCoverage
FROM src.prf_Office
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Prf_OfficeUDF', 'V') IS NOT NULL
    DROP VIEW dbo.Prf_OfficeUDF;
GO

CREATE VIEW dbo.Prf_OfficeUDF
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,OfficeId
	,UDFIdNo
FROM src.Prf_OfficeUDF
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.prf_PPO', 'V') IS NOT NULL
    DROP VIEW dbo.prf_PPO;
GO

CREATE VIEW dbo.prf_PPO
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PPOSysId
	,ProfileId
	,PPOId
	,bStatus
	,StartDate
	,EndDate
	,AutoSend
	,AutoResend
	,BypassMatching
	,UseProviderNetworkEnrollment
	,TieredTypeId
	,Priority
	,PolicyEffectiveDate
	,BillFormType
FROM src.prf_PPO
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.prf_Profile', 'V') IS NOT NULL
    DROP VIEW dbo.prf_Profile;
GO

CREATE VIEW dbo.prf_Profile
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProfileId
	,OfficeId
	,CoverageId
	,StateId
	,AnHeader
	,AnFooter
	,ExHeader
	,ExFooter
	,AnalystEdits
	,DxEdits
	,DxNonTraumaDays
	,DxNonSpecDays
	,PrintCopies
	,NewPvdState
	,bDuration
	,bLimits
	,iDurPct
	,iLimitPct
	,PolicyLimit
	,CoPayPercent
	,CoPayMax
	,Deductible
	,PolicyWarn
	,PolicyWarnPerc
	,FeeSchedules
	,DefaultProfile
	,FeeAncillaryPct
	,iGapdol
	,iGapTreatmnt
	,bGapTreatmnt
	,bGapdol
	,bPrintAdjustor
	,sPrinterName
	,ErEdits
	,ErAllowedDays
	,UcrFsRules
	,LogoIdNo
	,LogoJustify
	,BillLine
	,Version
	,ClaimDeductible
	,IncludeCommitted
	,FLMedicarePercent
	,UseLevelOfServiceUrl
	,LevelOfServiceURL
	,CCIPrimary
	,CCISecondary
	,CCIMutuallyExclusive
	,CCIComprehensiveComponent
	,PayDRGAllowance
	,FLHospEmPriceOn
	,EnableBillRelease
	,DisableSubmitBill
	,MaxPaymentsPerBill
	,NoOfPmtPerBill
	,DefaultDueDate
	,CheckForNJCarePaths
	,NJCarePathPercentFS
	,ApplyEndnoteForNJCarePaths
	,FLMedicarePercent2008
	,RequireEndnoteDuringOverride
	,StorePerUnitFSandUCR
	,UseProviderNetworkEnrollment
	,UseASCRule
	,AsstCoSurgeonEligible
	,LastChangedOn
	,IsNJPhysMedCapAfterCTG
	,IsEligibleAmtFeeBased
	,HideClaimTreeTotalsGrid
	,SortBillsBy
	,SortBillsByOrder
	,ApplyNJEmergencyRoomBenchmarkFee
	,AllowIcd10ForNJCarePaths
	,EnableOverrideDeductible
	,AnalyzeDiagnosisPointers
	,MedicareFeePercent
	,EnableSupplementalNdcData
	,ApplyOriginalNdcAwp
	,NdcAwpNotAvailable
	,PayEapgAllowance
	,MedicareInpatientApcEnabled
	,MedicareOutpatientAscEnabled
	,MedicareAscEnabled
	,UseMedicareInpatientApcFee
	,MedicareInpatientDrgEnabled
	,MedicareInpatientDrgPricingType
	,MedicarePhysicianEnabled
	,MedicareAmbulanceEnabled
	,MedicareDmeposEnabled
	,MedicareAspDrugAndClinicalEnabled
	,MedicareInpatientPricingType
	,MedicareOutpatientPricingRulesEnabled
	,MedicareAscPricingRulesEnabled
	,NjUseAdmitTypeEnabled
	,MedicareClinicalLabEnabled
	,MedicareInpatientEnabled
	,MedicareOutpatientApcEnabled
	,MedicareAspDrugEnabled
	,ShowAllocationsOnEob
	,EmergencyCarePricingRuleId
	,OutOfStatePricingEffectiveDateId
	,PreAllocation
	,AssistantCoSurgeonModifiers
	,AssistantSurgeryModifierNotMedicallyNecessary
	,AssistantSurgeryModifierRequireAdditionalDocument
	,CoSurgeryModifierNotMedicallyNecessary
	,CoSurgeryModifierRequireAdditionalDocument
	,DxNoDiagnosisDays
	,ModifierExempted
FROM src.prf_Profile
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProcedureCodeGroup', 'V') IS NOT NULL
    DROP VIEW dbo.ProcedureCodeGroup;
GO

CREATE VIEW dbo.ProcedureCodeGroup
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProcedureCode
	,MajorCategory
	,MinorCategory
FROM src.ProcedureCodeGroup
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProcedureServiceCategory', 'V') IS NOT NULL
    DROP VIEW dbo.ProcedureServiceCategory;
GO

CREATE VIEW dbo.ProcedureServiceCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProcedureServiceCategoryId
	,ProcedureServiceCategoryName
	,ProcedureServiceCategoryDescription
	,LegacyTableName
	,LegacyBitValue
FROM src.ProcedureServiceCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.PROVIDER', 'V') IS NOT NULL
    DROP VIEW dbo.PROVIDER;
GO

CREATE VIEW dbo.PROVIDER
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PvdIDNo
	,PvdMID
	,PvdSource
	,PvdTIN
	,PvdLicNo
	,PvdCertNo
	,PvdLastName
	,PvdFirstName
	,PvdMI
	,PvdTitle
	,PvdGroup
	,PvdAddr1
	,PvdAddr2
	,PvdCity
	,PvdState
	,PvdZip
	,PvdZipPerf
	,PvdPhone
	,PvdFAX
	,PvdSPC_List
	,PvdAuthNo
	,PvdSPC_ACD
	,PvdUpdateCounter
	,PvdPPO_Provider
	,PvdFlags
	,PvdERRate
	,PvdSubNet
	,InUse
	,PvdStatus
	,PvdElectroStartDate
	,PvdElectroEndDate
	,PvdAccredStartDate
	,PvdAccredEndDate
	,PvdRehabStartDate
	,PvdRehabEndDate
	,PvdTraumaStartDate
	,PvdTraumaEndDate
	,OPCERT
	,PvdDentalStartDate
	,PvdDentalEndDate
	,PvdNPINo
	,PvdCMSId
	,CreateDate
	,LastChangedOn
FROM src.PROVIDER
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProviderCluster', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderCluster;
GO

CREATE VIEW dbo.ProviderCluster
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PvdIDNo
	,OrgOdsCustomerId
	,MitchellProviderKey
	,ProviderClusterKey
	,ProviderType
FROM src.ProviderCluster
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProviderNetworkEventLog', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderNetworkEventLog;
GO

CREATE VIEW dbo.ProviderNetworkEventLog
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,IDField
	,LogDate
	,EventId
	,ClaimIdNo
	,BillIdNo
	,UserId
	,NetworkId
	,FileName
	,ExtraText
	,ProcessInfo
	,TieredTypeID
	,TierNumber
FROM src.ProviderNetworkEventLog
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProviderNumberCriteria', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderNumberCriteria;
GO

CREATE VIEW dbo.ProviderNumberCriteria
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderNumberCriteriaId
	,ProviderNumber
	,Priority
	,FeeScheduleTable
	,StartDate
	,EndDate
FROM src.ProviderNumberCriteria
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProviderNumberCriteriaRevenueCode', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderNumberCriteriaRevenueCode;
GO

CREATE VIEW dbo.ProviderNumberCriteriaRevenueCode
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderNumberCriteriaId
	,RevenueCode
	,MatchingProfileNumber
	,AttributeMatchTypeId
FROM src.ProviderNumberCriteriaRevenueCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProviderNumberCriteriaTypeOfBill', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderNumberCriteriaTypeOfBill;
GO

CREATE VIEW dbo.ProviderNumberCriteriaTypeOfBill
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderNumberCriteriaId
	,TypeOfBill
	,MatchingProfileNumber
	,AttributeMatchTypeId
FROM src.ProviderNumberCriteriaTypeOfBill
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProviderSpecialty', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderSpecialty;
GO

CREATE VIEW dbo.ProviderSpecialty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderId
	,SpecialtyCode
FROM src.ProviderSpecialty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ProviderSpecialtyToProvType', 'V') IS NOT NULL
    DROP VIEW dbo.ProviderSpecialtyToProvType;
GO

CREATE VIEW dbo.ProviderSpecialtyToProvType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProviderType
	,ProviderType_Desc
	,Specialty
	,Specialty_Desc
	,CreateDate
	,ModifyDate
	,LogicalDelete
FROM src.ProviderSpecialtyToProvType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Provider_ClientRef', 'V') IS NOT NULL
    DROP VIEW dbo.Provider_ClientRef;
GO

CREATE VIEW dbo.Provider_ClientRef
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PvdIdNo
	,ClientRefId
	,ClientRefId2
FROM src.Provider_ClientRef
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Provider_Rendering', 'V') IS NOT NULL
    DROP VIEW dbo.Provider_Rendering;
GO

CREATE VIEW dbo.Provider_Rendering
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PvdIDNo
	,RenderingAddr1
	,RenderingAddr2
	,RenderingCity
	,RenderingState
	,RenderingZip
FROM src.Provider_Rendering
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ReferenceBillApcLines', 'V') IS NOT NULL
    DROP VIEW dbo.ReferenceBillApcLines;
GO

CREATE VIEW dbo.ReferenceBillApcLines
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,Line_No
	,PaymentAPC
	,ServiceIndicator
	,PaymentIndicator
	,OutlierAmount
	,PricerAllowed
	,MedicareAmount
FROM src.ReferenceBillApcLines
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ReferenceSupplementBillApcLines', 'V') IS NOT NULL
    DROP VIEW dbo.ReferenceSupplementBillApcLines;
GO

CREATE VIEW dbo.ReferenceSupplementBillApcLines
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,SeqNo
	,Line_No
	,PaymentAPC
	,ServiceIndicator
	,PaymentIndicator
	,OutlierAmount
	,PricerAllowed
	,MedicareAmount
FROM src.ReferenceSupplementBillApcLines
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.RenderingNpiStates', 'V') IS NOT NULL
    DROP VIEW dbo.RenderingNpiStates;
GO

CREATE VIEW dbo.RenderingNpiStates
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ApplicationSettingsId
	,State
FROM src.RenderingNpiStates
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.RevenueCode', 'V') IS NOT NULL
    DROP VIEW dbo.RevenueCode;
GO

CREATE VIEW dbo.RevenueCode
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RevenueCode
	,RevenueCodeSubCategoryId
FROM src.RevenueCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.RevenueCodeCategory', 'V') IS NOT NULL
    DROP VIEW dbo.RevenueCodeCategory;
GO

CREATE VIEW dbo.RevenueCodeCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RevenueCodeCategoryId
	,Description
	,NarrativeInformation
FROM src.RevenueCodeCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.RevenueCodeSubCategory', 'V') IS NOT NULL
    DROP VIEW dbo.RevenueCodeSubCategory;
GO

CREATE VIEW dbo.RevenueCodeSubCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RevenueCodeSubcategoryId
	,RevenueCodeCategoryId
	,Description
	,NarrativeInformation
FROM src.RevenueCodeSubCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.RPT_RsnCategories', 'V') IS NOT NULL
    DROP VIEW dbo.RPT_RsnCategories;
GO

CREATE VIEW dbo.RPT_RsnCategories
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CategoryIdNo
	,CatDesc
	,Priority
FROM src.RPT_RsnCategories
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Rsn_Override', 'V') IS NOT NULL
    DROP VIEW dbo.Rsn_Override;
GO

CREATE VIEW dbo.Rsn_Override
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,ShortDesc
	,LongDesc
	,CategoryIdNo
	,ClientSpec
	,COAIndex
	,NJPenaltyPct
	,NetworkID
	,SpecialProcessing
FROM src.Rsn_Override
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.rsn_REASONS', 'V') IS NOT NULL
    DROP VIEW dbo.rsn_REASONS;
GO

CREATE VIEW dbo.rsn_REASONS
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,CV_Type
	,ShortDesc
	,LongDesc
	,CategoryIdNo
	,COAIndex
	,OverrideEndnote
	,HardEdit
	,SpecialProcessing
	,EndnoteActionId
	,RetainForEapg
FROM src.rsn_REASONS
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Rsn_Reasons_3rdParty', 'V') IS NOT NULL
    DROP VIEW dbo.Rsn_Reasons_3rdParty;
GO

CREATE VIEW dbo.Rsn_Reasons_3rdParty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ReasonNumber
	,ShortDesc
	,LongDesc
FROM src.Rsn_Reasons_3rdParty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.RuleType', 'V') IS NOT NULL
    DROP VIEW dbo.RuleType;
GO

CREATE VIEW dbo.RuleType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RuleTypeID
	,Name
	,Description
FROM src.RuleType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ScriptAdvisorBillSource', 'V') IS NOT NULL
    DROP VIEW dbo.ScriptAdvisorBillSource;
GO

CREATE VIEW dbo.ScriptAdvisorBillSource
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillSourceId
	,BillSource
FROM src.ScriptAdvisorBillSource
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ScriptAdvisorSettings', 'V') IS NOT NULL
    DROP VIEW dbo.ScriptAdvisorSettings;
GO

CREATE VIEW dbo.ScriptAdvisorSettings
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ScriptAdvisorSettingsId
	,IsPharmacyEligible
	,EnableSendCardToClaimant
	,EnableBillSource
FROM src.ScriptAdvisorSettings
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ScriptAdvisorSettingsCoverageType', 'V') IS NOT NULL
    DROP VIEW dbo.ScriptAdvisorSettingsCoverageType;
GO

CREATE VIEW dbo.ScriptAdvisorSettingsCoverageType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ScriptAdvisorSettingsId
	,CoverageType
FROM src.ScriptAdvisorSettingsCoverageType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SEC_RightGroups', 'V') IS NOT NULL
    DROP VIEW dbo.SEC_RightGroups;
GO

CREATE VIEW dbo.SEC_RightGroups
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RightGroupId
	,RightGroupName
	,RightGroupDescription
	,CreatedDate
	,CreatedBy
FROM src.SEC_RightGroups
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SEC_Users', 'V') IS NOT NULL
    DROP VIEW dbo.SEC_Users;
GO

CREATE VIEW dbo.SEC_Users
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,UserId
	,LoginName
	,Password
	,CreatedBy
	,CreatedDate
	,UserStatus
	,FirstName
	,LastName
	,AccountLocked
	,LockedCounter
	,PasswordCreateDate
	,PasswordCaseFlag
	,ePassword
	,CurrentSettings
FROM src.SEC_Users
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SEC_User_OfficeGroups', 'V') IS NOT NULL
    DROP VIEW dbo.SEC_User_OfficeGroups;
GO

CREATE VIEW dbo.SEC_User_OfficeGroups
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SECUserOfficeGroupId
	,UserId
	,OffcGroupId
FROM src.SEC_User_OfficeGroups
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SEC_User_RightGroups', 'V') IS NOT NULL
    DROP VIEW dbo.SEC_User_RightGroups;
GO

CREATE VIEW dbo.SEC_User_RightGroups
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SECUserRightGroupId
	,UserId
	,RightGroupId
FROM src.SEC_User_RightGroups
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SentryRuleTypeCriteria', 'V') IS NOT NULL
    DROP VIEW dbo.SentryRuleTypeCriteria;
GO

CREATE VIEW dbo.SentryRuleTypeCriteria
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RuleTypeId
	,CriteriaId
FROM src.SentryRuleTypeCriteria
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SENTRY_ACTION', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_ACTION;
GO

CREATE VIEW dbo.SENTRY_ACTION
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ActionID
	,Name
	,Description
	,CompatibilityKey
	,PredefinedValues
	,ValueDataType
	,ValueFormat
	,BillLineAction
	,AnalyzeFlag
	,ActionCategoryIDNo
FROM src.SENTRY_ACTION
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SENTRY_ACTION_CATEGORY', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_ACTION_CATEGORY;
GO

CREATE VIEW dbo.SENTRY_ACTION_CATEGORY
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ActionCategoryIDNo
	,Description
FROM src.SENTRY_ACTION_CATEGORY
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SENTRY_CRITERIA', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_CRITERIA;
GO

CREATE VIEW dbo.SENTRY_CRITERIA
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CriteriaID
	,ParentName
	,Name
	,Description
	,Operators
	,PredefinedValues
	,ValueDataType
	,ValueFormat
	,NullAllowed
FROM src.SENTRY_CRITERIA
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SENTRY_PROFILE_RULE', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_PROFILE_RULE;
GO

CREATE VIEW dbo.SENTRY_PROFILE_RULE
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProfileID
	,RuleID
	,Priority
FROM src.SENTRY_PROFILE_RULE
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SENTRY_RULE', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_RULE;
GO

CREATE VIEW dbo.SENTRY_RULE
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RuleID
	,Name
	,Description
	,CreatedBy
	,CreationDate
	,PostFixNotation
	,Priority
	,RuleTypeID
FROM src.SENTRY_RULE
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SENTRY_RULE_ACTION_DETAIL', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_RULE_ACTION_DETAIL;
GO

CREATE VIEW dbo.SENTRY_RULE_ACTION_DETAIL
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RuleID
	,LineNumber
	,ActionID
	,ActionValue
FROM src.SENTRY_RULE_ACTION_DETAIL
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SENTRY_RULE_ACTION_HEADER', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_RULE_ACTION_HEADER;
GO

CREATE VIEW dbo.SENTRY_RULE_ACTION_HEADER
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RuleID
	,EndnoteShort
	,EndnoteLong
FROM src.SENTRY_RULE_ACTION_HEADER
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SENTRY_RULE_CONDITION', 'V') IS NOT NULL
    DROP VIEW dbo.SENTRY_RULE_CONDITION;
GO

CREATE VIEW dbo.SENTRY_RULE_CONDITION
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RuleID
	,LineNumber
	,GroupFlag
	,CriteriaID
	,Operator
	,ConditionValue
	,AndOr
	,UdfConditionId
FROM src.SENTRY_RULE_CONDITION
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SPECIALTY', 'V') IS NOT NULL
    DROP VIEW dbo.SPECIALTY;
GO

CREATE VIEW dbo.SPECIALTY
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SpcIdNo
	,Code
	,Description
	,PayeeSubTypeID
	,TieredTypeID
FROM src.SPECIALTY
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.StateSettingMedicare', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingMedicare;
GO

CREATE VIEW dbo.StateSettingMedicare
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingMedicareId
	,PayPercentOfMedicareFee
FROM src.StateSettingMedicare
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.StateSettingsFlorida', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsFlorida;
GO

CREATE VIEW dbo.StateSettingsFlorida
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingsFloridaId
	,ClaimantInitialServiceOption
	,ClaimantInitialServiceDays
FROM src.StateSettingsFlorida
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.StateSettingsHawaii', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsHawaii;
GO

CREATE VIEW dbo.StateSettingsHawaii
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingsHawaiiId
	,PhysicalMedicineLimitOption
FROM src.StateSettingsHawaii
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.StateSettingsNewJersey', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsNewJersey;
GO

CREATE VIEW dbo.StateSettingsNewJersey
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingsNewJerseyId
	,ByPassEmergencyServices
FROM src.StateSettingsNewJersey
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.StateSettingsNewJerseyPolicyPreference', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsNewJerseyPolicyPreference;
GO

CREATE VIEW dbo.StateSettingsNewJerseyPolicyPreference
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PolicyPreferenceId
	,ShareCoPayMaximum
FROM src.StateSettingsNewJerseyPolicyPreference
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.StateSettingsNewYorkPolicyPreference', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsNewYorkPolicyPreference;
GO

CREATE VIEW dbo.StateSettingsNewYorkPolicyPreference
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PolicyPreferenceId
	,ShareCoPayMaximum
FROM src.StateSettingsNewYorkPolicyPreference
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.StateSettingsNY', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsNY;
GO

CREATE VIEW dbo.StateSettingsNY
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingsNYID
	,NF10PrintDate
	,NF10CheckBox1
	,NF10CheckBox18
	,NF10UseUnderwritingCompany
	,UnderwritingCompanyUdfId
	,NaicUdfId
	,DisplayNYPrintOptionsWhenZosOrSojIsNY
	,NF10DuplicatePrint
FROM src.StateSettingsNY
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.StateSettingsNyRoomRate', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsNyRoomRate;
GO

CREATE VIEW dbo.StateSettingsNyRoomRate
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingsNyRoomRateId
	,StartDate
	,EndDate
	,RoomRate
FROM src.StateSettingsNyRoomRate
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.StateSettingsOregon', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsOregon;
GO

CREATE VIEW dbo.StateSettingsOregon
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingsOregonId
	,ApplyOregonFeeSchedule
FROM src.StateSettingsOregon
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.StateSettingsOregonCoverageType', 'V') IS NOT NULL
    DROP VIEW dbo.StateSettingsOregonCoverageType;
GO

CREATE VIEW dbo.StateSettingsOregonCoverageType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StateSettingsOregonId
	,CoverageType
FROM src.StateSettingsOregonCoverageType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SupplementBillApportionmentEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.SupplementBillApportionmentEndnote;
GO

CREATE VIEW dbo.SupplementBillApportionmentEndnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillId
	,SequenceNumber
	,LineNumber
	,Endnote
FROM src.SupplementBillApportionmentEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SupplementBillCustomEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.SupplementBillCustomEndnote;
GO

CREATE VIEW dbo.SupplementBillCustomEndnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillId
	,SequenceNumber
	,LineNumber
	,Endnote
FROM src.SupplementBillCustomEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SupplementBill_Pharm_ApportionmentEndnote', 'V') IS NOT NULL
    DROP VIEW dbo.SupplementBill_Pharm_ApportionmentEndnote;
GO

CREATE VIEW dbo.SupplementBill_Pharm_ApportionmentEndnote
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillId
	,SequenceNumber
	,LineNumber
	,Endnote
FROM src.SupplementBill_Pharm_ApportionmentEndnote
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SupplementPreCtgDeniedLinesEligibleToPenalty', 'V') IS NOT NULL
    DROP VIEW dbo.SupplementPreCtgDeniedLinesEligibleToPenalty;
GO

CREATE VIEW dbo.SupplementPreCtgDeniedLinesEligibleToPenalty
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,LineNumber
	,CtgPenaltyTypeId
	,SeqNo
FROM src.SupplementPreCtgDeniedLinesEligibleToPenalty
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.SurgicalModifierException', 'V') IS NOT NULL
    DROP VIEW dbo.SurgicalModifierException;
GO

CREATE VIEW dbo.SurgicalModifierException
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Modifier
	,State
	,CoverageType
	,StartDate
	,EndDate
FROM src.SurgicalModifierException
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UB_APC_DICT', 'V') IS NOT NULL
    DROP VIEW dbo.UB_APC_DICT;
GO

CREATE VIEW dbo.UB_APC_DICT
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,StartDate
	,EndDate
	,APC
	,Description
FROM src.UB_APC_DICT
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UB_BillType', 'V') IS NOT NULL
    DROP VIEW dbo.UB_BillType;
GO

CREATE VIEW dbo.UB_BillType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TOB
	,Description
	,Flag
	,UB_BillTypeID
FROM src.UB_BillType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UB_RevenueCodes', 'V') IS NOT NULL
    DROP VIEW dbo.UB_RevenueCodes;
GO

CREATE VIEW dbo.UB_RevenueCodes
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,RevenueCode
	,StartDate
	,EndDate
	,PRC_DESC
	,Flags
	,Vague
	,PerVisit
	,PerClaimant
	,PerProvider
	,BodyFlags
	,DrugFlag
	,CurativeFlag
	,RevenueCodeSubCategoryId
FROM src.UB_RevenueCodes
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UDFBill', 'V') IS NOT NULL
    DROP VIEW dbo.UDFBill;
GO

CREATE VIEW dbo.UDFBill
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,BillIdNo
	,UDFIdNo
	,UDFValueText
	,UDFValueDecimal
	,UDFValueDate
FROM src.UDFBill
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UDFClaim', 'V') IS NOT NULL
    DROP VIEW dbo.UDFClaim;
GO

CREATE VIEW dbo.UDFClaim
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ClaimIdNo
	,UDFIdNo
	,UDFValueText
	,UDFValueDecimal
	,UDFValueDate
FROM src.UDFClaim
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UDFClaimant', 'V') IS NOT NULL
    DROP VIEW dbo.UDFClaimant;
GO

CREATE VIEW dbo.UDFClaimant
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,CmtIdNo
	,UDFIdNo
	,UDFValueText
	,UDFValueDecimal
	,UDFValueDate
FROM src.UDFClaimant
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UdfDataFormat', 'V') IS NOT NULL
    DROP VIEW dbo.UdfDataFormat;
GO

CREATE VIEW dbo.UdfDataFormat
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,UdfDataFormatId
	,DataFormatName
FROM src.UdfDataFormat
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UDFLevelChangeTracking', 'V') IS NOT NULL
    DROP VIEW dbo.UDFLevelChangeTracking;
GO

CREATE VIEW dbo.UDFLevelChangeTracking
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,UDFLevelChangeTrackingId
	,EntityType
	,EntityId
	,CorrelationId
	,UDFId
	,PreviousValue
	,UpdatedValue
	,UserId
	,ChangeDate
FROM src.UDFLevelChangeTracking
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UDFLibrary', 'V') IS NOT NULL
    DROP VIEW dbo.UDFLibrary;
GO

CREATE VIEW dbo.UDFLibrary
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,UDFIdNo
	,UDFName
	,ScreenType
	,UDFDescription
	,DataFormat
	,RequiredField
	,ReadOnly
	,Invisible
	,TextMaxLength
	,TextMask
	,TextEnforceLength
	,RestrictRange
	,MinValDecimal
	,MaxValDecimal
	,MinValDate
	,MaxValDate
	,ListAllowMultiple
	,DefaultValueText
	,DefaultValueDecimal
	,DefaultValueDate
	,UseDefault
	,ReqOnSubmit
	,IncludeDateButton
FROM src.UDFLibrary
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UDFListValues', 'V') IS NOT NULL
    DROP VIEW dbo.UDFListValues;
GO

CREATE VIEW dbo.UDFListValues
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ListValueIdNo
	,UDFIdNo
	,SeqNo
	,ListValue
	,DefaultValue
FROM src.UDFListValues
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UDFProvider', 'V') IS NOT NULL
    DROP VIEW dbo.UDFProvider;
GO

CREATE VIEW dbo.UDFProvider
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PvdIdNo
	,UDFIdNo
	,UDFValueText
	,UDFValueDecimal
	,UDFValueDate
FROM src.UDFProvider
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UDFViewOrder', 'V') IS NOT NULL
    DROP VIEW dbo.UDFViewOrder;
GO

CREATE VIEW dbo.UDFViewOrder
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,OfficeId
	,UDFIdNo
	,ViewOrder
FROM src.UDFViewOrder
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.UDF_Sentry_Criteria', 'V') IS NOT NULL
    DROP VIEW dbo.UDF_Sentry_Criteria;
GO

CREATE VIEW dbo.UDF_Sentry_Criteria
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,UdfIdNo
	,CriteriaID
	,ParentName
	,Name
	,Description
	,Operators
	,PredefinedValues
	,ValueDataType
	,ValueFormat
FROM src.UDF_Sentry_Criteria
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Vpn', 'V') IS NOT NULL
    DROP VIEW dbo.Vpn;
GO

CREATE VIEW dbo.Vpn
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,VpnId
	,NetworkName
	,PendAndSend
	,BypassMatching
	,AllowsResends
	,OdsEligible
FROM src.Vpn
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.VPNActivityFlag', 'V') IS NOT NULL
    DROP VIEW dbo.VPNActivityFlag;
GO

CREATE VIEW dbo.VPNActivityFlag
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Activity_Flag
	,AF_Description
	,AF_ShortDesc
	,Data_Source
	,Default_Billable
	,Credit
FROM src.VPNActivityFlag
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.VpnBillableFlags', 'V') IS NOT NULL
    DROP VIEW dbo.VpnBillableFlags;
GO

CREATE VIEW dbo.VpnBillableFlags
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SOJ
	,NetworkID
	,ActivityFlag
	,Billable
	,CompanyCode
	,CompanyName
FROM src.VpnBillableFlags
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.VpnBillingCategory', 'V') IS NOT NULL
    DROP VIEW dbo.VpnBillingCategory;
GO

CREATE VIEW dbo.VpnBillingCategory
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,VpnBillingCategoryCode
	,VpnBillingCategoryDescription
FROM src.VpnBillingCategory
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.VpnLedger', 'V') IS NOT NULL
    DROP VIEW dbo.VpnLedger;
GO

CREATE VIEW dbo.VpnLedger
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TransactionID
	,TransactionTypeID
	,BillIdNo
	,Line_No
	,Charged
	,DPAllowed
	,VPNAllowed
	,Savings
	,Credits
	,HasOverride
	,EndNotes
	,NetworkIdNo
	,ProcessFlag
	,LineType
	,DateTimeStamp
	,SeqNo
	,VPN_Ref_Line_No
	,SpecialProcessing
	,CreateDate
	,LastChangedOn
	,AdjustedCharged
FROM src.VpnLedger
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.VpnProcessFlagType', 'V') IS NOT NULL
    DROP VIEW dbo.VpnProcessFlagType;
GO

CREATE VIEW dbo.VpnProcessFlagType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,VpnProcessFlagTypeId
	,VpnProcessFlagType
FROM src.VpnProcessFlagType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.VpnSavingTransactionType', 'V') IS NOT NULL
    DROP VIEW dbo.VpnSavingTransactionType;
GO

CREATE VIEW dbo.VpnSavingTransactionType
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,VpnSavingTransactionTypeId
	,VpnSavingTransactionType
FROM src.VpnSavingTransactionType
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Vpn_Billing_History', 'V') IS NOT NULL
    DROP VIEW dbo.Vpn_Billing_History;
GO

CREATE VIEW dbo.Vpn_Billing_History
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Customer
	,TransactionID
	,Period
	,ActivityFlag
	,BillableFlag
	,Void
	,CreditType
	,Network
	,BillIdNo
	,Line_No
	,TransactionDate
	,RepriceDate
	,ClaimNo
	,ProviderCharges
	,DPAllowed
	,VPNAllowed
	,Savings
	,Credits
	,NetSavings
	,SOJ
	,seqno
	,CompanyCode
	,VpnId
	,ProcessFlag
	,SK
	,DATABASE_NAME
	,SubmittedToFinance
	,IsInitialLoad
	,VpnBillingCategoryCode
FROM src.Vpn_Billing_History
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.WeekEndsAndHolidays', 'V') IS NOT NULL
    DROP VIEW dbo.WeekEndsAndHolidays;
GO

CREATE VIEW dbo.WeekEndsAndHolidays
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DayOfWeekDate
	,DayName
	,WeekEndsAndHolidayId
FROM src.WeekEndsAndHolidays
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.Zip2County', 'V') IS NOT NULL
    DROP VIEW dbo.Zip2County;
GO

CREATE VIEW dbo.Zip2County
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,Zip
	,County
	,State
FROM src.Zip2County
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


IF OBJECT_ID('dbo.ZipCode', 'V') IS NOT NULL
    DROP VIEW dbo.ZipCode;
GO

CREATE VIEW dbo.ZipCode
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ZipCode
	,PrimaryRecord
	,STATE
	,City
	,CityAlias
	,County
	,Cbsa
	,CbsaType
	,ZipCodeRegionId
FROM src.ZipCode
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


 
 
