IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LossYearReport_Output') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.LossYearReport_Output
GO

CREATE PROCEDURE  dbo.LossYearReport_Output  (
@SourceDatabaseName VARCHAR(50)='AcsOds',
@RunType INT = 0, 
@OdsCustomerID INT,
@ReportId INT=5,
@ProcessId INT=3)
AS
BEGIN
-- DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@RunType INT = 0, @OdsCustomerID INT = 44, @ReportId INT=5, @ProcessId INT=3
DECLARE @SQLScript VARCHAR(MAX),
		@returnstatus INT; 

EXEC adm.Rpt_CreateUnpartitionedTableSchema @OdsCustomerId,@ProcessId,0,@returnstatus;

SET @SQLScript = CAST('' AS VARCHAR(MAX)) +
CASE WHEN @OdsCustomerID <> 0 THEN 
'DELETE FROM dbo.LossYearReport
WHERE OdsCustomerId = '+CAST(@OdsCustomerID as VARCHAR(5))+';' ELSE 

'TRUNCATE TABLE dbo.LossYearReport;' END+'

INSERT INTO stg.LossYearReport_Unpartitioned
    (ReportName,
	 OdsCustomerId,
     CustomerName,
     SOJ,
     AgeGroup,
     YOL,
     Year,
     Quarter,
     DateQuarter,
     FormType,
     CoverageType,
     CoverageTypeDesc,
     InjuryNatureId,
	 InjuryNatureDesc,
	 EncounterTypeId,
	 EncounterTypeDesc,
	 Period,
     ServiceGroup,
	 RevenueGroup,
     Gender,
     OutlierCat,
     ClaimantState,
     ClaimantCounty,
     ProviderSpecialty,
     ProviderState,
     Allowed,
     IndAllowed,
     Charged,
     IndCharged,
     UnitsCnt,
     IndUnitsCnt,
     ClaimantCnt,
     IndClaimantCnt,
     DOSCnt,
     IndDOSCnt,
     IsAllowedGreaterThanZero,
	 RunDate
     )
SELECT I.ReportName
		  ,ISNULL(D.CustomerId,0)
	      ,ISNULL(D.CustomerName,'''') DisplayName
	      ,I.SOJ 
	      ,I.AgeGroup
	      ,YEAR(I.DateQuarter) YOL
	      ,YEAR(I.DateQuarter) [Year]
	      ,DATEPART(QQ,I.DateQuarter) Quarter
	      ,I.DateQuarter
	      ,I.FormType
	      ,I.CoverageType
	      ,CASE WHEN LTRIM(RTRIM(ISNULL(CV.LongName,''Uncategorized''))) = '''' THEN ''Uncategorized'' ELSE ISNULL(CV.LongName,''Uncategorized'') END CoverageTypeDesc
	      ,ISNULL(I.InjuryNatureId,0) InjuryNatureId 
	      ,CASE WHEN I.ReportName like ''%Injury%'' THEN 
										 CASE WHEN  I.InjuryNatureId = 24 THEN INJ.NarrativeInformation ELSE ISNULL(INJ.Description,''Unknown'') END 
			  ELSE '''' END AS InjuryNatureDesc 
		  ,EN.EncounterTypeId
		  ,EN.Description
		  ,I.Period
	      ,I.ServiceGroup
		  ,RCC.Description AS RevenueGroup
	      ,I.Gender
	      ,I.Outlier_cat
	      ,I.ClaimantState
	      ,I.ClaimantCounty
	      ,I.ProviderSpecialty
	      ,I.ProviderState
	      ,ISNULL(C.Allowed,0) 
	      ,I.IndAllowed - ISNULL(C.Allowed,0) AS IndAllowed
	      ,ISNULL(C.Charged,0)
	      ,I.IndCharged - ISNULL(C.Charged,0) AS IndCharged
	      ,ISNULL(C.Units,0)
	      ,I.IndUnits - ISNULL(C.Units,0) AS IndUnits
	      ,ISNULL(C.ClaimantCnt,0)
	      ,I.IndClaimantCnt - ISNULL(C.ClaimantCnt,0) AS IndClaimantCnt
	      ,ISNULL(C.DOSCnt,0)
	      ,I.IndDOSCnt - ISNULL(C.DOSCnt,0) AS IndDOSCnt
	      ,I.IsAllowedGreaterThanZero
		  ,GETDATE()
    FROM stg.LossYearReport_Industry I
	LEFT JOIN '+@SourceDatabaseName+'.adm.Customer D
		ON D.CustomerId = '+CASE WHEN @OdsCustomerID <> 0 THEN CAST(@OdsCustomerId AS VARCHAR(3)) ELSE 'D.CustomerId ' END+'
    LEFT JOIN  stg.LossYearReport_Client C
			ON  C.OdsCustomerId = D.CustomerId
			AND C.ReportID = I.ReportID
			AND C.SOJ = I.SOJ
			AND C.IsAllowedGreaterThanZero = I.IsAllowedGreaterThanZero
			AND ISNULL(C.AgeGroup,''-1'') = ISNULL(I.AgeGroup,''-1'')
			AND C.DateQuarter = I.DateQuarter
			AND ISNULL(C.FormType,''-1'') = ISNULL(I.FormType,''-1'')
			AND ISNULL(C.CoverageType,''-1'') = ISNULL(I.CoverageType,''-1'')
			AND ISNULL(C.EncounterTypePriority,-1) = ISNULL(I.EncounterTypePriority,-1)
			AND ISNULL(C.ServiceGroup,'''') = ISNULL(I.ServiceGroup,'''')
			AND ISNULL(C.RevenueCodeCategoryId,-1) = ISNULL(I.RevenueCodeCategoryId,-1)
			AND ISNULL(C.Gender,'''') = ISNULL(I.Gender,'''')
			AND ISNULL(C.Outlier_cat,'''') = ISNULL(I.Outlier_cat,'''')
			AND ISNULL(C.ClaimantState,'''') = ISNULL(I.ClaimantState,'''')
			AND ISNULL(C.ClaimantCounty,'''') = ISNULL(I.ClaimantCounty,'''')
			AND ISNULL(C.ProviderSpecialty,'''') = ISNULL(I.ProviderSpecialty,'''')
			AND ISNULL(C.ProviderState,'''') = ISNULL(I.ProviderState,'''')
			AND ISNULL(C.InjuryNatureId,-1) = ISNULL(I.InjuryNatureId,-1)
			AND ISNULL(C.Period,''-1'') = ISNULL(I.Period,''-1'')
    LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'InjuryNature' ELSE 'if_InjuryNature(@RunPostingGroupAuditId)' END + ' INJ
			ON D.CustomerID = INJ.OdsCustomerId
			AND I.InjuryNatureID = INJ.InjuryNatureID
	LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'EncounterType' ELSE 'if_EncounterType(@RunPostingGroupAuditId)' END + ' EN
			ON D.CustomerID = EN.OdsCustomerId
			AND I.EncounterTypePriority = EN.EncounterTypeId
	LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'CoverageType' ELSE 'if_CoverageType(@RunPostingGroupAuditId)' END + ' CV
			ON  D.CustomerID = CV.OdsCustomerId
			AND I.CoverageType = CV.ShortName 
	LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.' + CASE WHEN  @RunType = 0 THEN 'RevenueCodeCategory' ELSE 'if_RevenueCodeCategory(@RunPostingGroupAuditId)' END + ' RCC 
			ON D.CustomerId = RCC.OdsCustomerId
			AND I.RevenueCodeCategoryId = RCC.RevenueCodeCategoryId;'

EXEC(@SQLScript);

EXEC adm.Rpt_CreateUnpartitionedTableIndexes @OdsCustomerId,@ProcessId,@returnstatus;
EXEC adm.Rpt_SwitchUnpartitionedTable @OdsCustomerId,@ProcessId,'',0,@returnstatus;

END

GO

