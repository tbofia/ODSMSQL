IF OBJECT_ID('rpt.FK_PostingGroupAudit_PostingGroup', 'F') IS NULL
ALTER TABLE rpt.PostingGroupAudit ADD CONSTRAINT FK_PostingGroupAudit_PostingGroup
    FOREIGN KEY (PostingGroupId)
    REFERENCES rpt.PostingGroup(PostingGroupId)
GO

IF OBJECT_ID('rpt.FK_PostingGroupAudit_DataExtractType', 'F') IS NULL
ALTER TABLE rpt.PostingGroupAudit ADD CONSTRAINT FK_PostingGroupAudit_DataExtractType
    FOREIGN KEY (DataExtractTypeId)
    REFERENCES rpt.DataExtractType(DataExtractTypeId)
GO
