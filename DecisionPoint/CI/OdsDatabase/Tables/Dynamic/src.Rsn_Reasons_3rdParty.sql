IF OBJECT_ID ('src.Rsn_Reasons_3rdParty', 'U') IS NULL
	BEGIN
		CREATE TABLE src.Rsn_Reasons_3rdParty
			(
			  OdsPostingGroupAuditId INT NOT NULL ,
			  OdsCustomerId INT NOT NULL ,
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL ,
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,
			  ReasonNumber INT NOT NULL,
			  ShortDesc VARCHAR(50) NULL,
			  LongDesc VARCHAR(MAX) NULL
			)
		ON DP_Ods_PartitionScheme(OdsCustomerId)
			WITH (
				DATA_COMPRESSION = PAGE);

		ALTER TABLE src.Rsn_Reasons_3rdParty ADD 
		CONSTRAINT PK_Rsn_Reasons_3rdParty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReasonNumber) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);


		ALTER INDEX PK_Rsn_Reasons_3rdParty ON src.Rsn_Reasons_3rdParty REBUILD WITH(STATISTICS_INCREMENTAL = ON);

	END
GO
