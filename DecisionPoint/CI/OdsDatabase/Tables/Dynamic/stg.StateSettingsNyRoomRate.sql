IF OBJECT_ID('stg.StateSettingsNyRoomRate', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsNyRoomRate  
BEGIN
	CREATE TABLE stg.StateSettingsNyRoomRate
		(
		  StateSettingsNyRoomRateId INT NULL,
		  StartDate DATETIME NULL,
		  EndDate DATETIME NULL,
		  RoomRate MONEY NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

