IF OBJECT_ID('rpt.PostingGroupProcess', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.PostingGroupProcess
        (
            PostingGroupId TINYINT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Priority TINYINT NOT NULL
        );

    ALTER TABLE rpt.PostingGroupProcess ADD 
    CONSTRAINT PK_PostingGroupProcess PRIMARY KEY CLUSTERED (PostingGroupId, ProcessId);
END
GO
