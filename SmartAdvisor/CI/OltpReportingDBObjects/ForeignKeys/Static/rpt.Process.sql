IF OBJECT_ID('rpt.FK_Process_Product', 'F') IS NULL
ALTER TABLE rpt.Process ADD CONSTRAINT FK_Process_Product
    FOREIGN KEY (ProductKey)
    REFERENCES rpt.Product(ProductKey)
GO
