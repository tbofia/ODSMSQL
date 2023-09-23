SET NOCOUNT ON;
BEGIN TRANSACTION
BEGIN TRY

	IF OBJECT_ID('dbo.Practitioner', 'V') IS NOT NULL
					DROP VIEW dbo.Practitioner

	IF OBJECT_ID('dbo.if_Practitioner') IS NOT NULL
					DROP FUNCTION dbo.if_Practitioner
				
	IF OBJECT_ID('stg.Practitioner', 'U') IS NOT NULL
					DROP TABLE stg.Practitioner 
				
	IF OBJECT_ID('src.Practitioner', 'U') IS NOT NULL
					DROP TABLE src.Practitioner

	IF OBJECT_ID('dbo.PractitionerChild', 'V') IS NOT NULL
					DROP VIEW dbo.PractitionerChild

	IF OBJECT_ID('dbo.if_PractitionerChild') IS NOT NULL
					DROP FUNCTION dbo.if_PractitionerChild
				
	IF OBJECT_ID('stg.PractitionerChild', 'U') IS NOT NULL
					DROP TABLE stg.PractitionerChild 
				
	IF OBJECT_ID('src.PractitionerChild', 'U') IS NOT NULL
					DROP TABLE src.PractitionerChild

	COMMIT
END TRY
BEGIN CATCH
	PRINT 'Error: Cound Not Rollback Changes made on Previous version...'
	ROLLBACK
END CATCH
GO

