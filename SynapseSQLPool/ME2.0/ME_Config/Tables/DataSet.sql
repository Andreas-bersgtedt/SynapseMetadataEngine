CREATE TABLE [ME_Config].[DataSet] (
    [Id]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [DataSetType]  VARCHAR (100) NOT NULL,
    [RunGroupCode] VARCHAR (20)  NOT NULL,
    [DataSetName]  VARCHAR (250) NOT NULL,
    [SchemaName]   VARCHAR (100) NULL,
    [TargetLake]   VARCHAR (250) NOT NULL,
    [ConnectionId] BIGINT        NOT NULL,
    [IsEnabled]    INT           DEFAULT ((0)) NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

