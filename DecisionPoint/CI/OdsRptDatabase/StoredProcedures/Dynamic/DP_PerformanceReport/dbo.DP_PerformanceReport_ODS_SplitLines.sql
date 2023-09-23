IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DP_PerformanceReport_SplitLines') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.DP_PerformanceReport_SplitLines
GO

CREATE PROCEDURE dbo.DP_PerformanceReport_SplitLines(
@OdsCustomerId INT = 0)
AS
BEGIN
-- Setup Run parameters
-- DECLARE @OdsCustomerId INT = 5;
DECLARE @SQLScript VARCHAR(MAX) = '	
DECLARE  @returnstatus INT;
									
-- Identify Split Lines and Join with child lines
IF OBJECT_ID(''tempdb..#GroupedLines'') IS NOT NULL DROP TABLE #GroupedLines
SELECT   T1.OdsCustomerId
		,T1.billIDNo
        ,1 AS actionIndicator
        ,T2.ref_line_no
        ,T2.line_no
        ,T2.charged
        
INTO #GroupedLines
FROM    stg.DP_PerformanceReport_Input T1
INNER JOIN stg.DP_PerformanceReport_Input T2
	ON T1.OdsCustomerId = T2.OdsCustomerId
	AND T1.billIDNo = T2.billIDNo
	AND T1.line_no = T2.ref_line_no 
	AND T1.line_no != T2.line_no

WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' T1.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END +'T1.line_type = 1
        AND T1.line_no_disp = 0
        AND T1.charged = 0
        AND T1.allowed > 0;

-- Update split line charges with sum of charged from children and set Children to zero
;WITH cte_LineCharges AS(
SELECT  billIDNo
		,OdsCustomerId
		,ref_line_no
		,SUM(ISNULL(charged,0)) AS Charged
FROM #GroupedLines
GROUP BY billIDNo
		 ,OdsCustomerId
		 ,ref_line_no)        
SELECT T.OdsCustomerId
      ,T.billIDNo
      ,T.line_type
      ,T.line_no
      ,T.CreateDate
      ,T.CompanyID
      ,T.Company
      ,T.OfficeID
      ,T.Office
      ,T.Coverage
      ,T.claimNo
      ,T.ClaimIDNo
      ,T.CmtIDNo
      ,T.SOJ
      ,T.Form_Type
      ,T.ProviderZipOfService
      ,T.TypeOfBill
      ,T.DiagnosisCode
      ,T.ProcedureCode
      ,T.ProviderSpecialty
      ,T.ProviderType
      ,T.ProviderType_Desc
      ,T.line_no_disp
      ,0 as ref_line_no
      ,T.over_ride
      ,CASE WHEN S.Billidno IS NOT NULL THEN S.Charged 
					 WHEN G.billIDNo IS NOT NULL THEN 0 ELSE T.Charged END AS charged
      ,T.allowed
      ,T.PreApportionedAmount
      ,T.analyzed
      ,T.units
      ,T.reporttype
      ,T.RunDate 
INTO #DP_PerformanceReport_Input
FROM stg.DP_PerformanceReport_Input T
LEFT OUTER JOIN #GroupedLines G
	ON T.OdsCustomerId = G.OdsCustomerId 
	AND T.billIDNo = G.billIDNo
	AND T.line_no = G.line_no
LEFT OUTER JOIN cte_LineCharges S 
	ON T.OdsCustomerId = S.OdsCustomerId	
	AND T.billIDNo = S.billIDNo
	AND T.line_no = S.ref_line_no'+
CASE WHEN @OdsCustomerId <> 0 THEN CHAR(13)+CHAR(10)+'WHERE  T.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+';' ELSE ';'+CHAR(13)+CHAR(10) END +
CASE WHEN @OdsCustomerID <> 0 THEN '

EXEC adm.Rpt_CreateUnpartitionedTableSchema '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,1,@returnstatus;
EXEC adm.Rpt_CreateUnpartitionedTableIndexes '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,@returnstatus;
EXEC adm.Rpt_SwitchUnpartitionedTable '+CAST(@OdsCustomerId AS VARCHAR(3))+',16,'''',1,@returnstatus;

DROP TABLE stg.DP_PerformanceReport_Input_Unpartitioned;' 

ELSE '
TRUNCATE TABLE stg.DP_PerformanceReport_Input;' END+'

INSERT INTO stg.DP_PerformanceReport_Input
SELECT OdsCustomerId
      ,billIDNo
      ,line_type
      ,line_no
      ,CreateDate
      ,CompanyID
      ,Company
      ,OfficeID
      ,Office
      ,Coverage
      ,claimNo
      ,ClaimIDNo
      ,CmtIDNo
      ,SOJ
      ,Form_Type
      ,ProviderZipOfService
      ,TypeOfBill
      ,DiagnosisCode
      ,ProcedureCode
      ,ProviderSpecialty
      ,ProviderType
      ,ProviderType_Desc
      ,line_no_disp
      ,ref_line_no
      ,over_ride
      ,charged
      ,allowed
      ,PreApportionedAmount
      ,analyzed
      ,units
      ,reporttype
      ,RunDate
FROM #DP_PerformanceReport_Input;'
	
EXEC (@SQLScript);

END 
GO
