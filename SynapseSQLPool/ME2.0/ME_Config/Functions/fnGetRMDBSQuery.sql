CREATE FUNCTION [ME_Config].[fnGetRMDBSQuery] (@DataSetID [VARCHAR](20),@DataSetName [VARCHAR](250),@SchemaName [VARCHAR](250),@DataSetType [VARCHAR](100)) RETURNS VARCHAR(4000)
AS
BEGIN
    -- Declare the return variable
    DECLARE @Query VARCHAR(MAX)

    -- T-SQL statements to compute the return value
IF @DataSetType IN ('MSSQL','MYSQL','AzMYSQL') SET @Query ='
SELECT	¬Dynamic¬ AS MetadataQuerySource
		,TABLE_NAME AS MetadataEntityName
		,TABLE_SCHEMA AS MetadataSchemaName
		,COLUMN_NAME AS MetadataObjectName
		,DATA_TYPE AS MetadataObjectType
		,CHARACTER_MAXIMUM_LENGTH AS MetadataObjectlength
		,FLOOR(NUMERIC_PRECISION) AS MetadataObjectPrecision
		,FLOOR(NUMERIC_SCALE) AS MetadataObjectScale
		,COALESCE(COLLATION_NAME,¬¬) AS MetadataObjectCollation
		,¬<DataSetID>¬ AS DataSetID
		,FLOOR(ORDINAL_POSITION) AS MetadataObjectOrder
		,¬0¬ AS MetadataObjectIdentityFlag
		,'+CASE WHEN @DataSetType IN ('MYSQL','AzMYSQL') THEN 'utc_timestamp()' ELSE 'GETUTCDATE()' END +' AS MetadataObjectRefreshUTCTimeStamp
				
FROM	INFORMATION_SCHEMA.COLUMNS
WHERE	TABLE_NAME = ¬<DataSetName>¬
		AND TABLE_SCHEMA = ¬<SchemaName>¬';
    -- T-SQL statements to compute the return value
	-- do we want CHAR_LENGTH or DATA_LENGTH ???
IF @DataSetType IN ('ORACLE') SET @Query ='
SELECT	¬Dynamic¬               AS "MetadataQuerySource"
		,TABLE_NAME             AS "MetadataEntityName"
		,OWNER                  AS "MetadataSchemaName"
		,COLUMN_NAME            AS "MetadataObjectName"
		,DATA_TYPE              AS "MetadataObjectType"
		,CHAR_LENGTH            AS "MetadataObjectlength"
		,FLOOR(DATA_PRECISION)  AS "MetadataObjectPrecision"
		,FLOOR(DATA_SCALE)      AS "MetadataObjectScale"
		,COALESCE(COLLATION,¬¬) AS "MetadataObjectCollation"
		,¬<DataSetID>¬          AS "DataSetID"
		,FLOOR(COLUMN_ID)       AS "MetadataObjectOrder"
		,¬0¬                    AS "MetadataObjectIdentityFlag"
		,'+CASE WHEN @DataSetType IN ('ORACLE') THEN 'LOCALTIMESTAMP AT TIME ZONE ¬UTC¬' END +' AS "MetadataObjectRefreshUTCTimeStamp"
				
FROM	ALL_TAB_COLUMNS
WHERE	TABLE_NAME = ¬<DataSetName>¬
		AND OWNER = ¬<SchemaName>¬';
SET @Query=REPLACE(@Query,'¬','''')
SET @Query=REPLACE(@Query,'<DataSetID>',@DataSetID)
SET @Query=REPLACE(@Query,'<DataSetName>',@DataSetName)
SET @Query=REPLACE(@Query,'<SchemaName>',@SchemaName)

    -- Return the result of the function
    RETURN @Query

	
END