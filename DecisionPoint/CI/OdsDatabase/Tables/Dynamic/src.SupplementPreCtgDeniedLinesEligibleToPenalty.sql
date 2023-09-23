IF OBJECT_ID('src.SupplementPreCtgDeniedLinesEligibleToPenalty', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SupplementPreCtgDeniedLinesEligibleToPenalty
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BillIdNo INT NOT NULL ,
			  LineNumber SMALLINT NOT NULL ,
			  CtgPenaltyTypeId TINYINT NOT NULL ,
			  SeqNo SMALLINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SupplementPreCtgDeniedLinesEligibleToPenalty ADD 
     CONSTRAINT PK_SupplementPreCtgDeniedLinesEligibleToPenalty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo, LineNumber, CtgPenaltyTypeId, SeqNo) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SupplementPreCtgDeniedLinesEligibleToPenalty ON src.SupplementPreCtgDeniedLinesEligibleToPenalty   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
