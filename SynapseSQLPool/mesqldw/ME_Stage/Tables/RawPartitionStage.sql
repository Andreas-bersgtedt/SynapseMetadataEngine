CREATE TABLE [ME_Stage].[RawPartitionStage] (
    [Id]               BIGINT        IDENTITY (1, 1) NOT NULL,
    [DatasetID]        INT           NOT NULL,
    [Partition_String] VARCHAR (100) NOT NULL,
    [Row_Count]        BIGINT        NOT NULL,
    [InsertTimestamp]  DATETIME2 (7) NOT NULL,
    [Status]           INT           DEFAULT ((0)) NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);