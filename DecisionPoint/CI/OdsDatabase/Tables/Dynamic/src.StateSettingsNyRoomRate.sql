IF OBJECT_ID('src.StateSettingsNyRoomRate', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsNyRoomRate
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StateSettingsNyRoomRateId INT NOT NULL ,
			  StartDate DATETIME NULL ,
			  EndDate DATETIME NULL ,
			  RoomRate MONEY NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingsNyRoomRate ADD 
     CONSTRAINT PK_StateSettingsNyRoomRate PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StateSettingsNyRoomRateId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsNyRoomRate ON src.StateSettingsNyRoomRate   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
