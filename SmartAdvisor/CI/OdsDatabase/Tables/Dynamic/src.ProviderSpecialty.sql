IF OBJECT_ID('src.ProviderSpecialty', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProviderSpecialty
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Id UNIQUEIDENTIFIER NOT NULL ,
			  Description NVARCHAR (MAX) NULL ,
			  ImplementationDate SMALLDATETIME NULL ,
			  DeactivationDate SMALLDATETIME NULL ,
			  DataSource UNIQUEIDENTIFIER NULL ,
			  Creator NVARCHAR (16) NULL ,
			  CreateDate SMALLDATETIME NULL ,
			  LastUpdater NVARCHAR (16) NULL ,
			  LastUpdateDate SMALLDATETIME NULL ,
			  CbrCode NVARCHAR(4) NULL ,

 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProviderSpecialty ADD 
     CONSTRAINT PK_ProviderSpecialty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Id) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProviderSpecialty ON src.ProviderSpecialty   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.ProviderSpecialty')
					AND c.name = 'Creator' 
					AND NOT ( t.name = 'NVARCHAR' 
						 AND c.max_length = '128'
						   ) ) 
	BEGIN
		ALTER TABLE src.ProviderSpecialty ALTER COLUMN Creator NVARCHAR(128) NULL ;
	END ; 
GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.ProviderSpecialty')
					AND c.name = 'LastUpdater' 
					AND NOT ( t.name = 'NVARCHAR' 
						 AND c.max_length = '128'
						   ) ) 
	BEGIN
		ALTER TABLE src.ProviderSpecialty ALTER COLUMN LastUpdater NVARCHAR(128) NULL ;
	END ; 
GO


IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.ProviderSpecialty')
						AND NAME = 'CbrCode' )
	BEGIN
		ALTER TABLE src.ProviderSpecialty ADD CbrCode NVARCHAR(4) NULL ;
	END ; 
GO



