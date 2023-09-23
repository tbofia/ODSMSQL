SET XACT_ABORT ON
GO

BEGIN TRANSACTION

UPDATE  SEC_Users
SET     Password = 'Q6*<6:23m' ,
        UserStatus = -1 ,
        AccountLocked = 0 ,
		PasswordCreateDate =  GETDATE() ,
        ePassword = 'Q6*<6:23m'
WHERE   LoginName = 'MITCHELL'


DELETE  FROM a
FROM    dbo.SEC_User_RightGroups a
        INNER JOIN dbo.SEC_Users b ON a.UserId = b.UserId
WHERE   b.LoginName = 'MITCHELL'
INSERT  INTO dbo.SEC_User_RightGroups
        ( UserId ,
          RightGroupId
        )
        SELECT  UserId ,
                1
        FROM    dbo.SEC_Users
        WHERE   LoginName = 'MITCHELL'

COMMIT TRANSACTION
GO
