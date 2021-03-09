CREATE PROC [ME_Config].[sp_GENERATE_DynamicRMDBS_discoverSQL] AS
BEGIN
SELECT SQLQuery=REPLACE('
SELECT ¬'+C.Connectiontype+'¬ AS DataSetType,¬999¬ AS RunGroupCode,TABLE_NAME AS DataSetName,TABLE_SCHEMA AS SchemaName
,¬RAW¬ AS TargetLake,¬'+CONVERT(VARCHAR(20),C.iD)+'¬ AS ConnectionId
,0 AS IsEnabled
  FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_TYPE=¬BASE TABLE¬
  '+CASE WHEN C.Connectiontype='MYSQL' 
		THEN 'AND TABLE_SCHEMA NOT IN (¬mysql¬,¬performance_schema¬,¬sys¬) '
		ELSE '' END
,'¬','''')
  ,[DataSetType]=C.Connectiontype, 
		DBServerName=C.[ConnectionString],
		DBName=C.[ConnectionName],
		SQLKVName=C.[ConnectionKVSecret]
		,SqlUserName=C.[ConnetionUserName]
		  ,DLContainer='metadata'
	  ,DLFolder='me_config_dataset'
	  ,DLFileName=LOWER(CONCAT(C.[ConnectionName],'_',C.[ConnectionKVSecret]))
  FROM [ME_Config].[Connection] C
  Where C.id not in (SELECT ConnectionId From [ME_Config].[DataSet])
  and C.Connectiontype IN ('MSSQL','MYSQL')



  END