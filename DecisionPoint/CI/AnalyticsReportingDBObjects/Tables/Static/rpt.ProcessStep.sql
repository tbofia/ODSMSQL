IF OBJECT_ID('rpt.ProcessStep', 'U') IS NULL
BEGIN
-- Note: FullSql and IncrementalSql here can't be VARCHAR(MAX) because
-- 1) I'm using xp_cmdshell to generate the text files via bcp, and the
--	bcp command string I pass can't exceed VARCHAR(8000), and
-- 2) I'm storing the query value in a String variable in SSIS, which
--	is limited to 8000 characters.
-- If we decided in the future that 8000 characters isn't sufficient, I'll have to write
-- to write a custom script task in SSIS to read in VARCHAR(MAX) and dump to file.
    CREATE TABLE rpt.ProcessStep
        (
            ProcessStepId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            ProcessStepDescription VARCHAR(100) NULL ,
            Priority TINYINT NOT NULL ,
            FullSql VARCHAR(8000) NULL ,
            IncrementalSql VARCHAR(8000) NULL ,
            MinAppVersion VARCHAR(10) NULL
        );

    ALTER TABLE rpt.ProcessStep ADD 
    CONSTRAINT PK_ProcessStep PRIMARY KEY CLUSTERED (ProcessStepId);
END
GO
