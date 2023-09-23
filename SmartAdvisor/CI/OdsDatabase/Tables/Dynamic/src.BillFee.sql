IF OBJECT_ID('src.BillFee', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillFee
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
			  FeeType CHAR (1) NOT NULL ,
			  TransactionType CHAR (6) NOT NULL ,
			  FeeCtrlSource CHAR (1) NULL ,
			  FeeControlSeq INT NULL ,
			  FeeAmount MONEY NULL ,
			  InvoiceSeq BIGINT NULL ,
			  InvoiceSubSeq SMALLINT NULL ,
			  PPONetworkID CHAR (2) NULL ,
			  ReductionCode SMALLINT NULL ,
			  FeeOverride CHAR (1) NULL ,
			  OverrideVerified CHAR (1) NULL ,
			  ExclusiveFee CHAR (1) NULL ,
			  FeeSourceID VARCHAR (20) NULL ,
			  HandlingFee CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillFee ADD 
     CONSTRAINT PK_BillFee PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, FeeType, TransactionType) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillFee ON src.BillFee   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
