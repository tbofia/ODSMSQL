IF OBJECT_ID('rpt.CustomerReconciliation', 'U') IS NOT NULL 
DROP TABLE rpt.CustomerReconciliation;
GO

CREATE TABLE rpt.CustomerReconciliation  (
		 ProcessId INT NOT NULL
		,TargetTableName VARCHAR(100) NOT NULL
		,SnapshotCreateDate DATETIME NOT NULL
        );

GO

