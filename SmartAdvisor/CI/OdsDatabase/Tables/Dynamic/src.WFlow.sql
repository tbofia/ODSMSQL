IF OBJECT_ID('src.WFlow', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.WFlow
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  WFlowSeq INT NOT NULL ,
			  Description VARCHAR (50) NULL ,
			  RecordStatus CHAR (1) NULL ,
			  EntityTypeCode CHAR (2) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  InitialTaskSeq INT NULL ,
			  PauseTaskSeq INT NULL ,

 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.WFlow ADD 
     CONSTRAINT PK_WFlow PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, WFlowSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_WFlow ON src.WFlow   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.WFlow')
						AND NAME = 'PauseTaskSeq' )
	BEGIN
		ALTER TABLE src.WFlow ADD PauseTaskSeq INT NULL ;
	END ; 
GO



