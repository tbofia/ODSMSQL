IF OBJECT_ID('adm.PostingGroup', 'U') IS NULL
BEGIN
    CREATE TABLE adm.PostingGroup
        (
            PostingGroupId TINYINT NOT NULL ,
            PostingGroupName VARCHAR(50) NOT NULL
        );

    ALTER TABLE adm.PostingGroup ADD 
    CONSTRAINT PK_PostingGroup PRIMARY KEY CLUSTERED (PostingGroupId);
END
GO
