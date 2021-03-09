CREATE PROC [ME_Config].[sp_ADFGetDynamicRDBMSQuery] @DataSetType [VARCHAR](100),@RunGroupCode [VARCHAR](20) AS
BEGIN

SELECT	d.[DataSetType], 
		DBServerName=C.[ConnectionString],
		DBName=C.[ConnectionName],
		SQLKVName=C.[ConnectionKVSecret]
		,SqlUserName=C.[ConnetionUserName]
       ,[DataSetName]
      ,[SchemaName]
      ,DLContainer='metadata'
	  ,DLFolder='inbound'
	  ,DLFileName=LOWER(CONCAT(D.[SchemaName],'_',D.[DataSetName]))
      ,SQLQuery=	ME_Config.fnGetRMDBSQuery(
					CONVERT(VARCHAR(20),D.id), 
					CONVERT(VARCHAR(250),D.DataSetName),
					CONVERT(VARCHAR(250),D.SchemaName), 
					CONVERT(VARCHAR(100),D.DataSetType)
					)
      
FROM	[ME_Config].[DataSet] D
		INNER JOIN [ME_Config].[Connection] C ON D.[ConnectionId]=C.id

WHERE	D.DataSetType=@DataSetType
		AND (D.RunGroupCode=@RunGroupCode OR @RunGroupCode='-1')
		AND D.IsEnabled < 2

END