IF NOT EXISTS (
		SELECT object_id
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('rpt.ProcessAudit')
			AND NAME = 'IX_PostingGroupAuditId_Status'
		)
CREATE INDEX IX_PostingGroupAuditId_Status ON rpt.ProcessAudit(PostingGroupAuditId, Status)
GO

IF NOT EXISTS (
		SELECT object_id
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('rpt.ProcessAudit')
			AND NAME = 'IX_PostingGroupAuditId_ProcessId_ProcessAuditId'
		)
CREATE INDEX IX_PostingGroupAuditId_ProcessId_ProcessAuditId ON rpt.ProcessAudit(PostingGroupAuditId, ProcessId, ProcessAuditId)
GO
