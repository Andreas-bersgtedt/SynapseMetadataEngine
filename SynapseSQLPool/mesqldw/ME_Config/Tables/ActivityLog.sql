CREATE TABLE [ME_Config].[ActivityLog] (
    [id]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [EventSource]       VARCHAR (50)   NOT NULL,
    [EventSourceID]     VARCHAR (100)  NOT NULL,
    [EventActivityName] VARCHAR (100)  NOT NULL,
    [EventUTCTimestamp] DATETIME       NOT NULL,
    [EventMessage]      VARCHAR (1000) NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);