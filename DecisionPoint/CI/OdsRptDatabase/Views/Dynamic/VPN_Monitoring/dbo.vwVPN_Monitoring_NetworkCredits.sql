IF OBJECT_ID ('dbo.vwVPN_Monitoring_NetworkCredits', 'V') IS NOT NULL
DROP VIEW dbo.vwVPN_Monitoring_NetworkCredits;
GO

CREATE VIEW dbo.vwVPN_Monitoring_NetworkCredits
AS
SELECT OdsCustomerId
      ,Customer
      ,Period
      ,SOJ
      ,CV_Type
      ,BillType
      ,Network
      ,Company
      ,Office
      ,ActivityFlagDesc
      ,CreditReasonDesc
      ,Credits
      ,Rundate
 FROM dbo.VPN_Monitoring_NetworkCredits_Output 
 GO
 
 