IF OBJECT_ID('stg.DP_PerformanceReport_MaxPrePPOBillInfo', 'U') IS NOT NULL
DROP TABLE stg.DP_PerformanceReport_MaxPrePPOBillInfo
BEGIN
CREATE TABLE stg.DP_PerformanceReport_MaxPrePPOBillInfo(
	 OdsCustomerId INT NOT NULL
	,billIDNo INT
	,line_no INT
	,line_type INT
	,Endnotes VARCHAR (50)
	,OVER_RIDE INT
	,ALLOWED MONEY DEFAULT 0.00
	,ANALYZED MONEY DEFAULT 0.00
	,RunDate datetime NOT NULL DEFAULT GETDATE()
	)
END
GO

