
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerGreenwichData') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerGreenwichData

GO

CREATE PROCEDURE dbo.ProviderDataExplorerGreenwichData (@ReportId INT,
@SourceDatabaseName VARCHAR(250) = 'AcsOds',
@TargetDatabaseName VARCHAR(250) = 'ReportDB')
AS
BEGIN
DECLARE @AuditFor VARCHAR(30),
		@ProcessName VARCHAR(50),
		@OdsPostingGroupAuditId INT;


SET @AuditFor='OdsCustomerId : 0';

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerEtlAuditStart @AuditFor,@ProcessName,@OdsPostingGroupAuditId,@ReportId;

DECLARE @SQLQuery VARCHAR(MAX) 
SET @SQLQuery=  CAST('' AS VARCHAR(MAX))+
	'
	-- Customers used to generate Greenwich data: AAA Michigan, Esurance, Sentry

	-- Inserting ClaimantHeader data for Greenwich

	DELETE FROM ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerClaimantHeader
	WHERE OdsCustomerId in (0)

	IF OBJECT_ID(''tempdb..#ClaimantHeader'') IS NOT NULL
		DROP TABLE #ClaimantHeader

	SELECT 
			0 OdsPostingGroupAuditId,
			0 OdsCustomerId,
			 ClaimId,
			 ClaimId AS ClaimNumber,
			 DateLoss,
			 CVCode,
			 LossState,
			 ClaimantId,			 
			 ClaimantState,
			 ClaimantZip,			 
			 ClaimantStateofJurisdiction,
			 CoverageType,
			 ClaimantHeaderId,
			 ProviderId,
			 CreateDate,
			 LastChangedOn,
			 MinimumDateofService,
			 MaximumDateofService,
			 DOSTenureInDays,
			 ExpectedTenureInDays,
			 ExpectedRecoveryDate,
			 ''Greenwich'' CustomerName,
			 InjuryDescription,
			 InjuryNatureId,
			 InjuryNaturePriority,
			 DerivedCVType,
			 DerivedCVDesc,
			 ClaimantZipLat,
			 ClaimantZipLong,
			 MSADesignation,
			 CBSADesignation,
			 CVCodeDesciption,
			 CoverageTypeDescription,
			 RunDate,
			 ROW_NUMBER() OVER(PARTITION BY ClaimantHeaderId order by OdscustomerId) RowNum
	INTO #ClaimantHeader 
    FROM  ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerClaimantHeader cmt 
	WHERE   OdsCustomerId IN (2,19,47 )

	INSERT INTO ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerClaimantHeader(
			OdsPostingGroupAuditId,
			 OdsCustomerId,
			 ClaimId,
			 ClaimNumber,
			 DateLoss,
			 CVCode,
			 LossState,
			 ClaimantId,
			 ClaimantState,
			 ClaimantZip,
			 ClaimantStateofJurisdiction,
			 CoverageType,
			 ClaimantHeaderId,
			 ProviderId,
			 CreateDate,
			 LastChangedOn,
			 MinimumDateofService,
			 MaximumDateofService,
			 DOSTenureInDays,
			 ExpectedTenureInDays,
			 ExpectedRecoveryDate,
			 CustomerName,
			 InjuryDescription,
			 InjuryNatureId,
			 InjuryNaturePriority,
			 DerivedCVType,
			 DerivedCVDesc,
			 ClaimantZipLat,
			 ClaimantZipLong,
			 MSADesignation,
			 CBSADesignation,
			 CVCodeDesciption,
			 CoverageTypeDescription,
			 RunDate
	)
	SELECT 
			OdsPostingGroupAuditId,
			OdsCustomerId,
			 ClaimId,
			 ClaimId AS ClaimNumber,
			 DateLoss,
			 CVCode,
			 LossState,
			 ClaimantId,
			 ClaimantState,
			 ClaimantZip,
			 ClaimantStateofJurisdiction,
			 CoverageType,
			 ClaimantHeaderId,
			 ProviderId,
			 CreateDate,
			 LastChangedOn,
			 MinimumDateofService,
			 MaximumDateofService,
			 DOSTenureInDays,
			 ExpectedTenureInDays,
			 ExpectedRecoveryDate,
			 CustomerName,
			 InjuryDescription,
			 InjuryNatureId,
			 InjuryNaturePriority,
			 DerivedCVType,
			 DerivedCVDesc,
			 ClaimantZipLat,
			 ClaimantZipLong,
			 MSADesignation,
			 CBSADesignation,
			 CVCodeDesciption,
			 CoverageTypeDescription,
			 RunDate	
    FROM  #ClaimantHeader c
	WHERE  RowNum = 1

	-- Inserting BillHeader data for Greenwich
	DELETE FROM ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerBillHeader
	WHERE OdsCustomerId in (0)

	IF OBJECT_ID(''tempdb..#BillHeader'') IS NOT NULL
		DROP TABLE #BillHeader

	SELECT 
			0 OdsPostingGroupAuditId,
			0 OdsCustomerId,
			 BillId,
			 ClaimantHeaderId,
			 DateSaved,
			 ClaimDateLoss,
			 CVType,
			 Flags,
			 CreateDate,
			 ProviderZipofService,
			 TypeofBill,
			 LastChangedOn,
			 CVTypeDescription,
			 RunDate,
			 ROW_NUMBER() OVER(PARTITION BY BillId order by OdscustomerId) RowNum
	INTO #BillHeader		 				
	FROM ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerBillHeader
	WHERE   OdsCustomerId IN (2,19,47 )

	INSERT INTO ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerBillHeader
		(
			 OdsPostingGroupAuditId,
			 OdsCustomerId,
			 BillId,
			 ClaimantHeaderId,
			 DateSaved,
			 ClaimDateLoss,
			 CVType,
			 Flags,
			 CreateDate,
			 ProviderZipofService,
			 TypeofBill,
			 LastChangedOn,
			 CVTypeDescription,
			 RunDate
		)
	SELECT 
			OdsPostingGroupAuditId,
			OdsCustomerId,
			 BillId,
			 ClaimantHeaderId,
			 DateSaved,
			 ClaimDateLoss,
			 CVType,
			 Flags,
			 CreateDate,
			 ProviderZipofService,
			 TypeofBill,
			 LastChangedOn,
			 CVTypeDescription,
			 RunDate							
	FROM #BillHeader
	WHERE RowNum = 1

	-- Inserting BillLine data for Greenwich
	DELETE FROM ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerBillLine
	WHERE OdsCustomerId in (0)

	IF OBJECT_ID(''tempdb..#BillLine'') IS NOT NULL
	DROP TABLE #BillLine

	SELECT 
			0 OdsPostingGroupAuditId,
			0 OdsCustomerId,
			 BillId,
			 LineNumber,
			 OverRide,
			 DateofService,
			 ProcedureCode,
			 Units,
			 Charged,
			 Allowed,
			 Analyzed,
			 RefLineNo,
			 POSRevCode,
			 Adjustment,
			 FormType,
			 CodeType,
			 Code,
			 CodeDescription,
			 Category,
			 SubCategory,
			 BillLineType,
			 BundlingFlag,
			 ExceptionFlag,
			 ExceptionComments,
			 VisitType,
			 BillInjuryDescription,
			 ProviderZoSLat,
			 ProviderZoSLong,
			 ProviderZoSState,
			 ModalityType,
			 ModalityUnitType,
			 RunDate,
			 SubFormType,
			 Modifier,
			 EndNote,			
			 ROW_NUMBER() OVER(PARTITION BY BillId,LineNumber,BillLineType order by OdscustomerId) RowNum
	INTO #BillLine	
	FROM  ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerBillLine b 
	WHERE   OdsCustomerId IN (2,19,47 )

	INSERT INTO ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerBillLine(
			OdsPostingGroupAuditId,
			 OdsCustomerId,
			 BillId,
			 LineNumber,
			 OverRide,
			 DateofService,
			 ProcedureCode,
			 Units,
			 Charged,
			 Allowed,
			 Analyzed,
			 RefLineNo,
			 POSRevCode,
			 Adjustment,
			 FormType,
			 CodeType,
			 Code,
			 CodeDescription,
			 Category,
			 SubCategory,
			 BillLineType,
			 BundlingFlag,
			 ExceptionFlag,
			 ExceptionComments,
			 VisitType,
			 BillInjuryDescription,
			 ProviderZoSLat,
			 ProviderZoSLong,
			 ProviderZoSState,
			 ModalityType,
			 ModalityUnitType,
			 RunDate,
			 SubFormType,
			 Modifier,
			 EndNote					
			)
	SELECT 
			OdsPostingGroupAuditId,
			OdsCustomerId,
			 BillId,
			 LineNumber,
			 OverRide,
			 DateofService,
			 ProcedureCode,
			 Units,
			 Charged,
			 Allowed,
			 Analyzed,
			 RefLineNo,
			 POSRevCode,
			 Adjustment,
			 FormType,
			 CodeType,
			 Code,
			 CodeDescription,
			 Category,
			 SubCategory,
			 BillLineType,
			 BundlingFlag,
			 ExceptionFlag,
			 ExceptionComments,
			 VisitType,
			 BillInjuryDescription,
			 ProviderZoSLat,
			 ProviderZoSLong,
			 ProviderZoSState,
			 ModalityType,
			 ModalityUnitType,
			 RunDate,
			 SubFormType,
			 Modifier,
			 EndNote				
	FROM  #BillLine b 
	WHERE RowNum = 1

	-- Inserting Provider data for Greenwich
	DELETE FROM ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerProvider
	WHERE OdsCustomerId in (0)

	IF OBJECT_ID(''tempdb..#Provider'') IS NOT NULL
		DROP TABLE #Provider

	SELECT 
			0 OdsPostingGroupAuditId,
			0 OdsCustomerId,
			ProviderId,
			ProviderTIN,
			ProviderFirstName, 
			ProviderLastName, 
			ProviderGroup, 
			ProviderState, 
			ProviderZip, 
			ProviderSPCList, 
			ProviderNPINumber, 
			ProviderName, 
			ProviderTypeID, 
			ProviderClusterId, 
			ProviderClusterName, 
			Specialty, 
			ClusterSpecialty, 
			CreatedDate, 
			RunDate,
			ROW_NUMBER() OVER(PARTITION BY ProviderId order by OdscustomerId) RowNum
	INTO #Provider
	FROM  ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerProvider
	WHERE   OdsCustomerId IN (2,19,47)

	INSERT INTO ' + @TargetDatabaseName + '.dbo.ProviderDataExplorerProvider(
			OdsPostingGroupAuditId,
			OdsCustomerId,
			ProviderId,
			ProviderTIN,
			ProviderFirstName, 
			ProviderLastName, 
			ProviderGroup, 
			ProviderState, 
			ProviderZip, 
			ProviderSPCList, 
			ProviderNPINumber, 
			ProviderName, 
			ProviderTypeID, 
			ProviderClusterId, 
			ProviderClusterName, 
			Specialty, 
			ClusterSpecialty, 
			CreatedDate, 
			RunDate	
	)
	SELECT 
			OdsPostingGroupAuditId,
			OdsCustomerId,
			ProviderId,
			ProviderTIN,
			ProviderFirstName, 
			ProviderLastName, 
			ProviderGroup, 
			ProviderState, 
			ProviderZip, 
			ProviderSPCList, 
			ProviderNPINumber, 
			ProviderName, 
			ProviderTypeID, 
			ProviderClusterId, 
			ProviderClusterName, 
			Specialty, 
			ClusterSpecialty, 
			CreatedDate, 
			RunDate
	FROM  #Provider p
	WHERE  RowNum = 1
'
EXEC (@SQLQuery)



-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerEtlAuditEnd @AuditFor,@ProcessName,@OdsPostingGroupAuditId,@ReportId;

END


GO

