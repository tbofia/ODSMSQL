IF OBJECT_ID('dbo.if_Bills_Tax', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Bills_Tax;
GO

CREATE FUNCTION dbo.if_Bills_Tax(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.BillsTaxId,
	t.TableType,
	t.BillIdNo,
	t.Line_No,
	t.SeqNo,
	t.TaxTypeId,
	t.ImportTaxRate,
	t.Tax,
	t.OverridenTax,
	t.ImportTaxAmount
FROM src.Bills_Tax t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillsTaxId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Tax
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillsTaxId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillsTaxId = s.BillsTaxId
WHERE t.DmlOperation <> 'D';

GO


