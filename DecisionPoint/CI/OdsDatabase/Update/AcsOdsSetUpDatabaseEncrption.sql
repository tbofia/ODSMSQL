-- Create Table to Store Encrypted Data
IF OBJECT_ID('ReportDB..OdsCustomerCLAIMS_Encrypted') IS NOT NULL DROP TABLE ReportDB..OdsCustomerCLAIMS_Encrypted
CREATE TABLE ReportDB..OdsCustomerCLAIMS_Encrypted(
	OdsPostingGroupAuditId int NOT NULL,
	OdsCustomerId int NOT NULL,
	ClaimIDNo int NOT NULL,
	ClaimNo_Encrypted VARCHAR(MAX) NULL,
	ClaimNo VARCHAR(MAX),
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
)

-- Create Procedure to Mast Data


-- Create database Key
-- DROP MASTER KEY; 
USE AcsOds
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'password';
GO

-- Create self signed certificate
-- DROP CERTIFICATE AcsOds_Certificate
USE AcsOds;
GO
CREATE CERTIFICATE AcsOds_Certificate
WITH SUBJECT = 'Protect Data';
GO

-- Create symmetric Key
-- CLOSE SYMMETRIC KEY AcsOds_SymmetricKey;  
-- DROP SYMMETRIC KEY AcsOds_SymmetricKey;  
USE AcsOds;
GO
CREATE SYMMETRIC KEY AcsOds_SymmetricKey
 WITH ALGORITHM = AES_128 
 ENCRYPTION BY CERTIFICATE AcsOds_Certificate;
GO