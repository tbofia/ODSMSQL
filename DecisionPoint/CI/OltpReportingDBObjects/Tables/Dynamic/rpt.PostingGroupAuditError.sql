IF OBJECT_ID('rpt.PostingGroupAuditError', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.PostingGroupAuditError
        (
            PostingGroupAuditErrorId INT IDENTITY(1, 1) ,
            PostingGroupAuditId INT NOT NULL ,
            ErrorCode VARCHAR(5) NOT NULL ,
            ErrorDescription VARCHAR(MAX) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL ,
        );

    ALTER TABLE rpt.PostingGroupAuditError ADD 
    CONSTRAINT PK_PostingGroupAuditError PRIMARY KEY CLUSTERED (PostingGroupAuditErrorId);
END
GO
