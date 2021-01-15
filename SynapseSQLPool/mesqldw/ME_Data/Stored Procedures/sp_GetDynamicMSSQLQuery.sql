CREATE PROC [ME_Data].[sp_GetDynamicMSSQLQuery] @DataSetType [VARCHAR](100),@ExecutionGroup [VARCHAR](10),@ExecutionPlane [VARCHAR](10) AS
BEGIN

DECLARE @PARTITION VARCHAR(50)
SET @PARTITION = (SELECT REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(16),GETUTCDATE(),120),'-','\'),' ','\'),':','\'))
SELECT	[DataSetType] 
		,DBServerName
		,DBName
		,SQLKVName
		,SqlUserName
       ,[DataSetName]
      ,[SchemaName]
      ,DLContainer
	  ,DLFolder=DLFolder+'\'+@PARTITION
	  ,DLFileName
		,SQLQuery=CONVERT(NVARCHAR(MAX),'SELECT '+Cols+' FROM ['+[SchemaName]+'].['+[Name]+']')
		,Cols
		,DataSetID=ID
		,[Target_Partition]=REPLACE(@PARTITION,'\','/')
		FROM
		(

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
	  
	  ,E.[Name]
	  ,D.ID
      --
	  ,Cols=CONVERT(NVARCHAR(MAX), (
									ISNULL(STRING_AGG('['+REPLACE(o.[MetadataObjectName],' ','_')+']=['+o.[MetadataObjectName]+']',',')	WITHIN GROUP ( ORDER BY o.[MetadataObjectOrder]  ASC  )
											,'*')
									)
							)
							--SELECT *
  FROM [Metadata].[Entity] E
  INNER JOIN [ME_Config].[DataSet] D on D.id=e.datasetid AND D.[IsEnabled]=1
  INNER JOIN  [ME_Config].[Connection] C ON   D.CONNECTIONID=C.ID
  INNER JOIN [Metadata].[Object] o ON o.EntityID=E.id


  GROUP BY 	d.[DataSetType], 
		C.[ConnectionString],
		C.[ConnectionName],
		C.[ConnectionKVSecret]
		,C.[ConnectionKVSecret]
       ,D.[DataSetName]
      ,D.[SchemaName]
      ,LOWER(E.TargetLake)
	  ,LOWER(E.LakeFolder)
	  ,LOWER(CONCAT(D.[SchemaName],'_',D.[DataSetName]))
	  ,E.[Name]
	  ,D.ID
	  ) AS X


END