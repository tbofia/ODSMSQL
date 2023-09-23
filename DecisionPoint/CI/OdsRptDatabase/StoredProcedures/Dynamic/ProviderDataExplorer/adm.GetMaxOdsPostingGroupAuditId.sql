IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.GetMaxOdsPostingGroupAuditId') AND type in (N'P', N'PC'))
DROP PROCEDURE adm.GetMaxOdsPostingGroupAuditId
GO

CREATE PROCEDURE adm.GetMaxOdsPostingGroupAuditId(
@SourceDatabaseName VARCHAR(50), 
@OdsCustomerId INT ,
@SnapshotAsOf DATETIME
)  
AS  
BEGIN   
    
DECLARE @SQLScript VARCHAR(MAX),  
		@MaxPostingGroupAuditId INT  
      
CREATE TABLE #PostingGroupAuditData  
(  
 MaxPostingGroupAuditId INT  
)  
SET @SQLScript = ' INSERT INTO #PostingGroupAuditData  
     SELECT    
      MAX(PostingGroupAuditId) LastPostingGroupAuditId    
     FROM     
      '+@SourceDatabaseName +'.adm.PostingGroupAudit pga    
     WHERE    
      pga. CustomerId='+CAST(@OdsCustomerId AS VARCHAR(50))    
      +' AND pga.SnapshotCreateDate <= ''' + CONVERT(VARCHAR(10),@SnapshotAsOf,112) + ''''  
  
   
EXEC (@SQLScript )    
  
SET @MaxPostingGroupAuditId = (SELECT MaxPostingGroupAuditId FROM #PostingGroupAuditData)  
  
RETURN @MaxPostingGroupAuditId  
  
END
GO 


