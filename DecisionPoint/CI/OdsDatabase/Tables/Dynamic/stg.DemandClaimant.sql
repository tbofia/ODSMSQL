IF OBJECT_ID('stg.DemandClaimant', 'U') IS NOT NULL
DROP TABLE stg.DemandClaimant
BEGIN
	CREATE TABLE stg.DemandClaimant (
	   DemandClaimantId int NULL
	  ,ExternalClaimantId int NULL
	  ,OrganizationId nvarchar(100) NULL
	  ,HeightInInches smallint NULL
	  ,[Weight] smallint NULL
	  ,Occupation varchar(50) NULL
	  ,BiReportStatus smallint NULL
	  ,HasDemandPackage int NULL
	  ,FactsOfLoss varchar(250) NULL
	  ,PreExistingConditions varchar(100) NULL
	  ,Archived bit NULL
	  ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
