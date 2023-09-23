IF NOT EXISTS (
		SELECT object_id
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('adm.ProcessAudit')
			AND NAME = 'IX_PostingGroupAuditId_Status'
		)
CREATE INDEX IX_PostingGroupAuditId_Status ON adm.ProcessAudit(PostingGroupAuditId, Status)
GO

IF NOT EXISTS (
		SELECT object_id
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('adm.ProcessAudit')
			AND NAME = 'IX_PostingGroupAuditId_ProcessId_ProcessAuditId'
		)
CREATE INDEX IX_PostingGroupAuditId_ProcessId_ProcessAuditId ON adm.ProcessAudit(PostingGroupAuditId, ProcessId, ProcessAuditId)
GO
