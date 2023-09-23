IF OBJECT_ID('stg.ETL_ControlFiles', 'U') IS NOT NULL
DROP TABLE stg.ETL_ControlFiles
BEGIN
	CREATE TABLE stg.ETL_ControlFiles
		(ControlFileName VARCHAR(255) NOT NULL,
		 OltpPostingGroupAuditId INT NOT NULL,
		 SnapshotDate Datetime NOT NULL,
		 DataFileName VARCHAR(255) NOT NULL,
		 TargetTableName VARCHAR(100) NOT NULL,
		 RowsExtracted INT NULL,
		 TotalRowCount BIGINT NULL,
		 OdsVersion VARCHAR(20)
		 );
 END
 GO
 