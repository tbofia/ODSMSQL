IF NOT EXISTS ( SELECT  system_type_id
            FROM    sys.types
            WHERE   name = 'VarcharTable'
                    AND is_user_defined = 1 )
    CREATE TYPE dbo.VarcharTable AS TABLE ( 
    Code VARCHAR(255) NOT NULL
    )
GO

GRANT EXECUTE ON TYPE::dbo.VarcharTable TO MedicalUserRole
GO
