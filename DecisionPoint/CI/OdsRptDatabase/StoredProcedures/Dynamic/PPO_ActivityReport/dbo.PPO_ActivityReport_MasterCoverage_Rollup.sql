IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PPO_ActivityReport_MasterCoverage_Rollup') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Rollup
GO

CREATE PROCEDURE dbo.PPO_ActivityReport_MasterCoverage_Rollup(
@SourceDatabaseName VARCHAR(50)='AcsOds',
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@ReportType INT = 1,
@OdsCustomerID INT = 0,
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
	--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@TargetDatabaseName VARCHAR(50) = 'ReportDB',@ReportType INT = 1,@RunType INT = 0,@if_Date AS DATETIME = GETDATE(),@OdsCustomerID INT = 0
	DECLARE @SQLScript VARCHAR(MAX);
	
	SET @SQLScript = '
	DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;
	DECLARE @StartOfMonth DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, '''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+'''), 0);

	DELETE FROM '+@TargetDatabaseName+'.dbo.PPO_ActivityReport_MasterCoverage_Output
	WHERE ((ReportTypeID = 2 AND StartOfMonth < @StartOfMonth)
	OR ReportTypeID  = '+CAST(@ReportType AS VARCHAR(2))+')'+CASE WHEN @OdsCustomerID <> 0 THEN ' AND OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5)) ELSE '' END +';

	IF OBJECT_ID(''tempdb..#BillsWithDuplicateLineCount'') IS NOT NULL	DROP TABLE #BillsWithDuplicateLineCount;
	SELECT OdsCustomerId
		,billIDNo
		,COUNT(1) LineCount
		,SUM(CASE WHEN DuplicateReductionsFlag <> 0 THEN 1 ELSE 0 END) DuplicateLineCount
	INTO #BillsWithDuplicateLineCount
	FROM stg.DP_PerformanceReport_linelevelprioritized
	GROUP BY OdsCustomerId,billIDNo
	HAVING SUM(CASE WHEN DuplicateReductionsFlag <> 0 THEN 1 ELSE 0 END) = COUNT(1); 
	
	IF OBJECT_ID(''tempdb..#tempConsolidatedReductions'') IS NOT NULL	DROP TABLE #tempConsolidatedReductions
	SELECT P.OdsCustomerId
		,P.billIDNo
		,B.billIDNo AS DuplicateBillidNo
		,P.line_no
		,P.line_type
		,P.BenefitsExhaustedReductions
		,CASE WHEN  (ISNULL(P.AnalystReductions,0) + ISNULL(P.AnalystORReductions,0)) = 0 
				AND P.FeeScheduleReductions = 0 
				AND P.BenchmarkReductions = 0
				AND P.VPNReductions = 0 
				AND P.CTGReductions = 0 
				AND P.DuplicateReductions = 0 
				AND P.BenefitsExhaustedReductions = 0
				AND P.Overrides = 0 THEN 1 ELSE 0 END AS RecompAnalystReductions
		,ISNULL(P.AnalystReductions,0) + ISNULL(P.AnalystORReductions,0) AnalystReductions
		,P.AnalystORReductions
		,P.DuplicateReductions
		,P.BenchmarkReductions
		,P.VPNReductions
		,P.FeeScheduleReductions
		,P.CTGReductions
		,P.Overrides
		,P.VPNReductionsFlag
		,P.DuplicateReductionsFlag
		,P.BenefitsExhaustedReductionsFlag
		
	INTO #tempConsolidatedReductions	
	FROM stg.DP_PerformanceReport_linelevelprioritized P
	LEFT OUTER JOIN #BillsWithDuplicateLineCount B
		ON P.OdsCustomerId = B.OdsCustomerId
		AND P.billIDNo = B.billIDNo;
		
	-- Indexes On Filtered Data
	CREATE CLUSTERED INDEX Idx_CustomerIdBillIdNoLineNoLineType 
	ON #tempConsolidatedReductions(OdsCustomerId,BillIdNo,Line_no,Line_type)
	WITH (DATA_COMPRESSION = PAGE);
	
	IF OBJECT_ID(''tempdb..#PPO_ActivityReport_MasterCoverage_rollup'') IS NOT NULL	DROP TABLE #PPO_ActivityReport_MasterCoverage_rollup
	SELECT m.OdsCustomerId
		,DATEADD(MONTH, DATEDIFF(MONTH, 0, m.CreateDate), 0) AS StartOfMonth
		,C.CustomerName AS Customer
		,YEAR(m.CreateDate) AS Year
		,MONTH(m.CreateDate) AS Month
		,ISNULL(m.Company, ''NA'') AS Company
		,ISNULL(m.Office, ''NA'') AS Office
		,ISNULL(m.SOJ, ''NA'') AS SOJ
		,ISNULL(m.Coverage, ''NA'') AS Coverage
		,ISNULL(m.Form_Type, ''NA'') AS Form_Type
		,m.billIDNo
		,m.line_no
		,m.units
		,m.charged
		,m.allowed
		,r.DuplicateReductions 
		,CASE WHEN r.RecompAnalystReductions  = 1 AND (m.charged - m.allowed > 0) THEN (m.charged - m.allowed) ELSE r.AnalystReductions END RecompAnalystReductions 
		,r.FeeScheduleReductions 
		,r.BenchmarkReductions 
		,r.CTGReductions
		,CASE WHEN r.DuplicateReductions <> 0 THEN m.BillIDNo END AS BillsWithOneOrMoreDuplicateLines
		,CASE WHEN r.DuplicateReductions <> 0 THEN m.BillIDNo END AS PartialDuplicateBills
		,r.DuplicateBillidNo
		,CASE WHEN r.DuplicateReductionsFlag <> 0 THEN 1 ELSE 0 END Dup_Lines
		,CASE WHEN r.BenefitsExhaustedReductionsFlag <> 0 THEN m.BillIDNo END BenefitsExhausted_Bills
		,CASE WHEN r.BenefitsExhaustedReductionsFlag <> 0 THEN 1 ELSE 0 END BenefitsExhausted_Lines
		,r.BenefitsExhaustedReductions
		,CASE WHEN r.RecompAnalystReductions  = 1 AND (m.charged - m.allowed > 0) THEN (m.charged - m.allowed) ELSE r.AnalystReductions END AnalystReductions
		,r.VPNReductions
		,r.Overrides

	INTO #PPO_ActivityReport_MasterCoverage_rollup
	FROM stg.PPO_ActivityReport_MasterCoverage_Input m
	INNER JOIN #tempConsolidatedReductions r ON m.OdsCustomerId = r.OdsCustomerId
		AND m.billIDNo = r.billIDNo
		AND m.line_no = r.line_no
		AND m.linetype = r.line_type
	INNER JOIN '+@SourceDatabaseName+'.adm.Customer C
		ON m.OdsCustomerId = c.CustomerId
	LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CustomerBillExclusion' ELSE'if_CustomerBillExclusion(@RunPostingGroupAuditId)' END+' ex 
		ON C.CustomerDatabase = ex.Customer
		AND m.billIDNo = ex.billIDNo
		AND ex.ReportID = 11
	
	WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' m.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'ex.billIDNo IS NULL;
		
	CREATE CLUSTERED INDEX Idx_CustomerIdBillIdNoLineNoLineType 
	ON #PPO_ActivityReport_MasterCoverage_rollup(OdsCustomerId,StartOfMonth,Customer,Year,Month,Company,Office,SOJ,Coverage,Form_Type)
	WITH (DATA_COMPRESSION = PAGE);
		
	
	INSERT INTO '+@TargetDatabaseName+'.dbo.PPO_ActivityReport_MasterCoverage_Output(
		 OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type
		,Total_Bills
		,Total_Provider_Charges
		,Total_Bill_Review_Reductions
		,ReportTypeID
		,RunDate)	
	SELECT
		 OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type
		,COUNT(DISTINCT billIDNo) Total_Bills
		,SUM(charged) Total_Provider_Charges
		,SUM(DuplicateReductions) 
			+ SUM(RecompAnalystReductions)
			+ SUM(FeeScheduleReductions) 
			+ SUM(BenchmarkReductions) 
			+ SUM(CTGReductions) Total_Bill_Review_Reductions
		,'+CAST(@ReportType AS VARCHAR(2))+' AS ReportTypeID
		,GETDATE()
	FROM #PPO_ActivityReport_MasterCoverage_rollup R1
	GROUP BY OdsCustomerId
		,StartOfMonth
		,Customer
		,Year
		,Month
		,Company
		,Office
		,SOJ
		,Coverage
		,Form_Type
	OPTION (HASH GROUP);'
		
	EXEC (@SQLScript);	
	
END
GO
