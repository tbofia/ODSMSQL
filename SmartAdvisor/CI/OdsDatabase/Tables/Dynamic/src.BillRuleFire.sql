IF OBJECT_ID('src.BillRuleFire', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillRuleFire
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  LineSeq SMALLINT NOT NULL ,
			  RuleID CHAR (5) NOT NULL ,
			  RuleType CHAR (1) NULL ,
			  DateRuleFired DATETIME NULL ,
			  Validated CHAR (1) NULL ,
			  ValidatedUserID CHAR (2) NULL ,
			  DateValidated DATETIME NULL ,
			  PendToID VARCHAR (13) NULL ,
			  RuleSeverity CHAR (1) NULL ,
			  WFTaskSeq INT NULL ,
			  ChildTargetSubset VARCHAR (4) NOT NULL ,
			  ChildTargetSeq INT NOT NULL ,
			  CapstoneRuleID INT NULL ,

 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillRuleFire ADD 
     CONSTRAINT PK_BillRuleFire PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, LineSeq, RuleID, ChildTargetSubset, ChildTargetSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillRuleFire ON src.BillRuleFire   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BillRuleFire')
						AND NAME = 'CapstoneRuleID' )
	BEGIN
		ALTER TABLE src.BillRuleFire ADD CapstoneRuleID INT NULL ;
	END ; 
GO



