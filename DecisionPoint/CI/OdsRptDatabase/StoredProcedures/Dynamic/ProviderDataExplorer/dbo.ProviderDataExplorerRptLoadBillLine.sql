

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsRptLoadBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsRptLoadBillLine

GO 

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerRptLoadBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerRptLoadBillLine

GO 

CREATE PROCEDURE dbo.ProviderDataExplorerRptLoadBillLine(
@SourceDatabaseName VARCHAR(50),
@SnapshotAsOf AS DATETIME,
@IsIncrementalLoad INT,
@Debug BIT,
@ReportId INT,
@OdsCustomerId INT)
AS
BEGIN

DECLARE @OdsPostingGroupAuditId INT,
		@ProcessName VARCHAR(50),
		@AuditFor Varchar(100),
		@PostingGroupAuditIdQuery NVARCHAR(MAX);

DECLARE @PostingIdTable TABLE (PostingId INT);

-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : '+CAST(@OdsCustomerId AS VARCHAR(3));

-- Get the latest OdsPostingGroupAuditId from Source adm.PostingGroupAudit
SET @PostingGroupAuditIdQuery = N'SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerId AS VARCHAR(3))+','''+LEFT(CONVERT(VARCHAR,@SnapshotAsOf,110),10)+''')';
INSERT INTO @PostingIdTable EXEC (@PostingGroupAuditIdQuery)
SELECT @OdsPostingGroupAuditId = PostingId FROM @PostingIdTable;

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerEtlAuditStart @AuditFor,@ProcessName,@OdsPostingGroupAuditId,@ReportId;

DECLARE @SQLScript VARCHAR(MAX),
		@RunFromOdsPostingGroupAuditId INT;

-- Get OdsPostingGroupAuditId from ETLAudit table for Incremental Load
SET @RunFromOdsPostingGroupAuditId = dbo.GetMaxRunFromOdsPostingGroupAuditId(@ProcessName,@AuditFor,@ReportId);

SET @SQLScript = CAST('' AS VARCHAR(MAX)) + 
'
DECLARE @ODSPAPRDesc VARCHAR(100),
		@ODSPAPRCategory VARCHAR(100),
		@ODSPAPRSubCategory VARCHAR(100),		
		@ODSPAPRDescPharma VARCHAR(100),
		@ODSPAPRCategoryPharma VARCHAR(100),
		@ODSPAPRSubCategoryPharma VARCHAR(100);

		SELECT @ODSPAPRDesc = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRDesc''
		SELECT @ODSPAPRCategory = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRCategory''
		SELECT @ODSPAPRSubCategory = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRSubCategory''
		SELECT @ODSPAPRDescPharma = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRDescPharma''
		SELECT @ODSPAPRCategoryPharma = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRCategoryPharma''
		SELECT @ODSPAPRSubCategoryPharma = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRSubCategoryPharma''
'+
	CASE 
		WHEN  @IsIncrementalLoad = 1 THEN		
--Incremental Load
-- Update all the records coming from staging and insert the new records to destination
'
UPDATE d 
SET		
			d.OverRide = s.OverRide,
			d.DateofService = s.DTSVC,
			d.ProcedureCode = s.PRCCD,
			d.Units = ISNULL(s.Units,0),
			d.Charged = s.Charged,
			d.Allowed = s.Allowed,
			d.Analyzed = s.Analyzed,
			d.RefLineNo = s.RefLineNo,
			d.POSRevCode = s.POSRevCode,
			d.Adjustment = s.Adjustment,
			d.FormType = s.FormType,
			d.CodeType = CASE WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 1 THEN ISNULL(ndcchy.CodeType,@ODSPAPRDesc)
							  WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 0 THEN ISNULL(chy.CodeType,@ODSPAPRDesc)
						      WHEN s.CodeType = ''Revenue'' THEN ISNULL(s.CodeType,@ODSPAPRDesc)
							  ELSE ISNULL(s.CodeType,@ODSPAPRDesc) END ,
			d.Code = s.Code,
			d.CodeDescription = CASE WHEN s.CodeType = ''NDC'' AND s.IsCodeNumeric = 0 THEN ISNULL(ndcchy.Description,@ODSPAPRDesc)
									 WHEN s.CodeType = ''NDC'' AND s.IsCodeNumeric = 1 THEN ISNULL(chy.Description,@ODSPAPRDesc)
									 WHEN s.CodeType IN (''Procedure'',''Revenue'') THEN ISNULL(s.CodeDescription,@ODSPAPRDesc)
									 END,
			d.Category = CASE WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 0 THEN ISNULL(chy.Category,@ODSPAPRCategory)
							  WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 1 THEN ISNULL(ndcchy.Category,@ODSPAPRCategory)
							  WHEN s.CodeType = ''Revenue'' THEN ISNULL(s.CodeCategory,@ODSPAPRCategory)
							  END ,
			d.SubCategory = CASE WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 0 THEN ISNULL(chy.SubCategory,@ODSPAPRSubCategory)
								 WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 1 THEN ISNULL(ndcchy.SubCategory,@ODSPAPRSubCategory)
								 WHEN s.CodeType = ''Revenue'' THEN ISNULL(s.CodeSubCategory,@ODSPAPRSubCategory)
								 END,
			d.BillLineType = s.BillLineType,
			d.BundlingFlag = s.BundlingFlag,
			d.ExceptionFlag = s.ExceptionFlag,
			d.ExceptionComments = s.ExceptionComments,
			d.VisitType = cm1.CodeCategory,
			d.ProviderZoSLat = zc.Lat,
			d.ProviderZoSLong = zc.Long,
			d.ProviderZoSState = zc.State,
			d.ModalityType = cm2.CodeCategory,
			d.ModalityUnitType = CASE WHEN cm2.CodeSubCategory = ''Timed''	AND s.Units >= 1 THEN ''Timed'' 
									  WHEN cm2.CodeSubCategory = ''UnTimed'' AND s.Units > 1 THEN ''UnTimed''
				                      ELSE ''Other'' END,		
			d.RunDate = GETDATE(),
			d.SubFormType = ISNULL(UPPER(s.SubFormType),''N/A''),
			d.BillInjuryDescription = s.BillInjuryDescription,
			d.Modifier = s.Modifier,
			d.EndNote = s.EndNote
FROM dbo.ProviderDataExplorerBillLine d 
	INNER JOIN stg.ProviderDataExplorerBillLine s ON s.BillIdNo = d.BillId
											 AND s.LineNumber = d.LineNumber
											 AND s.BillLineType = d.BillLineType
											 AND s.OdsCustomerId = d.OdsCustomerId
																					 
	LEFT JOIN rpt.ProviderDataExplorerZipCode zc ON SUBSTRING(s.ProviderZipOfService,1,5) = SUBSTRING(zc.zipcode,1,5)
	LEFT JOIN (SELECT CodeStart,
			          CodeEnd,
			          Category,
			          SubCategory,
			          Description,
			          CodeType,
			          IsCodeNumeric
			    FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 0 ) chy ON s.Code BETWEEN chy.CodeStart AND chy.CodeEnd
			    AND s.IsCodeNumeric = chy.IsCodeNumeric
			    AND s.CodeType IN (''Procedure'',''NDC'')
			    AND s.IsCodeNumeric = 0			          
	LEFT JOIN (SELECT CodeStart,
			          Category,
			          SubCategory,
			          Description,
			          CodeType,
			          IsCodeNumeric
			    FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 1 ) ndcchy ON s.Code = ndcchy.CodeStart
			    AND s.IsCodeNumeric = Ndcchy.IsCodeNumeric
			    AND s.CodeType IN (''Procedure'',''NDC'')
			    AND s.IsCodeNumeric = 1
	LEFT JOIN rpt.ProviderDataExplorerCodeMapping cm1 ON s.Code BETWEEN cm1.CodeStart AND cm1.CodeEnd AND cm1.CodeType = ''VisitType''
	LEFT JOIN rpt.ProviderDataExplorerCodeMapping cm2 ON s.Code BETWEEN cm2.CodeStart AND cm2.CodeEnd AND cm2.CodeType = ''ModalityType''
	


INSERT INTO dbo.ProviderDataExplorerBillLine
		  (
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
			ProviderZoSLat,
			ProviderZoSLong,
			ProviderZoSState,
			ModalityType,
			ModalityUnitType,
			SubFormType,
			BillInjuryDescription,
			Modifier,
			EndNote		
		   )
SELECT 
			s.OdsPostingGroupAuditId,
			s.OdsCustomerId,
			s.BillIdNo,
			s.LineNumber,			
			s.OverRide,
			s.DTSVC,
			s.PRCCD,
			ISNULL(s.Units,0) AS Units,
			s.Charged,
			s.Allowed,
			s.Analyzed,
			s.RefLineNo,
			s.POSRevCode,	
			s.Adjustment,
			s.FormType,			
			CASE WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 1 THEN ISNULL(ndcchy.CodeType,@ODSPAPRDesc)
				 WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 0 THEN ISNULL(chy.CodeType,@ODSPAPRDesc)
				 WHEN s.CodeType = ''Revenue'' THEN ISNULL(s.CodeType,@ODSPAPRDesc)
				 ELSE ISNULL(s.CodeType,@ODSPAPRDesc) END CodeType,			
			s.Code,			
			CASE WHEN s.CodeType = ''NDC'' AND s.IsCodeNumeric = 0 THEN ISNULL(ndcchy.Description,@ODSPAPRDesc)
				 WHEN s.CodeType = ''NDC'' AND s.IsCodeNumeric = 1 THEN ISNULL(chy.Description,@ODSPAPRDesc)
				 WHEN s.CodeType IN (''Procedure'',''Revenue'') THEN ISNULL(s.CodeDescription,@ODSPAPRDesc)
				 END  CodeDescription,				
			CASE WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 0 THEN ISNULL(chy.Category,@ODSPAPRCategory)
				 WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 1 THEN ISNULL(ndcchy.Category,@ODSPAPRCategory)
				 WHEN s.CodeType = ''Revenue'' THEN ISNULL(s.CodeCategory,@ODSPAPRCategory)
				 END  CodeCategory,			
			CASE WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 0 THEN ISNULL(chy.SubCategory,@ODSPAPRSubCategory)
				 WHEN s.CodeType IN (''Procedure'',''NDC'') AND s.IsCodeNumeric = 1 THEN ISNULL(ndcchy.SubCategory,@ODSPAPRSubCategory)
				 WHEN s.CodeType = ''Revenue'' THEN ISNULL(s.CodeSubCategory,@ODSPAPRSubCategory)
				 END  CodeSubCategory,
			s.BillLineType,	
			s.BundlingFlag,
			s.ExceptionFlag,
			s.ExceptionComments,
			cm1.CodeCategory,		
			zc.Lat AS ProviderZoSLat,
			zc.Long AS ProviderZoSLong,
			zc.State AS ProviderZoSState,
			cm2.CodeCategory,
			CASE WHEN cm2.CodeSubCategory = ''Timed''	AND s.Units >= 1 THEN ''Timed'' 
				 WHEN cm2.CodeSubCategory = ''UnTimed''	AND s.Units > 1 THEN ''UnTimed''
				 ELSE ''Other'' END	,
			ISNULL(UPPER(s.SubFormType),''N/A''),
			s.BillInjuryDescription,
			s.Modifier,
			s.EndNote
	FROM dbo.ProviderDataExplorerBillLine d 
	LEFT JOIN stg.ProviderDataExplorerBillLine s ON s.BillIdNo = d.BillId
										 AND s.LineNumber = d.LineNumber
										 AND s.BillLineType = d.BillLineType
										 AND s.OdsCustomerId = d.OdsCustomerId
	LEFT JOIN rpt.ProviderDataExplorerZipCode zc ON SUBSTRING(s.ProviderZipOfService,1,5) = SUBSTRING(zc.zipcode,1,5)
	LEFT JOIN (SELECT CodeStart,
			          CodeEnd,
			          Category,
			          SubCategory,
			          Description,
			          CodeType,
			          IsCodeNumeric
			    FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 0 ) chy ON s.Code BETWEEN chy.CodeStart AND chy.CodeEnd
			    AND s.IsCodeNumeric = chy.IsCodeNumeric
			    AND s.CodeType IN (''Procedure'',''NDC'')
			    AND s.IsCodeNumeric = 0			          
	LEFT JOIN (SELECT CodeStart,
			          Category,
			          SubCategory,
			          Description,
			          CodeType,
			          IsCodeNumeric
			    FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 1 ) ndcchy ON s.Code = ndcchy.CodeStart
			    AND s.IsCodeNumeric = Ndcchy.IsCodeNumeric
			    AND s.CodeType IN (''Procedure'',''NDC'')
			    AND s.IsCodeNumeric = 1
	LEFT JOIN rpt.ProviderDataExplorerCodeMapping cm1 ON s.Code BETWEEN cm1.CodeStart AND cm1.CodeEnd AND cm1.CodeType = ''VisitType''
	LEFT JOIN rpt.ProviderDataExplorerCodeMapping cm2 ON s.Code BETWEEN cm2.CodeStart AND cm2.CodeEnd AND cm2.CodeType = ''ModalityType''	 
	WHERE d.BillId IS NULL AND d.LineNumber IS NULL 


'				
ELSE
--Full Load
--Insert all the records coming from staging
'
IF OBJECT_ID(''tempdb..#IsCodeNumericzeroDP'',''U'') IS NOT NULL
		DROP TABLE #IsCodeNumericzeroDP;

   SELECT CodeStart,
	      CodeEnd,
	      Category,
	      SubCategory,
	      Description,
	      CodeType,
	      IsCodeNumeric
	INTO #IsCodeNumericzeroDP
	FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 0
IF EXISTS (SELECT Name FROM tempdb.sys.indexes
			WHERE Name = ''IX_IsCodeNumericzeroDP''
			AND OBJECT_ID = OBJECT_ID(''tempdb..#IsCodeNumericzeroDP''))
BEGIN
DROP INDEX IX_IsCodeNumericzeroDP ON #IsCodeNumericzeroDP ;
END
CREATE INDEX IX_IsCodeNumericzeroDP ON #IsCodeNumericzeroDP (CodeStart,CodeEnd);


IF OBJECT_ID(''tempdb..#IsCodeNumericOneDP'',''U'') IS NOT NULL
		DROP TABLE #IsCodeNumericOneDP;

   SELECT CodeStart,
	      Category,
	      SubCategory,
	      Description,
	      CodeType,
	      IsCodeNumeric
	INTO #IsCodeNumericOneDP
	FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 1 
IF EXISTS (SELECT Name FROM tempdb.sys.indexes
			WHERE Name = ''IX_IsCodeNumericOneDP''
			AND OBJECT_ID = OBJECT_ID(''tempdb..#IsCodeNumericOneDP''))
BEGIN
DROP INDEX IX_IsCodeNumericOneDP ON #IsCodeNumericOneDP ;
END
CREATE INDEX IX_IsCodeNumericOneDP ON #IsCodeNumericOneDP (CodeStart);


INSERT INTO dbo.ProviderDataExplorerBillLine(
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
			ProviderZoSLat,
			ProviderZoSLong,
			ProviderZoSState,
			ModalityType,
			ModalityUnitType,
			SubFormType,
			BillInjuryDescription,
			Modifier,
			EndNote							
			)
	SELECT 
			b.OdsPostingGroupAuditId,
			b.OdsCustomerId,
			b.BillIdNo,
			b.LineNumber,			
			b.OverRide,
			b.DTSVC,
			b.PRCCD,
			ISNULL(b.Units,0),
			b.Charged,
			b.Allowed,
			b.Analyzed,
			b.RefLineNo,
			b.POSRevCode,	
			b.Adjustment,			
			b.FormType,			
			CASE WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 0 THEN ISNULL(chy.CodeType,@ODSPAPRDesc)
				 WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 1 THEN ISNULL(ndcchy.CodeType,@ODSPAPRDesc)
				 WHEN b.CodeType = ''Revenue'' THEN ISNULL(b.CodeType,@ODSPAPRDesc)
				 ELSE ISNULL(b.CodeType,@ODSPAPRDesc) END CodeType,			
			b.Code,			
			CASE WHEN b.CodeType = ''NDC'' AND b.IsCodeNumeric = 0 THEN ISNULL(ndcchy.Description,@ODSPAPRDesc)
				 WHEN b.CodeType = ''NDC'' AND b.IsCodeNumeric = 1 THEN ISNULL(chy.Description,@ODSPAPRDesc)
				 WHEN b.CodeType IN (''Procedure'',''Revenue'') THEN ISNULL(b.CodeDescription,@ODSPAPRDesc)
				 END CodeDescription,				
			CASE WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 0 THEN ISNULL(chy.Category,@ODSPAPRCategory)
				 WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 1 THEN ISNULL(ndcchy.Category,@ODSPAPRCategory)
				 WHEN b.CodeType = ''Revenue'' THEN ISNULL(b.CodeCategory,@ODSPAPRCategory)
				 END AS CodeCategory,			
			CASE WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 0 THEN ISNULL(chy.SubCategory,@ODSPAPRSubCategory)
				 WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 1 THEN ISNULL(ndcchy.SubCategory,@ODSPAPRSubCategory)
				 WHEN b.CodeType = ''Revenue'' THEN ISNULL(b.CodeSubCategory,@ODSPAPRSubCategory)
				 END AS CodeSubCategory,
			BillLineType,
			b.BundlingFlag,
			b.ExceptionFlag,
			b.ExceptionComments,
			cm1.CodeCategory,			
			zc.Lat AS ProviderZoSLat,
			zc.Long AS ProviderZoSLong,
			zc.State AS ProviderZoSState,
			cm2.CodeCategory,
			CASE WHEN cm2.CodeSubCategory = ''Timed''	AND b.Units >= 1 THEN ''Timed'' 
				 WHEN cm2.CodeSubCategory = ''UnTimed''	AND b.Units > 1 THEN ''UnTimed''
				 ELSE ''Other'' END	,
			ISNULL(UPPER(b.SubFormType),''N/A''),
			b.BillInjuryDescription,
			b.Modifier,
			b.EndNote		
FROM  stg.ProviderDataExplorerBillLine b 
	LEFT JOIN rpt.ProviderDataExplorerZipCode zc ON SUBSTRING(b.ProviderZipOfService,1,5) = SUBSTRING(zc.zipcode,1,5)
	LEFT JOIN #IsCodeNumericzeroDP chy ON b.Code BETWEEN chy.CodeStart AND chy.CodeEnd
			    AND b.IsCodeNumeric = chy.IsCodeNumeric
			    AND b.CodeType IN (''Procedure'',''NDC'')
			    AND b.IsCodeNumeric = 0			          
	LEFT JOIN #IsCodeNumericOneDP ndcchy ON b.Code = ndcchy.CodeStart
			    AND b.IsCodeNumeric = Ndcchy.IsCodeNumeric
			    AND b.CodeType IN (''Procedure'',''NDC'')
			    AND b.IsCodeNumeric = 1
	LEFT JOIN rpt.ProviderDataExplorerCodeMapping cm1 ON b.Code BETWEEN cm1.CodeStart AND cm1.CodeEnd AND cm1.CodeType = ''VisitType''
	LEFT JOIN rpt.ProviderDataExplorerCodeMapping cm2 ON b.Code BETWEEN cm2.CodeStart AND cm2.CodeEnd AND cm2.CodeType = ''ModalityType''
	
	
	
	'
END

IF (@Debug = 1)
BEGIN
	PRINT @AuditFor;
	PRINT @OdsPostingGroupAuditId;
	PRINT @ProcessName;
	PRINT @RunFromOdsPostingGroupAuditId;
	PRINT(@SQLScript);
END

EXEC(@SQLScript);
		
-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerEtlAuditEnd @AuditFor,@ProcessName,@OdsPostingGroupAuditId,@ReportId;

END



GO


