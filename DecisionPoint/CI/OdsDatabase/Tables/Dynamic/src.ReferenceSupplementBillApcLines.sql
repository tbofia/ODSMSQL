
IF OBJECT_ID('src.ReferenceSupplementBillApcLines', 'U') IS NULL
BEGIN
	CREATE TABLE src.ReferenceSupplementBillApcLines (
		OdsPostingGroupAuditId INT NOT NULL ,
		OdsCustomerId INT NOT NULL ,
		OdsCreateDate DATETIME2(7) NOT NULL ,
		OdsSnapshotDate DATETIME2(7) NOT NULL ,
		OdsRowIsCurrent BIT NOT NULL ,
		OdsHashbytesValue VARBINARY(8000) NULL ,
		DmlOperation CHAR(1) NOT NULL ,
		BillIdNo INT NOT NULL,
		SeqNo SMALLINT NOT NULL,
		Line_No SMALLINT NOT NULL,
		PaymentAPC VARCHAR(5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		ServiceIndicator VARCHAR(2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		PaymentIndicator VARCHAR(1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		OutlierAmount DECIMAL(19,4) NULL,
		PricerAllowed DECIMAL(19,4) NULL,
		MedicareAmount DECIMAL(19,4) NULL	
		)ON DP_Ods_PartitionScheme(OdsCustomerId)
		WITH (
		DATA_COMPRESSION = PAGE);


	ALTER TABLE src.ReferenceSupplementBillApcLines ADD CONSTRAINT PK_ReferenceSupplementBillApcLines PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId, 
		OdsCustomerId, 
		BillIdNo,
		SeqNo,
		Line_No
		)WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_ReferenceSupplementBillApcLines ON src.ReferenceSupplementBillApcLines REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END

GO
