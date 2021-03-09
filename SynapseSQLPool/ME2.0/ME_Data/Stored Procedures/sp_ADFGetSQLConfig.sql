CREATE PROC [ME_Data].[sp_ADFGetSQLConfig] @DataSetType [VARCHAR](100),@RunGroupCode [VARCHAR](20) AS
BEGIN

SELECT	d.[DataSetType], 
		DBServerName=C.[ConnectionString],
		DBName=C.[ConnectionName],
		SQLKVName=C.[ConnectionKVSecret]
		,SqlUserName=C.[ConnectionKVSecret]
       ,D.[DataSetName]
      ,D.[SchemaName]
      ,DLContainer=LOWER(E.TargetLake)
	  ,DLFolder=LOWER(E.LakeFolder)
	  ,DLFileName=LOWER(CONCAT(D.[SchemaName],'_',D.[DataSetName]))
      ,SQLQuery=CONVERT(NVARCHAR(MAX),'SELECT '+COLS.Cols/*[ME_Config].[fnGetRMDBSQuerySelectColumnNames](E.Id)*/+' FROM ['+E.[SchemaName]+'].['+E.[Name]+']')
      
FROM	[ME_Config].[DataSet] D
		INNER JOIN [ME_Config].[Connection] C ON D.[ConnectionId]=C.id
		INNER JOIN Metadata.Entity E ON D.Id=E.DatasetId AND D.[IsEnabled]=1
		INNER JOIN (   
					SELECT Cols=CONVERT(NVARCHAR(MAX),(ISNULL	(
						STRING_AGG('['+REPLACE([MetadataObjectName],' ','_')+']=['+[MetadataObjectName]+']',',')
						WITHIN GROUP ( ORDER BY [MetadataObjectOrder]  ASC  )
						,'*'
						))),EntityID
					FROM MEtadata.[object] 
					Where EntityID IN (
					SELECT DISTINCT EntityID 
					FROM MEtadata.[object] 
					where [MetadataObjectName] LIKE '% %'
										) 
										GROUP BY EntityID
					 
					) AS COLS ON COLS.EntityID=E.Id

WHERE	D.DataSetType=@DataSetType
		AND (D.RunGroupCode=@RunGroupCode OR @RunGroupCode='-1')
		AND D.IsEnabled < 2

END