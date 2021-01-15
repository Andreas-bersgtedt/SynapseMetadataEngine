CREATE TABLE [Metadata].[Entity] (
    [Id]                     BIGINT         IDENTITY (1, 1) NOT NULL,
    [DataSetId]              BIGINT         NOT NULL,
    [Name]                   VARCHAR (250)  NULL,
    [SchemaName]             VARCHAR (250)  NULL,
    [TargetLake]             VARCHAR (250)  NOT NULL,
    [LakeFolder]             VARCHAR (2000) NOT NULL,
    [RecordProcessTimestamp] DATETIME       NOT NULL,
    [CreatedUTCTimestamp]    DATETIME       NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);