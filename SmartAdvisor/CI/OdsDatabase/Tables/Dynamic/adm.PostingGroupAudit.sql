SET NOCOUNT ON;
IF OBJECT_ID('adm.PostingGroupAudit', 'U') IS NULL
BEGIN
    CREATE TABLE adm.PostingGroupAudit
        (
            PostingGroupAuditId INT IDENTITY(1, 1) ,
            OltpPostingGroupAuditId INT NOT NULL,
            PostingGroupId TINYINT NOT NULL ,
            CustomerId INT NOT NULL,
            Status VARCHAR(2) NOT NULL ,
            DataExtractTypeId INT NOT NULL ,
            OdsVersion VARCHAR(10) NULL ,
            SnapshotCreateDate DATETIME2(7) NULL ,
            SnapshotDropDate DATETIME2(7) NULL ,
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE adm.PostingGroupAudit ADD 
    CONSTRAINT PK_PostingGroupAudit PRIMARY KEY CLUSTERED (PostingGroupAuditId);
END
GO

-- Rename AppVersion Column.
IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.PostingGroupAudit')
                        AND NAME = 'AppVersion' )
BEGIN
    EXEC sp_RENAME 'adm.PostingGroupAudit.AppVersion', 'OdsVersion', 'COLUMN'
END
GO

-- Rename IsIncremental Column
IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.PostingGroupAudit')
                        AND NAME = 'IsIncremental' )
BEGIN
    EXEC sp_RENAME 'adm.PostingGroupAudit.IsIncremental', 'DataExtractTypeId', 'COLUMN'
END
GO

-- Rename SnapshotDropDate Column
IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'adm.PostingGroupAudit')
                        AND NAME = 'SnapshotDropDate' )
BEGIN
    EXEC sp_RENAME 'adm.PostingGroupAudit.SnapshotDropDate', 'CoreDBVersionId', 'COLUMN'
END
GO

-- Change Datatype to INT Note. Have to change to Varchar first because cannot directly alter from Datetime2 to int
IF EXISTS ( SELECT 1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'adm.PostingGroupAudit')
                    AND c.name = 'CoreDBVersionId'
                    AND NOT t.name = 'INT' 
					)
    BEGIN
        ALTER TABLE adm.PostingGroupAudit ALTER COLUMN CoreDBVersionId VARCHAR NULL; 

		ALTER TABLE adm.PostingGroupAudit ALTER COLUMN CoreDBVersionId INT NULL;
    END;
GO
