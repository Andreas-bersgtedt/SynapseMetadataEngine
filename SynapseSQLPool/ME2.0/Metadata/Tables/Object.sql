CREATE TABLE [Metadata].[Object] (
    [Id]                                BIGINT        IDENTITY (1, 1) NOT NULL,
    [EntityId]                          BIGINT        NOT NULL,
    [DataSetID]                         VARCHAR (20)  NULL,
    [MetadataObjectName]                VARCHAR (250) NULL,
    [MetadataObjectOrder]               INT           NOT NULL,
    [MetadataObjectHash]                BIGINT        NULL,
    [MetadataObjectRefreshUTCTimeStamp] DATETIME      NULL,
    [RecordProcessTimestamp]            DATETIME      NOT NULL,
    [CreatedUTCTimestamp]               DATETIME      NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

