-- Removing rpt.fn_IsVersion1LessThanOrEqualToVersion2 from AcsOds v1.1 because
-- I'm using the HIERARCHYID data type to compare versions instead.
IF OBJECT_ID('rpt.fn_IsVersion1LessThanOrEqualToVersion2') IS NOT NULL
    DROP FUNCTION rpt.fn_IsVersion1LessThanOrEqualToVersion2
GO
