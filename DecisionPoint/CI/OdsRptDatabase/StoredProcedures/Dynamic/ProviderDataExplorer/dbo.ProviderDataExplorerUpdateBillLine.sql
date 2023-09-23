
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderAnalyticsUpdateBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderAnalyticsUpdateBillLine

GO 

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerUpdateBillLine') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerUpdateBillLine

GO 
CREATE PROCEDURE dbo.ProviderDataExplorerUpdateBillLine(
@SourceDatabaseName VARCHAR(50),
@SnapshotAsOf AS DATETIME,
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
		@WhereClause VARCHAR(MAX),	    
		@RunFromOdsPostingGroupAuditId INT;

-- Get OdsPostingGroupAuditId from ETLAudit table for Incremental Load
SET @RunFromOdsPostingGroupAuditId = dbo.GetMaxRunFromOdsPostingGroupAuditId(@ProcessName,@AuditFor,@ReportId)

SET @WhereClause =
	  CHAR(13)+CHAR(10)+'WHERE ex.ReportID = '+CAST(@ReportId AS VARCHAR(3)) 
	+ CHAR(13)+CHAR(10)+CHAR(9) + 'AND cus.CustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))
	---+ CHAR(13)+CHAR(10)+CHAR(9) + CASE WHEN @IsIncrementalLoad = 1 THEN ' AND ex.OdsPostingGroupAuditID > '+CAST(@RunFromOdsPostingGroupAuditId AS VARCHAR(50)) ELSE '' END	
	+ CHAR(13)+CHAR(10)+CHAR(9)

SET @SQLScript = CAST('' AS VARCHAR(MAX))+
 '
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

 IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDXPACHUpdateClaimantHeader'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerClaimantHeader''))
  BEGIN
    DROP INDEX IDXPACHUpdateClaimantHeader ON stg.ProviderDataExplorerClaimantHeader;
  END
CREATE INDEX IDXPACHUpdateClaimantHeader ON stg.ProviderDataExplorerClaimantHeader (OdsCustomerId,ClaimantHdrIdNo);



IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDXPACHUpdateBillHeader'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerBillHeader''))
  BEGIN
    DROP INDEX IDXPACHUpdateBillHeader ON stg.ProviderDataExplorerBillHeader;
  END
CREATE INDEX IDXPACHUpdateBillHeader ON stg.ProviderDataExplorerBillHeader (OdsCustomerId,ClaimantHdrIdNo,BillIdNo);


/*	Set ExceptionFlag as 1 with records having condition date_of_service is less than date_loss */
UPDATE bl 
	SET
	bl.ExceptionFlag = 1,
	ExceptionComments=''Date of service is less than date loss''	
FROM stg.ProviderDataExplorerBillLine bl
	     INNER JOIN stg.ProviderDataExplorerBillHeader bh ON bl.BillIdNo = bh.BillIdNo 
												AND bl.OdsCustomerId = bh.OdsCustomerId 												
		 INNER JOIN stg.ProviderDataExplorerClaimantHeader ch ON bh.ClaimantHdrIdNo = ch.ClaimantHdrIdNo 
											    AND bh.OdsCustomerId = ch.OdsCustomerId											   
												  
		 WHERE bl.DTSVC < ch.DateLoss  

/*	set exception_flag as 1 with records having condition Allowed amount is higher than charged amount. */
	
UPDATE stg.ProviderDataExplorerBillLine 
SET 
	ExceptionFlag=1,
	ExceptionComments=''Allowed amount is higher than charged amount.'' 

WHERE ISNULL(Allowed,0) > ISNULL(Charged,0);


/*	Set exception_flag as 1 where Duplicate records where identified with endnote as 4. */

IF OBJECT_ID(''tempdb..#DuplicateBillLines'') IS NOT NULL					
	DROP TABLE #DuplicateBillLines;

SELECT  ISNULL(Be.OdsCustomerId,bo.OdsCustomerId ) AS OdsCustomerId,
		ISNULL(Be.BillIDNo,bo.BillIDNo) as BillIdNo, 
		Isnull(be.LINE_NO,bo.Line_No) as Line_No
		
INTO #DuplicateBillLines
FROM '+@SourceDatabaseName+'.dbo.Bills_Pharm_Endnotes BE
FULL OUTER JOIN '+@SourceDatabaseName+'.dbo.Bills_Pharm_OverrideEndNotes BO ON Be.OdsCustomerId = BO.OdsCustomerId 
														AND BE.BillIDNo = BO.BillIDNo 
														AND BE.LINE_NO = BO.LINE_NO
WHERE BE.odscustomerid = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		AND (BO.OverrideEndNote = 4 OR (be.EndNote = 4 AND  BO.OverrideEndNote IS NULl))
		
UNION

  SELECT ISNULL(Be.OdsCustomerId,bo.OdsCustomerId ) AS OdsCustomerId,
		 ISNULL(Be.BillIDNo,bo.BillIDNo) AS BillIdNo, 
		 Isnull(be.LINE_NO,bo.Line_No) AS Line_No

FROM '+@SourceDatabaseName+'.dbo.Bills_EndNotes BE
FULL OUTER JOIN '+@SourceDatabaseName+'.dbo.Bills_OverrideEndNotes BO ON BE.OdsCustomerId = BO.OdsCustomerId 
																AND BE.BillIDNo = BO.BillIDNo 
																AND BE.LINE_NO = BO.LINE_NO
WHERE BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId)+' 
		AND (BO.OverrideEndNote = 4 OR (be.EndNote = 4 AND  BO.OverrideEndNotE IS NULL))

UNION

SELECT ISNULL(Be.OdsCustomerId,bo.OdsCustomerId ) AS OdsCustomerId,
		 ISNULL(Be.BillIDNo,bo.BillIDNo) AS BillIdNo, 
		 Isnull(be.LineNumber,bo.Line_No) AS Line_No

FROM stg.ProviderDataExplorerBillLine BE
Inner JOIN '+@SourceDatabaseName+'.dbo.Bills_OverrideEndNotes BO ON BE.OdsCustomerId = BO.OdsCustomerId 
																AND BE.BillIDNo = BO.BillIDNo 
																AND BE.LineNumber = BO.LINE_NO
WHERE BO.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId)+' 
		AND BO.OverrideEndNote = 4

UNION

  SELECT ISNULL(Be.OdsCustomerId,bo.OdsCustomerId ) AS OdsCustomerId,
		 ISNULL(Be.BillIDNo,bo.BillIDNo) AS BillIdNo, 
		 Isnull(be.LineNumber,bo.Line_No) AS Line_No

FROM stg.ProviderDataExplorerBillLine BE
Inner JOIN '+@SourceDatabaseName+'.dbo.Bills_Pharm_OverrideEndNotes BO ON BE.OdsCustomerId = BO.OdsCustomerId 
																AND BE.BillIDNo = BO.BillIDNo 
																AND BE.LineNumber = BO.LINE_NO
WHERE BO.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId)+' 
		AND BO.OverrideEndNote = 4


UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Duplicate records identified with endnote as 4.''				
FROM stg.ProviderDataExplorerBillLine B 
INNER JOIN #DuplicateBillLines BE ON BE.BillIDNo = B.BillIdNo
								 AND BE.LINE_NO = B.LineNumber
		                         AND BE.OdsCustomerId = B.OdsCustomerId


		
/* Every claim first Date_of_Service should be last 24 months*/

IF OBJECT_ID(''tempdb..#DTSVC'') IS NOT NULL
         DROP TABLE #DTSVC;
  
BEGIN
	
IF OBJECT_ID(''tempdb..#DTSVC_Bills'') IS NOT NULL					
	DROP TABLE #DTSVC_Bills;			
	
CREATE TABLE #DTSVC_Bills
	(
	OdsCustomerId INT NOT NULL,	
	ClaimIDNo INT NOT NULL,
	BillIdNo INT NOT NULL,
	BillLineNo INT NOT NULL,
	DTSVC DATETIME

	CONSTRAINT PK_ProviderDataExplorerClaimsInScope PRIMARY KEY
			(						
				OdsCustomerId,
				ClaimIDNo,
				BillIdNo,
				BillLineNo
			)
		
	);

	INSERT INTO #DTSVC_Bills
	SELECT  ch.OdsCustomerId,
	        ch.ClaimIdNo,				
			b.BillIDNo,
			b.LINE_NO,
			b.DT_SVC
	FROM stg.ProviderDataExplorerClaimantHeader ch  
              INNER JOIN stg.ProviderDataExplorerBillHeader Bh ON ch.OdsCustomerId = bh.OdsCustomerId 	
														 AND ch.ClaimantHdrIdNo = bh.ClaimantHdrIdNo
			  INNER JOIN '+@SourceDatabaseName+'.dbo.BILLS b ON bh.OdsCustomerId = b.OdsCustomerId
																		 AND bh.BillIDNo = b.BillIDNo
																		 AND b.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
	

	IF EXISTS (SELECT Name FROM tempdb.sys.indexes  WHERE Name=''IDX_DTSVC_Bills_DT_SVC'' 
		  AND OBJECT_ID = OBJECT_ID(''tempdb..#DTSVC_Bills''))
		BEGIN
		  DROP INDEX IDX_DTSVC_Bills_DT_SVC ON #DTSVC_Bills;
		END
	CREATE INDEX IDX_DTSVC_Bills_DT_SVC ON #DTSVC_Bills(DTSVC);	
	
	SELECT 
		  C.OdsCustomerId,
		  C.ClaimIDNo
		  ,MIN(c.DTSVC ) MinDtsvc
		 INTO  #DTSVC
		From  #DTSVC_Bills c 
			  
	GROUP BY 						
			C.OdsCustomerId,
			C.ClaimIDNo;
END


IF OBJECT_ID(''tempdb..#DateOfService'') IS NOT NULL
           DROP TABLE #DateOfService ;
BEGIN
	SELECT 
		ch.OdsCustomerId,
		ch.ClaimIdNo,
		MIN(CAST(bl.DTSVC AS DATE)) MinDateOfService 
	INTO #DateOfService
	FROM
		 stg.ProviderDataExplorerBillLine bl 
	     INNER JOIN stg.ProviderDataExplorerBillHeader bh ON bl.BillIdNo = bh.BillIdNo 
												AND bl.OdsCustomerId = bh.OdsCustomerId 												
		 INNER JOIN stg.ProviderDataExplorerClaimantHeader ch ON bh.ClaimantHdrIdNo = ch.ClaimantHdrIdNo 
											    AND bh.OdsCustomerId = ch.OdsCustomerId
											    

GROUP BY 
		ch.OdsCustomerId,
		ch.ClaimIDNo;
END

/* take records which do not match from the above two temp tables */
IF OBJECT_ID(''tempdb..#ClaimLevelDataofService'') IS NOT NULL
        DROP TABLE #ClaimLevelDataofService;
BEGIN
SELECT 
		S.OdsCustomerId,
		S.ClaimIDNo,
		D.MinDtsvc,
		S.MinDateOfService 
	INTO #ClaimLevelDataofService  
FROM #DTSVC D INNER JOIN #DateOfService S ON D.OdsCustomerId = S.OdsCustomerId 
										AND D.ClaimIDNo = S.ClaimIDNo
										WHERE D.MinDtsvc <> S.MinDateOfService
					
END


UPDATE bl 
    SET
ExceptionFlag = 1,
ExceptionComments = ''Claim''''s with first date of sevice is < 24 months.''

FROM
	 stg.ProviderDataExplorerBillLine bl 
	     INNER JOIN stg.ProviderDataExplorerBillHeader bh ON bl.BillIdNo = bh.BillIdNo 
												AND bl.OdsCustomerId = bh.OdsCustomerId 												
		 INNER JOIN stg.ProviderDataExplorerClaimantHeader ch ON bh.ClaimantHdrIdNo = ch.ClaimantHdrIdNo 
											    AND bh.OdsCustomerId = ch.OdsCustomerId											    
    JOIN  #ClaimLevelDataofService D ON  D.ClaimIDNo = ch.ClaimIDNo 
												AND D.OdsCustomerId = ch.OdsCustomerId ;



IF OBJECT_ID(''stg.CustomerBillExclusionTemp'',''U'') IS NOT NULL					
	DROP TABLE stg.CustomerBillExclusionTemp;	

CREATE TABLE stg.CustomerBillExclusionTemp( 
			OdsCustomerId  INT NOT NULL,
			BillIdNo INT NOT NULL
			);

INSERT INTO stg.CustomerBillExclusionTemp
SELECT cus.CustomerId
	   ,ex.BillIdNo 	  
FROM '+@SourceDatabaseName+'.dbo.CustomerBillExclusion ex 
INNER JOIN '+@SourceDatabaseName+'.adm.Customer cus ON ex.Customer =cus.CustomerDatabase  
 '+@WhereClause + ' 
 
		   
/*Bundling Unbundling Script*/

UPDATE B 
  SET 
      B.BundlingFlag = -1

FROM stg.ProviderDataExplorerBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.BILLS_Endnotes BE 
	  WHERE BE.BillIDNo = B.BillIdNo
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId		
		AND BE.EndNote IN(10)
		AND BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		)


UPDATE B
  SET 
      B.BundlingFlag = -2
FROM stg.ProviderDataExplorerBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.BILLS_Endnotes BE 
	  WHERE BE.BillIDNo = B.BillIdNo
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId		
		AND BE.EndNote IN(35)
		AND BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		)

IF OBJECT_ID(''tempdb..#BillLineArchive'') IS NOT NULL
         DROP TABLE #BillLineArchive;
BEGIN
        
SELECT *
INTO #BillLineArchive
FROM stg.ProviderDataExplorerBillLine B 
WHERE BundlingFlag IN(-1, -2);

DELETE FROM stg.ProviderDataExplorerBillLine
WHERE BundlingFlag IN(-1, -2);

END


INSERT INTO stg.ProviderDataExplorerBillLine
SELECT 
		a.OdsPostingGroupAuditId,
		a.OdsCustomerId,
		a.BillIdNo,
		a.LineNumber,
		a.OverRide,
		a.DTSVC,
		a.PRCCD,
		a.Units,
		b.c,
		a.Allowed,
		a.Analyzed,
		a.RefLineNo,
		a.POSRevCode,
		ISNULL(b.c,0) - ISNULL(a.ALLOWED,0)  Adjustment, 
		a.FormType,
		a.CodeType,
		a.Code,
		a.ProviderZipOfService,
		a.BillLineType,
		a.ExceptionFlag,
		a.ExceptionComments,
		1 AS BundlingFlag,
		a.CodeDescription,
		a.CodeCategory,
		a.CodeSubCategory,
		a.IsCodeNumeric,
		a.SubFormType,
		a.BillInjuryDescription,	
		a.Modifier,
		a.EndNote,
		a.RunDate
		
       FROM #BillLineArchive a 
            INNER JOIN
       (
           SELECT bl.BillIdNo, 
                  bl.LineNumber, 
                  bl.OdsCustomerId,                  
                  SUM(isnull(ul.charged,0)) c
           FROM #BillLineArchive bl 
                LEFT JOIN #BillLineArchive ul ON ul.BillIdNo = bl.BillIdNo
                                                                     AND ul.RefLineNo = bl.LineNumber
                                                                     AND ul.BundlingFlag = -1
																	 AND ul.OdsCustomerId = bl.OdsCustomerId                                                                   
                                                                     
           WHERE bl.BundlingFlag = -2
           GROUP BY bl.BillIdNo, 
                    bl.LineNumber, 
                    bl.OdsCustomerId                   
       ) b ON a.BillIdNo = b.BillIdNo
              AND a.LineNumber = b.LineNumber
              AND a.OdsCustomerId = b.OdsCustomerId;


/*	Set exception_flag as 1 where Benefits exhausted records were identified with endnote as 202. Using BILLS_Endnotes, Bills_OverrideEndNotes,
	Bills_Pharm_Endnotes and Bills_Pharm_OverrideEndNotes tables */
		
UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Benefits exhausted records identified with endnote as 202.''				
FROM stg.ProviderDataExplorerBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.BILLS_Endnotes BE 
	  WHERE BE.BillIDNo = B.BillIdNo
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId
		AND BE.EndNote = 202
		AND BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		)

	
UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Benefits exhausted records identified with endnote as 202.''			
FROM stg.ProviderDataExplorerBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.Bills_OverrideEndNotes BE 
	  WHERE BE.BillIDNo = B.BillIdNo
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId
		AND BE.OverrideEndNote = 202
		AND BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		)

UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Benefits exhausted records identified with endnote as 202.''			
FROM stg.ProviderDataExplorerBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.Bills_Pharm_Endnotes BE 
	  WHERE BE.BillIDNo = B.BillIdNo
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId
		AND BE.EndNote = 202
		AND BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		)

UPDATE b
SET 
	ExceptionFlag = 1,
	ExceptionComments  = ''Benefits exhausted records identified with endnote as 202.''			
FROM stg.ProviderDataExplorerBillLine B 
WHERE EXISTS(
      SELECT 1  
	  FROM '+@SourceDatabaseName+'.dbo.Bills_Pharm_OverrideEndNotes BE 
	  WHERE BE.BillIDNo = B.BillIdNo
		AND BE.LINE_NO = B.LineNumber
		AND BE.OdsCustomerId = B.OdsCustomerId
		AND BE.OverrideEndNote = 202
		AND BE.OdsCustomerId = '+ CONVERT(VARCHAR(10),@OdsCustomerId) +'
		
		)


/* Add EndNote details in BillLine TABLE 
 Endnotes: found in multiple tables:
-BILLS_Endnotes.EndNote
-BILLS_CTG_Endnotes.Endnote
-Bills_OverrideEndnotes.OverrideEndNote
-Bills_Pharm_CTG_Endnotes.EndNote
-Bills_Pharm_Endnotes.EndNote
-Bills_Pharm_OverrideEndnotes.OverrideEndNote

We will fetch end note from individual tables into temporary table with multiple endNotes as comma separated values.
Then we will update our stg table by concatenating end noteds from all temporary tables.

If endnote is from BILLS_CTG_Endnotes or Bills_Pharm_CTG_Endnotes then prepend "C" to the endnote
If endnote is from Bills_OverideEndnotes or Bills_Pharm_OverrideEndnotes then prepend "X" to the endnote

 */

	-- Step 1 get EndNotes FROM BILLS_Endnotes

IF OBJECT_ID(''tempdb..#ben'') IS NOT NULL
	DROP TABLE #ben

	SELECT
		   b.OdsCustomerId
		   ,b.BillIDNo
		   ,LINE_NO
		   ,m.EndNote
	INTO #ben 
	FROM '+@SourceDatabaseName+'.src.BILLS_Endnotes m
	INNER JOIN stg.ProviderDataExplorerBillLine b ON m.OdsCustomerId = b.OdsCustomerId 
													AND b.BillIdNo=m.BillIDNo 
													AND b.LineNumber=m.LINE_NO
	WHERE b.OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +'


IF EXISTS(SELECT name 
			FROM tempdb.sys.indexes 
			WHERE name = N''IX_ben_BillIdNo_LineNo'' 
			AND OBJECT_ID = OBJECT_ID(''tempdb..#ben'')
		)
	DROP INDEX IX_ben_BillIdNo_LineNo ON #ben

	CREATE NONCLUSTERED INDEX IX_ben_BillIdNo_LineNo ON #ben(BillIdNo,Line_No)

-- Concatenate multiple endNote for same Line as comma separate values  

IF OBJECT_ID(''tempdb..#BillEndNotes'') IS NOT NULL
	DROP TABLE #BillEndNotes

	SELECT
		   OdsCustomerId
		   ,BillIDNo
		   ,LINE_NO
		   ,EndNotes = STUFF((
						  SELECT '','' + CAST(md.EndNote AS VARCHAR)
						  FROM #ben md
						  WHERE m.BillIDNo = md.BillIDNo
								AND m.LINE_NO = md.LINE_NO
						  FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')
	INTO #BillEndNotes
	FROM #ben m


	-- Step 2 get EndNotes FROM BILLS_CTG_Endnotes

IF OBJECT_ID(''tempdb..#bcen'') IS NOT NULL
	DROP TABLE #bcen

	SELECT
		   b.OdsCustomerId
		   ,b.BillIDNo
		   ,LINE_NO
		   ,m.EndNote
	INTO #bcen 
	FROM '+@SourceDatabaseName+'.src.BILLS_CTG_Endnotes m
	INNER JOIN stg.ProviderDataExplorerBillLine b ON m.OdsCustomerId = b.OdsCustomerId 
													AND b.BillIdNo=m.BillIDNo 
													AND b.LineNumber=m.LINE_NO
	WHERE b.OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +'


IF EXISTS(SELECT name 
			FROM tempdb.sys.indexes 
			WHERE name = N''IX_bcen_BillIdNo_LineNo'' 
				AND OBJECT_ID = OBJECT_ID(''tempdb..#bcen'')
		)
	DROP INDEX IX_bcen_BillIdNo_LineNo ON #bcen

	CREATE NONCLUSTERED INDEX IX_bcen_BillIdNo_LineNo ON #bcen(BillIdNo,Line_No)

-- Concatenate multiple endNote for same Line as comma separate values and prepend C to every EndNote

IF OBJECT_ID(''tempdb..#BillCtgEndNotes'') IS NOT NULL
	DROP TABLE #BillCtgEndNotes

	SELECT
		   OdsCustomerId
		   ,BillIDNo
		   ,LINE_NO
		   ,EndNotes = STUFF((
			  SELECT '',C'' + CAST(md.EndNote AS VARCHAR)
			  FROM #bcen md
			  WHERE m.BillIDNo = md.BillIDNo
					AND m.LINE_NO = md.LINE_NO
			  FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')
	INTO #BillCtgEndNotes
	FROM #bcen m


	-- Step 3 get EndNotes FROM Bills_OverrideEndnotes

IF OBJECT_ID(''tempdb..#boen'') IS NOT NULL
	DROP TABLE #boen

	SELECT
		   b.OdsCustomerId
		   ,b.BillIDNo
		   ,LINE_NO
		   ,m.OverrideEndNote
	INTO #boen 
	FROM '+@SourceDatabaseName+'.src.Bills_OverrideEndnotes m
	INNER JOIN stg.ProviderDataExplorerBillLine b ON m.OdsCustomerId = b.OdsCustomerId 
												AND b.BillIdNo=m.BillIDNo 
												AND b.LineNumber=m.LINE_NO
	WHERE b.OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +'


IF EXISTS(SELECT name 
			FROM tempdb.sys.indexes 
			WHERE name = N''IX_boen_BillIdNo_LineNo'' 
				AND OBJECT_ID = OBJECT_ID(''tempdb..#boen'')
		)
	DROP INDEX IX_boen_BillIdNo_LineNo ON #boen

	CREATE NONCLUSTERED INDEX IX_boen_BillIdNo_LineNo ON #boen(BillIdNo,Line_No)

-- Concatenate multiple endNote for same Line as comma separate values and prepend X to every EndNote

IF OBJECT_ID(''tempdb..#BillOverrideEndNotes'') IS NOT NULL
	DROP TABLE #BillOverrideEndNotes

	SELECT
		   OdsCustomerId
		   ,BillIDNo
		   ,LINE_NO
		   ,EndNotes = STUFF((
			  SELECT '',X'' + CAST(md.OverrideEndNote AS VARCHAR)
			  FROM #boen md
			  WHERE m.BillIDNo = md.BillIDNo
					AND m.LINE_NO = md.LINE_NO
			  FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')
	INTO #BillOverrideEndNotes
	FROM #boen m

	--Step 4  get EndNotes FROM Bills_Pharm_Endnotes

	IF OBJECT_ID(''tempdb..#bpen'') IS NOT NULL
	DROP TABLE #bpen

	SELECT
		   b.OdsCustomerId
		   ,b.BillIDNo
		   ,LINE_NO
		   ,m.EndNote
	INTO #bpen 
	FROM '+@SourceDatabaseName+'.src.Bills_Pharm_Endnotes m
	INNER JOIN stg.ProviderDataExplorerBillLine b ON m.OdsCustomerId = b.OdsCustomerId 
													AND b.BillIdNo=m.BillIDNo 
													AND b.LineNumber=m.LINE_NO
	WHERE b.OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +'


IF EXISTS(SELECT name 
			FROM tempdb.sys.indexes 
			WHERE name = N''IX_bpen_BillIdNo_LineNo'' 
				AND OBJECT_ID = OBJECT_ID(''tempdb..#bpen'')
		)
	DROP INDEX IX_bpen_BillIdNo_LineNo ON #bpen

	CREATE NONCLUSTERED INDEX IX_bpen_BillIdNo_LineNo ON #bpen(BillIdNo,Line_No)

-- Concatenate multiple endNote for same Line as comma separate values 

IF OBJECT_ID(''tempdb..#BillPharmaEndNotes'') IS NOT NULL
	DROP TABLE #BillPharmaEndNotes

	SELECT
		   OdsCustomerId
		   ,BillIDNo
		   ,LINE_NO
		   ,EndNotes = STUFF((
			  SELECT '','' + CAST(md.EndNote AS VARCHAR)
			  FROM #bpen md
			  WHERE m.BillIDNo = md.BillIDNo
					AND m.LINE_NO = md.LINE_NO
			  FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')
	INTO #BillPharmaEndNotes
	FROM #bpen m


	-- Step 5 get EndNotes FROM Bills_Pharm_CTG_Endnotes

IF OBJECT_ID(''tempdb..#bpcen'') IS NOT NULL
	DROP TABLE #bpcen

	SELECT
		   b.OdsCustomerId
		   ,b.BillIDNo
		   ,LINE_NO
		   ,m.EndNote
	INTO #bpcen 
	FROM '+@SourceDatabaseName+'.src.Bills_Pharm_CTG_Endnotes m
	INNER JOIN stg.ProviderDataExplorerBillLine b ON m.OdsCustomerId = b.OdsCustomerId 
													AND b.BillIdNo=m.BillIDNo 
													AND b.LineNumber=m.LINE_NO
	WHERE b.OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +'


IF EXISTS(SELECT name 
			FROM tempdb.sys.indexes 
			WHERE name = N''IX_bpcen_BillIdNo_LineNo'' 
				AND OBJECT_ID = OBJECT_ID(''tempdb..#bpcen'')
		)
	DROP INDEX IX_bpcen_BillIdNo_LineNo ON #bpcen

	CREATE NONCLUSTERED INDEX IX_bpcen_BillIdNo_LineNo ON #bpcen(BillIdNo,Line_No)

-- Concatenate multiple endNote for same Line as comma separate values and prepend C to every EndNote

IF OBJECT_ID(''tempdb..#BillPharmaCtgEndNotes'') IS NOT NULL
	DROP TABLE #BillPharmaCtgEndNotes

	SELECT
		   OdsCustomerId
		   ,BillIDNo
		   ,LINE_NO
		   ,EndNotes = STUFF((
			  SELECT '',C'' + CAST(md.EndNote AS VARCHAR)
			  FROM #bpcen md
			  WHERE m.BillIDNo = md.BillIDNo
					AND m.LINE_NO = md.LINE_NO
			  FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')
	INTO #BillPharmaCtgEndNotes
	FROM #bpcen m


	-- Step 6 get EndNotes FROM Bills_Pharm_OverrideEndnotes

	IF OBJECT_ID(''tempdb..#bpoen'') IS NOT NULL
	DROP TABLE #bpoen

	SELECT
		   b.OdsCustomerId
		   ,b.BillIDNo
		   ,LINE_NO
		   ,m.OverrideEndNote
	INTO #bpoen 
	FROM '+@SourceDatabaseName+'.src.Bills_Pharm_OverrideEndnotes m
	INNER JOIN stg.ProviderDataExplorerBillLine b ON m.OdsCustomerId = b.OdsCustomerId 
													AND b.BillIdNo=m.BillIDNo 
													AND b.LineNumber=m.LINE_NO
	WHERE b.OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +'


IF EXISTS(SELECT name 
			FROM tempdb.sys.indexes 
			WHERE name = N''IX_bpoen_BillIdNo_LineNo'' 
				AND OBJECT_ID = OBJECT_ID(''tempdb..#bpoen'')
		)
	DROP INDEX IX_bpoen_BillIdNo_LineNo ON #bpoen

	CREATE NONCLUSTERED INDEX IX_bpoen_BillIdNo_LineNo ON #bpoen(BillIdNo,Line_No)

-- Concatenate multiple endNote for same Line as comma separate values and prepend X to every EndNote

IF OBJECT_ID(''tempdb..#BillPharmaOverrideEndNotes'') IS NOT NULL
	DROP TABLE #BillPharmaOverrideEndNotes

	SELECT
		   OdsCustomerId
		   ,BillIDNo
		   ,LINE_NO
		   ,EndNotes = STUFF((
			  SELECT '',X'' + CAST(md.OverrideEndNote AS VARCHAR)
			  FROM #bpoen md
			  WHERE m.BillIDNo = md.BillIDNo
					AND m.LINE_NO = md.LINE_NO
			  FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''')
	INTO #BillPharmaOverrideEndNotes
	FROM #bpoen m

--Concatenate all EndNote from different tables as comma separated.

	UPDATE b
	SET b.EndNote = ISNULL(be.EndNotes ,'''')
					+ISNULL('',''+bce.EndNotes ,'''')
					+ISNULL('',''+boe.EndNotes ,'''')
					+ISNULL('',''+bpe.EndNotes ,'''')
					+ISNULL('',''+bpce.EndNotes,'''')
					+ISNULL('',''+bpoe.EndNotes,'''')
	FROM stg.ProviderDataExplorerBillLine b
	LEFT JOIN #BillEndNotes be ON b.OdsCustomerId=be.OdsCustomerId 
								AND b.BillIdNo=be.BillIDNo
								AND b.LineNumber = be.LINE_NO
	LEFT JOIN #BillCtgEndNotes bce ON b.OdsCustomerId=bce.OdsCustomerId 
								AND b.BillIdNo=bce.BillIDNo
								AND b.LineNumber = bce.LINE_NO
	LEFT JOIN #BillOverrideEndNotes boe ON b.OdsCustomerId=boe.OdsCustomerId 
								AND b.BillIdNo=boe.BillIDNo
								AND b.LineNumber = boe.LINE_NO
	LEFT JOIN #BillPharmaEndNotes bpe ON b.OdsCustomerId=bpe.OdsCustomerId 
								AND b.BillIdNo=bpe.BillIDNo
								AND b.LineNumber = bpe.LINE_NO
	LEFT JOIN #BillPharmaCtgEndNotes bpce ON b.OdsCustomerId=bpce.OdsCustomerId 
								AND b.BillIdNo=bpce.BillIDNo
								AND b.LineNumber = bpce.LINE_NO
	LEFT JOIN #BillPharmaOverrideEndNotes bpoe ON b.OdsCustomerId=bpoe.OdsCustomerId 
								AND b.BillIdNo=bpoe.BillIDNo
								AND b.LineNumber = bpoe.LINE_NO

-- If first table do not have any EndNote, then remove leading comma

	UPDATE b
	SET EndNote = RIGHT(EndNote,len(endnote)-1)
	FROM stg.ProviderDataExplorerBillLine b 
	WHERE OdsCustomerId='+ CONVERT(VARCHAR(10),@OdsCustomerId) +' 
		AND EndNote LIKE '',%''


/* Exclude bill lines with feature date of service. Using Adm.ReportParameters.EndDate.*/
DECLARE @ODSPAEndDate DATETIME
SELECT @ODSPAEndDate = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+ CONVERT(VARCHAR(10),@ReportId) +'  
			AND ParameterName = ''ODSPAEndDate''

UPDATE b
	SET ExceptionFlag = 1,
		ExceptionComments =''Exclude Bill Lines with future date of service.''
FROM stg.ProviderDataExplorerBillLine b 
	WHERE OdsCustomerId ='+ CONVERT(VARCHAR(10),@OdsCustomerId) +' 
		AND DTSVC > @ODSPAEndDate

		 
		 
			  '
			  			   			  
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

