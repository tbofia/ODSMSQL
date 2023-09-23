IF OBJECT_ID('rpt.ProcessStepAudit', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.ProcessStepAudit
        (
            ProcessStepAuditId INT IDENTITY(1, 1) ,
            ProcessAuditId INT NOT NULL ,
            ProcessStepId INT NOT NULL ,
            PreviousCheckpoint BIGINT NULL ,
            CurrentCheckpoint BIGINT NULL ,
            CompleteDate DATETIME2(7) NULL ,
            TotalRowsAffected INT NULL ,
            CreateDate DATETIME2(7) NOT NULL ,
            LastChangeDate DATETIME2(7) NOT NULL
        );

    ALTER TABLE rpt.ProcessStepAudit ADD 
    CONSTRAINT PK_ProcessStepAudit PRIMARY KEY CLUSTERED (ProcessStepAuditId);
END
GO
