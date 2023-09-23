IF NOT EXISTS ( SELECT  system_type_id
                FROM    sys.types
                WHERE   name = 'KeyValuePairTable'
                        AND is_user_defined = 1 )
    CREATE TYPE dbo.KeyValuePairTable AS TABLE ( 
    [Key] INT NOT NULL, 
    [Value] VARCHAR(255) NOT NULL
    )
GO
