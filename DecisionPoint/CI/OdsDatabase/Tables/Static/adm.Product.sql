IF OBJECT_ID('adm.Product', 'U') IS NULL
BEGIN
    CREATE TABLE adm.Product
        (
            ProductKey VARCHAR(100) NOT NULL ,
            Name VARCHAR(100) NOT NULL ,
            SchemaName VARCHAR(10) NOT NULL
        );

    ALTER TABLE adm.Product ADD 
    CONSTRAINT PK_EtlProduct PRIMARY KEY CLUSTERED (ProductKey);
END
GO

