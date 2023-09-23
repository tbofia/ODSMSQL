IF OBJECT_ID('src.DeductibleRuleExemptEndnote', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.DeductibleRuleExemptEndnote
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Endnote INT NOT NULL ,
			  EndnoteTypeId TINYINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.DeductibleRuleExemptEndnote ADD 
     CONSTRAINT PK_DeductibleRuleExemptEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Endnote, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_DeductibleRuleExemptEndnote ON src.DeductibleRuleExemptEndnote   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO

 IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.DeductibleRuleExemptEndnote')
                    AND c.name = 'Endnote'
                    AND NOT ( t.name = 'INT'
                            ) )
    BEGIN
		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE i.is_primary_key = 1 AND SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote'
		)
		ALTER TABLE src.DeductibleRuleExemptEndnote DROP CONSTRAINT PK_DeductibleRuleExemptEndnote;

		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote' 
			AND i.name = 'IX_Endnote_EndnoteTypeId_OdsCustomerId_OdsPostingGroupAuditId'
		)
		DROP INDEX IX_Endnote_EndnoteTypeId_OdsCustomerId_OdsPostingGroupAuditId ON src.DeductibleRuleExemptEndnote;

		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote' 
			AND i.name = 'IX_OdsPostingGroupAuditId_DmlOperation'
		)
		DROP INDEX IX_OdsPostingGroupAuditId_DmlOperation ON src.DeductibleRuleExemptEndnote;

		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote' 
			AND i.name = 'IX_OdsCustomerId_OdsRowIsCurrent'
		)
		DROP INDEX IX_OdsCustomerId_OdsRowIsCurrent ON src.DeductibleRuleExemptEndnote;

        ALTER TABLE src.DeductibleRuleExemptEndnote ALTER COLUMN Endnote INT NOT NULL;
    END;
GO

 IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.DeductibleRuleExemptEndnote')
                    AND c.name = 'EndnoteTypeId'
                    AND NOT ( t.name = 'TINYINT'
                            ) )
    BEGIN
		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE i.is_primary_key = 1 AND SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote'
		)
		ALTER TABLE src.DeductibleRuleExemptEndnote DROP CONSTRAINT PK_DeductibleRuleExemptEndnote;

		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote' 
			AND i.name = 'IX_Endnote_EndnoteTypeId_OdsCustomerId_OdsPostingGroupAuditId'
		)
		DROP INDEX IX_Endnote_EndnoteTypeId_OdsCustomerId_OdsPostingGroupAuditId ON src.DeductibleRuleExemptEndnote;

		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote' 
			AND i.name = 'IX_OdsPostingGroupAuditId_DmlOperation'
		)
		DROP INDEX IX_OdsPostingGroupAuditId_DmlOperation ON src.DeductibleRuleExemptEndnote;

		IF EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote' 
			AND i.name = 'IX_OdsCustomerId_OdsRowIsCurrent'
		)
		DROP INDEX IX_OdsCustomerId_OdsRowIsCurrent ON src.DeductibleRuleExemptEndnote;

        ALTER TABLE src.DeductibleRuleExemptEndnote ALTER COLUMN EndnoteTypeId TINYINT NOT NULL;
    END;
GO

IF NOT EXISTS (
			SELECT 1 FROM sys.tables t
			INNER JOIN sys.indexes i ON i.object_id = t.object_id
			WHERE i.is_primary_key = 1 AND SCHEMA_NAME(t.schema_id) = 'src' AND t.name = 'DeductibleRuleExemptEndnote'
		)
BEGIN
	 ALTER TABLE src.DeductibleRuleExemptEndnote 
	 ADD CONSTRAINT PK_DeductibleRuleExemptEndnote PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Endnote, EndnoteTypeId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_DeductibleRuleExemptEndnote ON src.DeductibleRuleExemptEndnote   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
END
GO
