IF OBJECT_ID('adm.Customer', 'U') IS NOT NULL
DROP TABLE adm.Customer
GO
IF OBJECT_ID('adm.PostingGroup', 'U') IS NOT NULL
DROP TABLE adm.PostingGroup
GO
IF OBJECT_ID('adm.Process', 'U') IS NOT NULL
DELETE FROM  adm.Process WHERE ProductKey IN ('SmartAdvisor' ,'WcsOds')
GO
IF OBJECT_ID('adm.Product', 'U') IS NOT NULL
DELETE FROM  adm.Product WHERE ProductKey IN ('SmartAdvisor' ,'WcsOds')
GO
IF OBJECT_ID('adm.DataExtractType', 'U') IS NOT NULL
DROP TABLE adm.DataExtractType
GO
IF OBJECT_ID('adm.StatusCode', 'U') IS NOT NULL
DROP TABLE adm.StatusCode
GO

