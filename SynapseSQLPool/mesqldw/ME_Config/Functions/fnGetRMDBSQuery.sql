CREATE FUNCTION [ME_Config].[fnGetRMDBSQuery] (@DataSetID [VARCHAR](20),@DataSetName [VARCHAR](250),@SchemaName [VARCHAR](250),@DataSetType [VARCHAR](100)) RETURNS VARCHAR(4000)
AS
BEGIN
    -- Declare the return variable
    DECLARE @Query VARCHAR(4000)

    -- T-SQL statements to compute the return value
IF @DataSetType = 'MSSQL' SET @Query ='
SELECT	MetadataQuerySource=Convert(VARCHAR(50),¬Dynamic¬)
		,MetadataEntityName=Convert(VARCHAR(250),T.name)
		,MetadataSchemaName=Convert(VARCHAR(250),S.name)
		,MetadataObjectName=Convert(VARCHAR(250),C.name)
		,MetadataObjectType=Convert(VARCHAR(250),TY.name)
		,MetadataObjectlength=Convert(VARCHAR(20),C.max_length)
		,MetadataObjectPrecision=Convert(VARCHAR(20),C.precision)
		,MetadataObjectScale=Convert(VARCHAR(20),C.scale)
		,MetadataObjectCollation=Convert(VARCHAR(250),ISNULL(C.collation_name,¬¬))
		,DataSetID=Convert(VARCHAR(20),¬<DataSetID>¬)
		,MetadataObjectOrder=C.column_id
		,MetadataObjectIdentityFlag=Convert(VARCHAR(20),C.is_identity)
		,MetadataObjectRefreshUTCTimeStamp=GETUTCDATE()
				
FROM	sys.columns C
		INNER JOIN sys.tables T on C.object_id=T.object_id
		INNER JOIN sys.schemas S ON T.schema_id=S.schema_id
		INNER JOIN sys.types TY on C.system_type_id=TY.system_type_id  AND TY.system_type_id=TY.user_type_id
WHERE	T.Name = ¬<DataSetName>¬
		AND S.name = ¬<SchemaName>¬';
SET @Query=REPLACE(@Query,'¬','''')
SET @Query=REPLACE(@Query,'<DataSetID>',@DataSetID)
SET @Query=REPLACE(@Query,'<DataSetName>',@DataSetName)
SET @Query=REPLACE(@Query,'<SchemaName>',@SchemaName)

    -- Return the result of the function
    RETURN @Query
END