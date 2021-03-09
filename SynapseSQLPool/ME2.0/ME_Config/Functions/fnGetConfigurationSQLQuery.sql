CREATE FUNCTION [ME_Config].[fnGetConfigurationSQLQuery] (@ConnectionType [VARCHAR](50),@ConnectionId [bigint]) RETURNS VARCHAR(500)
AS
BEGIN
    -- Declare the return variable
	DECLARE @SQLQUERY VARCHAR(500)

/*Datatype Definition for Microsoft SQL Datatypes*/
IF @ConnectionType in ('MSSQL','MYSQL','AzMYSQL')
BEGIN
  SET @SQLQUERY = 'SELECT ''' + @ConnectionType + ''' AS DataSetType,  ' +
                          '''999''                    AS RunGroupCode, ' +
                          'TABLE_NAME                 AS DataSetName,  ' +
                          'TABLE_SCHEMA               AS SchemaName,   ' +
                          '''RAW''                    AS TargetLake,   ' +
                          '''' + cast(@ConnectionId as varchar) + '''  AS ConnectionId, ' +
                          '0                          AS IsEnabled ' +
                  ' FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = ''BASE TABLE'''
  IF @ConnectionType LIKE '%MYSQL'
    SET @SQLQUERY += ' AND TABLE_SCHEMA NOT IN (''mysql'',''performance_schema'',''sys'')'
END
ELSE IF @ConnectionType = 'ORACLE'
BEGIN
  SET @SQLQUERY = REPLACE(	'SELECT ¬' + @ConnectionType + '¬ AS DataSetType,  ' +
							'CAST(¬999¬ as int)			AS RunGroupCode, ' +
							'TABLE_NAME                 AS DataSetName,  ' +
							'OWNER                      AS SchemaName,   ' +
							'¬RAW¬						AS TargetLake,   ' +
							'CAST(¬' + cast(@ConnectionId as varchar) + '¬ as int)  AS ConnectionId, ' +
							'CAST(0 as int)				AS IsEnabled ' +
							' FROM ALL_TABLES WHERE TABLESPACE_NAME NOT IN (¬SYSTEM¬, ¬SYSAUX¬)'
						,'¬','''')
END							
ELSE
  SET @SQLQUERY = ''

-- Return the result of the function
RETURN @SQLQUERY
END