
IF OBJECT_ID('src.ReferenceBillApcLines', 'U') IS NULL
BEGIN
	CREATE TABLE src.ReferenceBillApcLines
	(
		OdsPostingGroupAuditId INT NOT NULL ,
		OdsCustomerId INT NOT NULL ,
		OdsCreateDate DATETIME2(7) NOT NULL ,
		OdsSnapshotDate DATETIME2(7) NOT NULL ,
		OdsRowIsCurrent BIT NOT NULL ,
		OdsHashbytesValue VARBINARY(8000) NULL ,
		DmlOperation CHAR(1) NOT NULL ,
		BillIdNo INT NOT NULL,
		Line_No SMALLINT NOT NULL,
		PaymentAPC VARCHAR(5) NULL,
		ServiceIndicator VARCHAR(2) NULL,
		PaymentIndicator VARCHAR(1) NULL,
		OutlierAmount DECIMAL(19,4) NULL,
		PricerAllowed DECIMAL(19,4) NULL,
		MedicareAmount DECIMAL(19,4) NULL
	)ON DP_Ods_PartitionScheme(OdsCustomerId)
		WITH (
		DATA_COMPRESSION = PAGE);
		
	ALTER TABLE src.ReferenceBillApcLines
	ADD CONSTRAINT PK_ReferenceBillApcLines
	PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo, Line_No)
	WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
	
	ALTER INDEX PK_ReferenceBillApcLines ON src.ReferenceBillApcLines REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END

GO
