CREATE TABLE [ME_Secure].[DL_Containers] (
    [Id]                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [DLContainerName]      VARCHAR (500)  NOT NULL,
    [DLstorageaccountname] VARCHAR (500)  NOT NULL,
    [DLKVSecretName]       VARCHAR (500)  NOT NULL,
    [KeyVaultName]         VARCHAR (1000) NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);