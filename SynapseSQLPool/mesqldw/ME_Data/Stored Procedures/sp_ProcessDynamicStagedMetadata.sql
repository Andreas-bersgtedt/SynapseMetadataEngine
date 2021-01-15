CREATE PROC [ME_Data].[sp_ProcessDynamicStagedMetadata] @DataSetType [VARCHAR](100) AS
BEGIN
--Initial Reset... 
BEGIN TRY 
DROP TABLE #TTAttribute
DROP TABLE #TTBase
DROP TABLE #TTOBJECT
DROP TABLE #TTEntity
DROP TABLE #Attribute
DROP TABLE #OBJECT
DROP TABLE #Entity
END TRY
BEGIN CATCH
PRINT 'Seems as if the temp tables were not there :)'
END CATCH




--Lock In Reslults
SELECT [MetadataQuerySource]
      ,[MetadataEntityName]
      ,[MetadataSchemaName]
      ,[MetadataObjectName]
      ,[MetadataObjectType]
      ,[MetadataObjectlength]
      ,[MetadataObjectPrecision]
      ,[MetadataObjectScale]
      ,[MetadataObjectCollation]
      ,[DataSetID]
      ,[MetadataObjectOrder]
      ,[MetadataObjectIdentityFlag]
      ,[MetadataObjectRefreshUTCTimeStamp]

	  ,MetadataObjectHash=CONVERT(BIGINT,HASHBYTES('SHA1',CONCAT([DataSetID],'¬'
      ,[MetadataObjectName])))
	   
	INTO #TTBase
	--SELECT *
  FROM [ME_Data].[MetadataEntityStage]
  WHERE [MetadataQuerySource]='Dynamic' 
		AND DATASETID IN	(
							SELECT id 
							from [ME_Config].[DataSet] 
							where @DataSetType=DataSetType
							)

--Get All Distinct Entities
--DROP TABLE #TTEntity
SELECT DISTINCT [DataSetID],[MetadataEntityName]
      ,[MetadataSchemaName]
INTO #TTEntity
FROM #TTBase

--Build Up Objects
SELECT [DataSetID]
      ,[MetadataObjectName]
	  ,[MetadataObjectOrder]
	  ,MetadataObjectHash
	  ,[MetadataObjectRefreshUTCTimeStamp]=MAX([MetadataObjectRefreshUTCTimeStamp])
INTO #TTOBJECT
FROM #TTBase
GROUP BY [DataSetID]
      ,[MetadataObjectName]
	  ,MetadataObjectHash
	  ,[MetadataObjectOrder]


--Build Attribute KVP Table
SELECT *
INTO #TTAttribute
FROM (
SELECT	 MetadataObjectHash
		,[DataSetID]
		,[KEY]=CONVERT(VARCHAR(100),'ObjectDataType')
		,[Value]=CONVERT(NVARCHAR(4000),[MetadataObjectType])
		,[KeyValueDataType]=CONVERT(VARCHAR(50),'String')
		,[KeyValueRefreshDate]=[MetadataObjectRefreshUTCTimeStamp]
FROM #TTBase
UNION ALL
SELECT	 MetadataObjectHash
		,[DataSetID]
		,[KEY]=CONVERT(VARCHAR(100),'ObjectDataTypeSize')
		,[Value]=CONVERT(NVARCHAR(4000),MetadataObjectlength)
		,[KeyValueDataType]='Int'
		,[KeyValueRefreshDate]=[MetadataObjectRefreshUTCTimeStamp]
FROM #TTBase
UNION ALL
SELECT	 MetadataObjectHash
		,[DataSetID]
		,[KEY]=CONVERT(VARCHAR(100),'ObjectDataTypePrecision')
		,[Value]=CONVERT(NVARCHAR(4000),MetadataObjectPrecision)
		,[KeyValueDataType]='Int'
		,[KeyValueRefreshDate]=[MetadataObjectRefreshUTCTimeStamp]
FROM #TTBase
UNION ALL
SELECT	 MetadataObjectHash
		,[DataSetID]
		,[KEY]=CONVERT(VARCHAR(100),'ObjectDataTypeScale')
		,[Value]=CONVERT(NVARCHAR(4000),MetadataObjectScale)
		,[KeyValueDataType]='Int'
		,[KeyValueRefreshDate]=[MetadataObjectRefreshUTCTimeStamp]
FROM #TTBase
UNION ALL
SELECT	 MetadataObjectHash
		,[DataSetID]
		,[KEY]=CONVERT(VARCHAR(100),'ObjectDataTypeCollation')
		,[Value]=CONVERT(NVARCHAR(4000),MetadataObjectCollation)
		,[KeyValueDataType]='String'
		,[KeyValueRefreshDate]=[MetadataObjectRefreshUTCTimeStamp]
FROM #TTBase
WHERE ISNULL(MetadataObjectCollation,'') !=''
UNION ALL
SELECT	 MetadataObjectHash
		,[DataSetID]
		,[KEY]=CONVERT(VARCHAR(100),'ObjectIdentityFlag')
		,[Value]=CONVERT(NVARCHAR(4000),MetadataObjectIdentityFlag)
		,[KeyValueDataType]='Int'
		,[KeyValueRefreshDate]=[MetadataObjectRefreshUTCTimeStamp]
FROM #TTBase
) X



SELECT E.*,D.TargetLake,LakeFolder=CONCAT(D.id
								,'\'
								,D.DataSetType
								,'\'
								,E.[MetadataSchemaName]
								,'\'
								,E.[MetadataEntityName]) 
		,RecordProcessTimestamp=GETUTCDATE()
INTO #Entity
FROM #TTEntity E
INNER JOIN [ME_Config].[DataSet] D ON D.id=E.DataSetID

SELECT * ,RecordProcessTimestamp=GETUTCDATE()
INTO #Object
FROM #TTOBJECT

SELECT * ,RecordProcessTimestamp=GETUTCDATE()
INTO #Attribute
FROM #TTAttribute


--Update Metadata.Entity table
UPDATE t
SET 
       t.[Name]=s.[MetadataEntityName]
      ,t.[SchemaName]=s.[MetadataSchemaName]
      ,t.[TargetLake]=s.[TargetLake]
      ,t.[LakeFolder]=s.[LakeFolder]
      ,t.[RecordProcessTimestamp]=s.[RecordProcessTimestamp]
FROM [Metadata].[Entity] t 
INNER JOIN  #Entity s ON s.[DataSetId] = t.[DataSetId]


	INSERT INTO [Metadata].[Entity] ([DataSetId]
      ,[Name]
      ,[SchemaName]
      ,[TargetLake]
      ,[LakeFolder]
      ,[RecordProcessTimestamp]
	  ,CreatedUTCTimestamp)
	  SELECT DISTINCT s.[DataSetId]
      ,s.[MetadataEntityName]
      ,s.[MetadataSchemaName]
      ,s.[TargetLake]
      ,s.[LakeFolder]
      ,s.[RecordProcessTimestamp]
	  ,CreatedUTCTimestamp=GETUTCDATE()
	  FROM #Entity s 
	  LEFT OUTER JOIN  [Metadata].[Entity] t
	  ON s.[DataSetId] = t.[DataSetId]
	  WHERE t.[DataSetId] IS NULL
	;
	  /*
MERGE [Metadata].[Entity] t 
    USING #Entity s
ON (s.[DataSetId] = t.[DataSetId])
WHEN MATCHED
    THEN UPDATE SET 
       t.[Name]=s.[MetadataEntityName]
      ,t.[SchemaName]=s.[MetadataSchemaName]
      ,t.[TargetLake]=s.[TargetLake]
      ,t.[LakeFolder]=s.[LakeFolder]
      ,t.[RecordProcessTimestamp]=s.[RecordProcessTimestamp]



            
WHEN NOT MATCHED --BY TARGET 
    THEN INSERT ([DataSetId]
      ,[Name]
      ,[SchemaName]
      ,[TargetLake]
      ,[LakeFolder]
      ,[RecordProcessTimestamp])
         VALUES (s.[DataSetId]
      ,s.[MetadataEntityName]
      ,s.[MetadataSchemaName]
      ,s.[TargetLake]
      ,s.[LakeFolder]
      ,s.[RecordProcessTimestamp])
	  */
	;

	

--Update Metadata Object Table 

UPDATE t
SET 
        t.[MetadataObjectOrder]		=s.[MetadataObjectOrder]
       ,t.[RecordProcessTimestamp]	=s.[RecordProcessTimestamp]
FROM [Metadata].[Object] t 
INNER JOIN  (
			SELECT o.*, [EntityId]=E.id 
			FROM #Object o 
			INNER JOIN [Metadata].[Entity] E 
			ON E.[DataSetId]=o.[DataSetId]
			) s ON s.[MetadataObjectHash] = t.[MetadataObjectHash];

INSERT INTO [Metadata].[Object]([EntityId]
				,[DataSetID]
				,[MetadataObjectName]
				,[MetadataObjectOrder]
				,[MetadataObjectHash]
				,[MetadataObjectRefreshUTCTimeStamp]
				,[RecordProcessTimestamp]
				,CreatedUTCTimestamp
				)
         SELECT s.[EntityId]
				,s.[DataSetID]
				,s.[MetadataObjectName]
				,s.[MetadataObjectOrder]
				,s.[MetadataObjectHash]
				,s.[MetadataObjectRefreshUTCTimeStamp]
				,s.[RecordProcessTimestamp]
				,CreatedUTCTimestamp=GETUTCDATE()
	FROM   (
			SELECT o.*, [EntityId]=E.id 
			FROM #Object o 
			INNER JOIN [Metadata].[Entity] E 
			ON E.[DataSetId]=o.[DataSetId]
			) s 
	WHERE s.[MetadataObjectHash] NOT IN (SELECT [MetadataObjectHash] FROM [Metadata].[Object] WITH (NOLOCK))
	


/*
MERGE [Metadata].[Object] t 
    USING	(
			SELECT o.*, [EntityId]=E.id 
			FROM #Object o 
			INNER JOIN [Metadata].[Entity] E 
			ON E.[DataSetId]=o.[DataSetId]
			) s
ON (s.[MetadataObjectHash] = t.[MetadataObjectHash])
WHEN MATCHED
    THEN UPDATE SET 
       t.[MetadataObjectOrder]		=s.[MetadataObjectOrder]
       ,t.[RecordProcessTimestamp]	=s.[RecordProcessTimestamp]
            
WHEN NOT MATCHED BY TARGET 
    THEN INSERT ([EntityId]
				,[DataSetID]
				,[MetadataObjectName]
				,[MetadataObjectOrder]
				,[MetadataObjectHash]
				,[MetadataObjectRefreshUTCTimeStamp]
				,[RecordProcessTimestamp]
				)
         VALUES (s.[EntityId]
				,s.[DataSetID]
				,s.[MetadataObjectName]
				,s.[MetadataObjectOrder]
				,s.[MetadataObjectHash]
				,s.[MetadataObjectRefreshUTCTimeStamp]
				,s.[RecordProcessTimestamp])
	;

	*/

--Update Metadata Attribute Table 

UPDATE t
SET 
        t.[Value]=s.[Value]
       ,t.[KeyValueRefreshDate]=s.[KeyValueRefreshDate]
       ,t.[RecordProcessTimestamp]	=s.[RecordProcessTimestamp]
FROM [Metadata].[Attribute] t 
INNER JOIN  (
			SELECT o.*, [EntityId]=E.[EntityId] ,[ObjectId]=E.[Id] 
			FROM #Attribute o 
			INNER JOIN [Metadata].[Object] E 
			ON E.[MetadataObjectHash]=o.[MetadataObjectHash]
			) s ON (s.[MetadataObjectHash] = t.[MetadataObjectHash] and S.[Key]=T.[Key]);


INSERT INTO [Metadata].[Attribute] ([EntityId]
				,[ObjectId]
				,[MetadataObjectHash]
				,[DataSetID]
				,[KEY]
				,[Value]
				,[KeyValueDataType]
				,[KeyValueRefreshDate]
				,[RecordProcessTimestamp]
				,CreatedUTCTimestamp
				)
			SELECT s.[EntityId]
				,s.[ObjectId]
				,s.[MetadataObjectHash]
				,s.[DataSetID]
				,s.[KEY]
				,s.[Value]
				,s.[KeyValueDataType]
				,s.[KeyValueRefreshDate]
				,s.[RecordProcessTimestamp]
				,CreatedUTCTimestamp=GETUTCDATE()
			FROM 
			(
				SELECT o.*, [EntityId]=E.[EntityId] ,[ObjectId]=E.[Id] 
				FROM #Attribute o 
				INNER JOIN [Metadata].[Object] E 
				ON E.[MetadataObjectHash]=o.[MetadataObjectHash]
			) s 
			LEFT OUTER JOIN [Metadata].[Attribute]  t ON s.[MetadataObjectHash] = t.[MetadataObjectHash] and S.[Key]=T.[Key] 
			WHERE t.[MetadataObjectHash] IS NULL;
/*
MERGE [Metadata].[Attribute] t 
    USING	(
			SELECT o.*, [EntityId]=E.[EntityId] ,[ObjectId]=E.[Id] 
			FROM #Attribute o 
			INNER JOIN [Metadata].[Object] E 
			ON E.[MetadataObjectHash]=o.[MetadataObjectHash]
			) s
ON (s.[MetadataObjectHash] = t.[MetadataObjectHash] and S.[Key]=T.[Key])
WHEN MATCHED
    THEN UPDATE SET 
		t.[Value]=s.[Value]
       ,t.[KeyValueRefreshDate]=s.[KeyValueRefreshDate]
       ,t.[RecordProcessTimestamp]	=s.[RecordProcessTimestamp]
            
WHEN NOT MATCHED BY TARGET 
    THEN INSERT ([EntityId]
				,[ObjectId]
				,[MetadataObjectHash]
				,[DataSetID]
				,[KEY]
				,[Value]
				,[KeyValueDataType]
				,[KeyValueRefreshDate]
				,[RecordProcessTimestamp]
				)
         VALUES (s.[EntityId]
				,s.[ObjectId]
				,s.[MetadataObjectHash]
				,s.[DataSetID]
				,s.[KEY]
				,s.[Value]
				,s.[KeyValueDataType]
				,s.[KeyValueRefreshDate]
				,s.[RecordProcessTimestamp])
	;
	*/
--Purge stage table of data
DELETE  FROM [ME_Data].[MetadataEntityStage]
WHERE CONVERT(BIGINT,HASHBYTES('SHA1',CONCAT([DataSetID],'¬'
      ,[MetadataObjectName]))) IN (SELECT DISTINCT MetadataObjectHash FROM #TTBase)
--Cleanup
DROP TABLE #TTAttribute
DROP TABLE #TTBase
DROP TABLE #TTOBJECT
DROP TABLE #TTEntity
DROP TABLE #Attribute
DROP TABLE #OBJECT
DROP TABLE #Entity

END