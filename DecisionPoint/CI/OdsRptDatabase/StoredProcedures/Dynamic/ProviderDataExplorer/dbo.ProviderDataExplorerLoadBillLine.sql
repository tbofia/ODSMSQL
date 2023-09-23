
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsLoadBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsLoadBillLine

GO 

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerLoadBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerLoadBillLine

GO 

CREATE PROCEDURE dbo.ProviderDataExplorerLoadBillLine(
@SourceDatabaseName VARCHAR(50),
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@SnapshotAsOf AS DATETIME,
@IsIncrementalLoad INT,
@Debug BIT,
@ReportId INT,
@OdsCustomerId INT)
AS
BEGIN

DECLARE 
		@OdsPostingGroupAuditId INT,
		@ProcessName VARCHAR(50),
		@AuditFor VARCHAR(100),
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
		@WhereClauseforBills VARCHAR(MAX),
		@WhereClauseforBillsPharm VARCHAR(MAX),
		@RunFromOdsPostingGroupAuditId INT;

-- Get OdsPostingGroupAuditId from ETLAudit table for Incremental Load
SET @RunFromOdsPostingGroupAuditId = dbo.GetMaxRunFromOdsPostingGroupAuditId(@ProcessName,@AuditFor,@ReportId)


-- Build Where clause for Bills
SET @WhereClauseforBills =
	  CHAR(13)+CHAR(10)+'WHERE '
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' b.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' AND b.PRC_CD <> ''COORD'''
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND b.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END	
	+ CHAR(13)+CHAR(10)+CHAR(9)
-- Build Where clause for BillsPharm
SET @WhereClauseforBillsPharm =
	  CHAR(13)+CHAR(10)+'WHERE '
	+ CHAR(13)+CHAR(10)+CHAR(9) + ' bp.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND bp.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END


SET @SQLScript = CAST('' AS VARCHAR(MAX))+
'
IF OBJECT_ID(''tempdb..#RevenueCodes'') IS NOT NULL
	DROP TABLE #RevenueCodes

SELECT * INTO #RevenueCodes FROM '+@SourceDatabaseName+'.dbo.ub_revenuecodes

UPDATE	rc
SET
	revenuecodesubcategoryid=rc2.revenuecodesubcategoryid
FROM
	#RevenueCodes rc
	JOIN (SELECT DISTINCT revenuecode,revenuecodesubcategoryid FROM #RevenueCodes WHERE  revenuecodesubcategoryid IS NOT NULL) rc2 ON
	rc.revenuecode=rc2.revenuecode AND rc.revenuecodesubcategoryid IS NULL

IF OBJECT_ID(''tempdb..#CodeHierarchy'') IS NOT NULL
	DROP TABLE #CodeHierarchy
	
SELECT
	''Procedure'' Dataset,
	odscustomerid OdsCustomerId,	
	prc_cd Code,
	SUBSTRING(prc_desc,0,2500) Description,
	''Procedure'' Category,
	''Procedure'' SubCategory,
	StartDate,
	EndDate
INTO #CodeHierarchy
FROM
	'+@SourceDatabaseName+'.dbo.cpt_prc_dict

UNION

SELECT
	''Revenue'' Dataset,
	rc.odscustomerid,	
	rc.revenuecode,
	SUBSTRING(rc.prc_desc,0,2500) prc_desc,
	UPPER(rcc.Description),
	UPPER(rcsc.Description),
	StartDate,
	EndDate
FROM
	#RevenueCodes rc
	LEFT JOIN '+@SourceDatabaseName+'.dbo.revenuecodesubcategory rcsc ON rc.revenuecodesubcategoryid=rcsc.revenuecodesubcategoryid AND rc.odscustomerid=rcsc.odscustomerid 
	LEFT JOIN '+@SourceDatabaseName+'.dbo.revenuecodecategory rcc ON rcsc.revenuecodecategoryid=rcc.revenuecodecategoryid AND rcsc.odscustomerid=rcc.odscustomerid 


IF EXISTS (SELECT Name FROM tempdb.sys.indexes  WHERE Name = ''IDXPACodeHierarchyCode'' 
    AND object_id = OBJECT_ID(''tempdb..#CodeHierarchy''))
  BEGIN
    DROP INDEX IDXPACodeHierarchyCode ON #CodeHierarchy;
  END
CREATE INDEX IDXPACodeHierarchyCode ON #CodeHierarchy (DataSet,Code);


'+
CASE WHEN @IsIncrementalLoad = 0 THEN
'
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name=''IDXPACHOdsCustomerIdBillIdNo'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerBillHeader''))
  BEGIN
    DROP INDEX IDXPACHOdsCustomerIdBillIdNo ON stg.ProviderDataExplorerBillHeader;
  END
CREATE INDEX IDXPACHOdsCustomerIdBillIdNo ON stg.ProviderDataExplorerBillHeader (OdsCustomerId,BillIdNo,TypeOfBill);
'
ELSE '' END
+
'
TRUNCATE TABLE stg.ProviderDataExplorerBillLine;

DECLARE @ODSPAPRCodeTypePharma  VARCHAR(100),
		@ODSPAUB04 VARCHAR(10),
		@ODSPACMS1500 VARCHAR(10),
		@ODSPABillLineTypePharma VARCHAR(30),
		@ODSPABillLineType VARCHAR(30),
		@ODSPAPRDescPharma VARCHAR(100),
		@ODSPAPRCategoryPharma VARCHAR(100),
		@ODSPAPRSubCategoryPharma VARCHAR(100);

		SELECT @ODSPAUB04 = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAUB04''
		SELECT @ODSPACMS1500 = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPACMS1500''
		SELECT @ODSPABillLineType = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPABillLineType''
		SELECT @ODSPAPRCodeTypePharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRCodeTypePharma''
		SELECT @ODSPAPRDescPharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRDescPharma''
		SELECT @ODSPAPRCategoryPharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRCategoryPharma''
		SELECT @ODSPAPRSubCategoryPharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPAPRSubCategoryPharma''
		SELECT @ODSPABillLineTypePharma = ParameterValue FROM  adm.ReportParameters WHERE ReportId = 9 AND ParameterName = ''ODSPABillLineTypePharma''

INSERT INTO stg.ProviderDataExplorerBillLine(
			OdsPostingGroupAuditId,
			OdsCustomerId,
			BillIdNo,
			LineNumber,			
			OverRide,
			DTSVC,
			PRCCD,
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
			ProviderZipOfService,
			BillLineType,
			CodeDescription,
			CodeCategory,
			CodeSubCategory,
			IsCodeNumeric,
			Modifier			
)
SELECT 		
			b.OdsPostingGroupAuditId,
			b.OdsCustomerId,
			b.BillIdNo,
			b.LINE_NO,			
			b.Over_Ride,
			b.DT_SVC,
			b.PRC_CD,
			b.Units,
			b.Charged,
			b.Allowed,
			b.Analyzed,
			b.REF_LINE_NO,
			b.POS_RevCode,
			ISNULL(b.CHARGED, 0) - ISNULL(b.ALLOWED, 0) AS Adjustment,
			    CASE
                  WHEN(bh.Flags&4096) = 4096
                  THEN @ODSPAUB04
                  ELSE @ODSPACMS1500
              END AS FormTypeDesc,
			  CASE
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN ''Procedure''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN ''REVENUE''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN ''REVENUE''
			ELSE ''Procedure'' END PR_Code_Type,
			  CASE
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN b.prc_cd
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN b.pos_revcode
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN b.pos_revcode
			ELSE b.prc_cd END PR_Code,
			bh.PvdZOS,
			@ODSPABillLineType,
			ch.Description CodeDescription,
			ch.Category CodeCategory,
			ch.SubCategory CodeSubCategory,
			CASE WHEN ISNUMERIC(b.PRC_CD) = 1 THEN 1 
				 WHEN ISNUMERIC(b.PRC_CD) = 0 THEN 0 END,
			b.TS_CD												

	FROM '+@SourceDatabaseName+'.dbo.BILLS b '
		+ CHAR(13)+CHAR(10)+CHAR(9) + 
		CASE
			WHEN @IsIncrementalLoad = 0 THEN
		'INNER JOIN stg.ProviderDataExplorerBillHeader bh ON b.OdsCustomerId = bh.OdsCustomerId 
																				AND b.BillIdNo = bh.BillIdNo'
												
			ELSE 'INNER JOIN '+@SourceDatabaseName+'.dbo.BILL_HDR bh ON b.OdsCustomerId = bh.OdsCustomerId 
																				AND b.BillIdNo = bh.BillIdNo'
		  END
		+ CHAR(13)+CHAR(10)+CHAR(9) +
		'LEFT JOIN #CodeHierarchy ch ON	 CASE
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN ''Procedure''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN ''Revenue''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN ''Revenue''
			ELSE ''Procedure'' END = ch.Dataset
			AND
					 CASE
							WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN b.prc_cd
							WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN b.pos_revcode
							WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN b.pos_revcode
					ELSE b.prc_cd END = ch.Code
			AND b.dt_svc BETWEEN ch.StartDate AND ch.EndDate
			AND b.OdsCustomerId = ch.OdsCustomerId        
			'											    
		+ @WhereClauseforBills  +'		

UNION 

SELECT 		
			bp.OdsPostingGroupAuditId,
			bp.OdsCustomerId,
			bp.BillIdNo,
			bp.LINE_NO,
			bp.OverRide,
			bp.DateOfService,
			REPLACE(bp.NDC,''-'','''') AS NDC,
			bp.Units,
			bp.Charged,
			bp.Allowed,
			bp.Analyzed,
			0,
			bp.POS_RevCode,
			ISNULL(bp.CHARGED, 0) - ISNULL(bp.ALLOWED, 0) AS Adjustment,
			CASE
               WHEN(bh.Flags&4096) = 4096
               THEN @ODSPAUB04
               ELSE @ODSPACMS1500
			 END AS FormTypeDesc,			
			@ODSPAPRCodeTypePharma AS PR_Code_Type,			 
			CONVERT(VARCHAR(100),REPLACE(NDC,''-'','''')) AS PR_Code,
			bh.PvdZOS,
			@ODSPABillLineTypePharma,			
			@ODSPAPRDescPharma,
			@ODSPAPRCategoryPharma,
			@ODSPAPRSubCategoryPharma,
			CASE WHEN ISNUMERIC(REPLACE(bp.NDC,''-'','''')) = 1 THEN 1 
				 WHEN ISNUMERIC(REPLACE(bp.NDC,''-'','''')) = 0 THEN 0 END,
			'''' as TS_CD

		FROM '+@SourceDatabaseName+'.dbo.Bills_Pharm bp '
		+ CHAR(13)+CHAR(10)+CHAR(9) + 
			CASE
			WHEN @IsIncrementalLoad = 0 THEN
		'INNER JOIN stg.ProviderDataExplorerBillHeader bh ON bp.OdsCustomerId = bh.OdsCustomerId 
																				AND bp.BillIdNo = bh.BillIdNo'												
			ELSE 'INNER JOIN '+@SourceDatabaseName+'.dbo.BILL_HDR bh ON bp.OdsCustomerId = bh.OdsCustomerId 
																				AND bp.BillIdNo = bh.BillIdNo'
		  END
		+ CHAR(13)+CHAR(10)+CHAR(9) +											
				   + @WhereClauseforBillsPharm  

				  	+ CHAR(13)+CHAR(10)+CHAR(9)
        +CASE
			WHEN @IsIncrementalLoad = 0 THEN
		+'DROP INDEX IDXPACHOdsCustomerIdBillIdNo ON stg.ProviderDataExplorerBillHeader;'
		ELSE '' END
		+ CHAR(13)+CHAR(10)+CHAR(9)+'
		
			
	   DELETE b  
       FROM  stg.ProviderDataExplorerBillLine b 
	   INNER JOIN '+@SourceDatabaseName+'.dbo.BILLS_Endnotes e ON b.BillIdNo = e.BillIDNo 
													AND b.LineNumber = e.LINE_NO 
													AND b.OdsCustomerId = e.OdsCustomerId
       WHERE e.EndNote = 45 AND e.OdsCustomerId ='+CONVERT(VARCHAR(100),@OdsCustomerId)+';	
	   
/*Update the category and subcategory for RC codes like 
RC250 is replaced with 0250 and provider category and subcategory */
	   
UPDATE	b 
SET
	b.CodeCategory = rc.Category,
	b.CodeSubCategory = rc.SubCategory
FROM
	stg.ProviderDataExplorerBillLine b
    INNER JOIN  rpt.ProviderDataExplorerPRCodeDataQuality Pr ON b.Code = pr.Code 
												AND  ISNULL(pr.Category,'''' ) = '''' 
												AND pr.MappedCode = ''RC''
												AND b.Code like ''RC%''
	INNER JOIN #CodeHierarchy rc ON REPLACE(b.Code,''RC'',''0'') = rc.Code 
												AND b.OdsCustomerId = rc.OdsCustomerId ;


		
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDPA_ProviderDataExplorerBillLinePOSRevCode'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerBillLine''))
	BEGIN
    DROP INDEX IDPA_ProviderDataExplorerBillLinePOSRevCode ON stg.ProviderDataExplorerBillLine;
  END
CREATE INDEX IDPA_ProviderDataExplorerBillLinePOSRevCode ON stg.ProviderDataExplorerBillLine (BillIdno,POSRevCode);



IF OBJECT_ID(''tempdb..#SubFormTypeTemp'') IS NOT NULL
	DROP TABLE #SubFormTypeTemp
SELECT 	Bl.BillIdNo,
		Bl.LineNumber,
		ISNULL(CASE WHEN  bl.FormType = ''CMS-1500'' THEN Ps.Description 
								     WHEN  bl.FormType = ''UB-04''    THEN SUBSTRING(bt.Description,1,CHARINDEX('';'',bt.Description)-1)						   
						        END ,''N/A'') SubFormType
		INTO #SubFormTypeTemp
FROM stg.ProviderDataExplorerBillHeader bh 
INNER JOIN stg.ProviderDataExplorerBillLine bl ON bl.BillIdNo = bh.BillIdNo 
												AND bl.OdsCustomerId = bh.OdsCustomerId 												
LEFT JOIN '+@SourceDatabaseName+'.dbo.UB_BillType bt on bh.TypeOfBill = bt.tob 
												AND bl.OdsCustomerId = bt.OdsCustomerId 												
LEFT JOIN '+@SourceDatabaseName+'.dbo.PlaceOfServiceDictionary ps ON  bl.POSRevCode = RIGHT(CONCAT(''00'', ISNULL(CONVERT(VARCHAR(2),ps.PlaceOfServiceCode),'''')),2)
												AND bl.OdsCustomerId = ps.OdsCustomerId 
												AND (CONVERT(DATE,bl.DTSVC) BETWEEN StartDate AND EndDate)
		
		
	IF EXISTS (SELECT Name FROM tempdb.sys.indexes  WHERE Name = ''IDXPA_SubFormTypeTempBillIdNo'' 
    AND object_id = OBJECT_ID(''tempdb..#SubFormTypeTemp''))
  BEGIN
    DROP INDEX IDXPA_SubFormTypeTempBillIdNo ON #SubFormTypeTemp;
  END
CREATE INDEX IDXPA_SubFormTypeTempBillIdNo ON #SubFormTypeTemp (BillIdNo,LineNumber);
		
												
	UPDATE bl 
		SET 
		bl.SubFormType = sf.SubFormType
FROM stg.ProviderDataExplorerBillLine bl 
INNER JOIN  #SubFormTypeTemp SF ON SF.BillIdNo = bl.BillIdNo 
									AND SF.LineNumber = bl.LineNumber
	
	
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDPA_ProviderDataExplorerBillLinePOSRevCode'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerBillLine''))
	BEGIN
    DROP INDEX IDPA_ProviderDataExplorerBillLinePOSRevCode ON stg.ProviderDataExplorerBillLine;
  END

		'

IF(@Debug = 1)
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


