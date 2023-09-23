SET XACT_ABORT ON
IF OBJECT_ID('rpt.ProcessCheckpoint', 'U') IS NULL
    BEGIN
        BEGIN TRANSACTION
        CREATE TABLE rpt.ProcessCheckpoint
            (
              ProcessId SMALLINT NOT NULL ,
              PreviousCheckpoint BIGINT NOT NULL ,
              LastChangeDate DATETIME2(7) NOT NULL
            );

        ALTER TABLE rpt.ProcessCheckpoint ADD 
        CONSTRAINT PK_ProcessCheckpoint PRIMARY KEY CLUSTERED (ProcessId);

		-- When we push the table, we'll want to copy over the existing checkpoints.
		IF OBJECT_ID('rpt.ProcessStepAudit', 'U') IS NOT NULL
		BEGIN
				INSERT  INTO rpt.ProcessCheckpoint
						( ProcessId ,
						  PreviousCheckpoint ,
						  LastChangeDate
						)
						SELECT  ps.ProcessId ,
								MAX(psa.CurrentCheckpoint) AS PreviousCheckpoint ,
								GETDATE()
						FROM    rpt.ProcessStepAudit psa
								INNER JOIN rpt.ProcessStep ps ON psa.ProcessStepId = ps.ProcessStepId
						WHERE   psa.CompleteDate IS NOT NULL
						GROUP BY ps.ProcessId;
		END
        COMMIT TRANSACTION
    END
GO
