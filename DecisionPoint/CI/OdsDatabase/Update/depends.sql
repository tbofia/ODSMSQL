DECLARE	 @SQLScript VARCHAR(MAX) = CAST('' AS VARCHAR(MAX)) 
 ,@StgColumnList VARCHAR(MAX) 
 ,@JoinClause VARCHAR(MAX) 
 ,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId =252) 
 ,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId =252) 
 ,@StagingSchemaName CHAR(3) = N'stg' 
 ,@SrcSchemaName CHAR(3) = N'src' 
 ,@HashbyteFunction VARCHAR(MAX) 
 ,@IsSnapshot INT = (SELECT IsSnapshot FROM adm.Process WHERE ProcessId  =252) 
 DECLARE @KeyColumnsList TABLE(TargetColumnName VARCHAR(255)); 
  SET @HashbyteFunction = (SELECT  [adm].[Etl_GenerateProcessHashbytes] (252) ) 
 --1.0 Get Join Clause for the given process to Join staging and Target 
 INSERT INTO @KeyColumnsList 
 SELECT DISTINCT I.COLUMN_NAME AS TargetColumnName 
 FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE I 
 INNER JOIN adm.Process P 
 ON I.TABLE_NAME = P.TargetTableName 
 AND OBJECTPROPERTY(OBJECT_ID(I.CONSTRAINT_SCHEMA + '.' + I.CONSTRAINT_NAME), 'IsPrimaryKey') = 1 
 AND I.TABLE_SCHEMA = @TargetSchemaName 
 WHERE P.TargetTableName = @TargetTableName 
 AND I.COLUMN_NAME NOT IN('OdsCustomerId', 'OdsPostingGroupAuditId') 
 -- Get one of columns that is part of the primary key  SET @KeyColumnSingle = (SELECT TOP 1 TargetColumnName FROM @KeyColumnsList) ; 
 --Create Join Clause 
 SELECT @JoinClause = COALESCE(@JoinClause + ' AND ', '') + 'T.' + TargetColumnName + ' = S.' + TargetColumnName 
 FROM @KeyColumnsList; 
--2.0 Get Column list for Staging tables 
 SELECT @stgColumnList = COALESCE(@stgColumnList + CHAR(13) + CHAR(10) + CHAR(9) + ',', '') + 'S.' + TargetColumnName
 FROM @KeyColumnsList 
 --4.0 Reduce Staging Data using Generated Hashbytes 
 SET @SQLScript =  'IF OBJECT_ID(''tempdb..#' + @TargetTableName +''') IS NOT NULL  DROP TABLE ' + '#' + @TargetTableName + CHAR(13) + CHAR(10) + CHAR(9) + 

'SELECT OdsPostingGroupAuditId,' + @stgColumnList + CHAR(13) + CHAR(10) + CHAR(9) +      ',S.DmlOperation' + CHAR(13) + CHAR(10) + CHAR(9) +      @HashbyteFunction + CHAR(13) + CHAR(10) +     'INTO ' + '#' + @TargetTableName + ' 
 FROM'+ ' src.'+@TargetTableName+' S ' + CHAR(13) + CHAR(10) + CHAR(9) + 'WHERE S.[OdsRowIsCurrent] = 1 AND S.[DmlOperation] <> ''D'' ;' +CHAR(13)+CHAR(10)+ 
 '-- Update Statment on Src table 
  UPDATE S 
  SET S.[OdsHashbytesValue] = T.OdsHashbytesValue' +CHAR(13)+CHAR(10)+  'FROM' + '  src.'+@TargetTableName+' S' +CHAR(13)+CHAR(10)+  ' INNER JOIN ' +'#'+@TargetTableName+' T' +CHAR(13)+CHAR(10)+  ' ON ' +@JoinClause+''+CHAR(13)+CHAR(10)+  ' WHERE S.OdsPostingGroupAuditId = T.OdsPostingGroupAuditId   ' +CHAR(13)+CHAR(10)+  ' AND S.[OdsHashbytesValue] <> T.OdsHashbytesValue '  BEGIN TRY 
 EXEC(@SQLScript); 
 END TRY 
 BEGIN CATCH 
 PRINT 'Query failed...' 
 END CATCH 
 GO 

