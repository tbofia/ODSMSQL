IF OBJECT_ID('rpt.PrePPOBillInfo_Endnotes', 'U') IS NULL
BEGIN
CREATE TABLE rpt.PrePPOBillInfo_Endnotes(
	OdsCustomerId int NOT NULL,
	billIDNo int NULL,
	line_no int NULL,
	linetype int NULL,
	Endnotes varchar(50) NULL,
	OVER_RIDE int NULL,
	ALLOWED money NULL,
	ANALYZED money NULL,
	RunDate datetime NOT NULL DEFAULT GETDATE()
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO


