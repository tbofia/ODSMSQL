IF NOT EXISTS ( SELECT  system_type_id
                FROM    sys.types
                WHERE   name = 'IntegerTable'
                        AND is_user_defined = 1 )
    CREATE TYPE dbo.IntegerTable AS TABLE ( 
    Id INT NOT NULL
    )
GO

GRANT EXECUTE ON TYPE::dbo.IntegerTable TO MedicalUserRole
GO
