CREATE PROC [ME_Config].[sp_LoadPrimeMetadata] AS
BEGIN
	/*DEBUG
		SET @PARTITIONSTRING='2021/01/07/15/23'
		SET @DatasetID=25
*/
	/*DECLARE GLOBALS*/
	DECLARE @STORAGE_ACCOUNT VARCHAR(500)
	
	
	/*SET GLOBAL PARAMETERS*/
	SET @STORAGE_ACCOUNT =(SELECT TOP 1 AttributeValue	FROM ME_Config.GLOBALS WHERE [Attribute]='STORAGE_ACCOUNT')

	/*DECLARE LOCAL PARAMETERS*/
	DECLARE @SQLCOPYINTO VARCHAR(MAX);
	DECLARE @SourceConnnectionName VARCHAR(250)
	

	/*Get Source Database / Connection Name for use in target table name*/
	SET @SourceConnnectionName = ('https://'+@STORAGE_ACCOUNT+'.dfs.core.windows.net/metadata/me_config_dataset/*.parquet')
	


	/*Ensure Stage schema exists as defined in MF_Config.Globals*/
	
	/*Build out main metadata for dynamic SQL*/

/*Build out Copy Into Statement*/
	SET @SQLCOPYINTO = (REPLACE('COPY INTO dbo.tbdxxxxx
(DATASETTYPE 1, RUNGROUPCODE 2, DATASETNAME 3, SCHEMANAME 4, TARGETLAKE 5, CONNECTIONID 6, ISENABLED 7)
  
  FROM  ¬'+@SourceConnnectionName+ '¬
  WITH
(
	FILE_TYPE = ¬PARQUET¬
	,MAXERRORS = 0
	,IDENTITY_INSERT = ¬OFF¬
)

  ', '¬', '''')
		
			)
	
	/*Build Out Drop and Recreate of StageTable*/
	PRINT @SQLCOPYINTO



IF NOT EXISTS (SELECT * FROM sys.objects WHERE NAME = 'tbdxxxxx' AND TYPE = 'U')
CREATE TABLE dbo.tbdxxxxx
	(
	 [DATASETTYPE] nvarchar(300),
	 [RUNGROUPCODE] nvarchar(300),
	 [DATASETNAME] nvarchar(300),
	 [SCHEMANAME] nvarchar(300),
	 [TARGETLAKE] nvarchar(300),
	 [CONNECTIONID] nvarchar(300),
	 [ISENABLED] INT
	)
WITH
	(
	DISTRIBUTION = ROUND_ROBIN,
	 HEAP
	);





	EXEC (@SQLCOPYINTO)

	INSERT INTO [ME_Config].[DataSet]([DataSetType]
      ,[RunGroupCode]
      ,[DataSetName]
      ,[SchemaName]
      ,[TargetLake]
      ,[ConnectionId]
      ,[IsEnabled])
		SELECT * FROM dbo.tbdxxxxx;
DROP TABLE dbo.tbdxxxxx


	
END