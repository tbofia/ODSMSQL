IF OBJECT_ID('dbo.TableLookUp', 'V') IS NOT NULL
    DROP VIEW dbo.TableLookUp;
GO

CREATE VIEW dbo.TableLookUp
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,TableCode
	,TypeCode
	,Code
	,SiteCode
	,OldCode
	,ShortDesc
	,Source
	,Priority
	,LongDesc
	,OwnerApp
	,RecordStatus
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.TableLookUp
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


