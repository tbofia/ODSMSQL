IF OBJECT_ID('dbo.PROVIDER', 'V') IS NOT NULL
    DROP VIEW dbo.PROVIDER;
GO

CREATE VIEW dbo.PROVIDER
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PvdIDNo
	,PvdMID
	,PvdSource
	,PvdTIN
	,PvdLicNo
	,PvdCertNo
	,PvdLastName
	,PvdFirstName
	,PvdMI
	,PvdTitle
	,PvdGroup
	,PvdAddr1
	,PvdAddr2
	,PvdCity
	,PvdState
	,PvdZip
	,PvdZipPerf
	,PvdPhone
	,PvdFAX
	,PvdSPC_List
	,PvdAuthNo
	,PvdSPC_ACD
	,PvdUpdateCounter
	,PvdPPO_Provider
	,PvdFlags
	,PvdERRate
	,PvdSubNet
	,InUse
	,PvdStatus
	,PvdElectroStartDate
	,PvdElectroEndDate
	,PvdAccredStartDate
	,PvdAccredEndDate
	,PvdRehabStartDate
	,PvdRehabEndDate
	,PvdTraumaStartDate
	,PvdTraumaEndDate
	,OPCERT
	,PvdDentalStartDate
	,PvdDentalEndDate
	,PvdNPINo
	,PvdCMSId
	,CreateDate
	,LastChangedOn
FROM src.PROVIDER
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


