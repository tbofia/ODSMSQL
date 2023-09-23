IF OBJECT_ID('rpt.PostingGroup', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.PostingGroup
        (
            PostingGroupId TINYINT NOT NULL ,
            PostingGroupName VARCHAR(50) NOT NULL
        );

    ALTER TABLE rpt.PostingGroup ADD 
    CONSTRAINT PK_PostingGroup PRIMARY KEY CLUSTERED (PostingGroupId);
END
GO
