
IF OBJECT_ID('stg.UDFLevelChangeTracking', 'U') IS NOT NULL
DROP TABLE stg.UDFLevelChangeTracking
BEGIN
	CREATE TABLE stg.UDFLevelChangeTracking 
	(
		UDFLevelChangeTrackingId INT NULL,
	    EntityType INT NULL,
		EntityId INT NULL,
		CorrelationId VARCHAR(50) NULL,
		UDFId INT NULL,  
		PreviousValue VARCHAR(MAX) NULL,
		UpdatedValue VARCHAR(MAX) NULL,
        UserId INT NULL,
		ChangeDate DATETIME2 NULL,
		DmlOperation CHAR(1) NOT NULL
	)
END
GO

