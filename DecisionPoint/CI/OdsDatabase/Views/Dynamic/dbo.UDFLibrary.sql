IF OBJECT_ID('dbo.UDFLibrary', 'V') IS NOT NULL
    DROP VIEW dbo.UDFLibrary;
GO

CREATE VIEW dbo.UDFLibrary
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,UDFIdNo
	,UDFName
	,ScreenType
	,UDFDescription
	,DataFormat
	,RequiredField
	,ReadOnly
	,Invisible
	,TextMaxLength
	,TextMask
	,TextEnforceLength
	,RestrictRange
	,MinValDecimal
	,MaxValDecimal
	,MinValDate
	,MaxValDate
	,ListAllowMultiple
	,DefaultValueText
	,DefaultValueDecimal
	,DefaultValueDate
	,UseDefault
	,ReqOnSubmit
	,IncludeDateButton
FROM src.UDFLibrary
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


