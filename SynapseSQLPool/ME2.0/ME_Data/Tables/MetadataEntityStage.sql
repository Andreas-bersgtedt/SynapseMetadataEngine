CREATE TABLE [ME_Data].[MetadataEntityStage] (
    [MetadataQuerySource]               VARCHAR (50)  NULL,
    [MetadataEntityName]                VARCHAR (250) NULL,
    [MetadataSchemaName]                VARCHAR (250) NULL,
    [MetadataObjectName]                VARCHAR (250) NULL,
    [MetadataObjectType]                VARCHAR (250) NULL,
    [MetadataObjectlength]              VARCHAR (20)  NULL,
    [MetadataObjectPrecision]           VARCHAR (20)  NULL,
    [MetadataObjectScale]               VARCHAR (20)  NULL,
    [MetadataObjectCollation]           VARCHAR (250) NULL,
    [DataSetID]                         VARCHAR (20)  NULL,
    [MetadataObjectOrder]               INT           NOT NULL,
    [MetadataObjectIdentityFlag]        VARCHAR (20)  NULL,
    [MetadataObjectRefreshUTCTimeStamp] DATETIME      NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

