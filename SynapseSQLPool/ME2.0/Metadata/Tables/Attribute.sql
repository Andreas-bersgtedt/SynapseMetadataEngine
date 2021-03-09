CREATE TABLE [Metadata].[Attribute] (
    [Id]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [EntityId]               BIGINT          NOT NULL,
    [ObjectId]               BIGINT          NULL,
    [MetadataObjectHash]     BIGINT          NULL,
    [DataSetID]              VARCHAR (20)    NULL,
    [KEY]                    VARCHAR (100)   NULL,
    [Value]                  NVARCHAR (4000) NULL,
    [KeyValueDataType]       VARCHAR (50)    NULL,
    [KeyValueRefreshDate]    DATETIME        NOT NULL,
    [RecordProcessTimestamp] DATETIME        NOT NULL,
    [CreatedUTCTimestamp]    DATETIME        NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

