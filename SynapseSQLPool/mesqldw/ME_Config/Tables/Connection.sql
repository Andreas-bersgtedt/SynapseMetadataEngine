CREATE TABLE [ME_Config].[Connection] (
    [Id]                 BIGINT        IDENTITY (1, 1) NOT NULL,
    [ConnectionType]     VARCHAR (100) NOT NULL,
    [ConnectionName]     VARCHAR (250) NOT NULL,
    [ConnectionString]   VARCHAR (100) NULL,
    [ConnectionKVSecret] VARCHAR (250) NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);