CREATE FUNCTION [ME_Config].[fnGetDatatypedeff] (@DataSetType [VARCHAR](50),@DataType [VARCHAR](500),@Size [VARCHAR](20),@Precision [VARCHAR](20),@SCALE [VARCHAR](20)) RETURNS VARCHAR(500)
AS
BEGIN
    -- Declare the return variable
	DECLARE @DATATYPEDEFF VARCHAR(500)

/*Datatype Definition for Microsoft SQL Datatypes*/
IF @DataSetType = 'MSSQL'
SET @DATATYPEDEFF =(
/*SELECT*/	CASE	WHEN	@DataType LIKE '%INT%' or
						@DataType LIKE 'bit' or
						--@DataType LIKE 'xml' or
						@DataType LIKE 'uniqueidentifier' or
						@DataType LIKE '%money%' or
						@DataType LIKE 'real' or
						(@DataType = 'float' and @Precision='53')

				THEN	@DataType
				WHEN	@DataType IN	(
										'DECIMAL'
										,'DEC'
										,'numeric'
										)
				THEN	@DataType + '('+@Precision+','+@SCALE+')'
				
				WHEN	@DataType LIKE '%var%' and @DataType != 'sql_variant'
				THEN	@DataType + '('+CASE WHEN @Size='-1' or @Size > '4000' Then 'MAX' ELSE @Size END + ')'

				WHEN	@DataType IN	(
										'datetime'
										,'date'
										,'smalldatetime'
										)
				THEN	@DataType 
				WHEN	@DataType IN	(
										'time'
										,'datetime2'
										,'datetimeoffset'
										)
				THEN	@DataType + '('+@SCALE+')'
				WHEN    @DataType LIKE 'xml'
				THEN	'VARCHAR(MAX)'
				ELSE	@DataType + '('+@Size+')'
		END
)

/*Datatype Definition for Oracle SQL Datatypes*/
IF @DataSetType = 'PLSQL'
SET @DATATYPEDEFF = @DataType + '('+@Size+')'

/*Datatype Definition for MySQL Datatypes*/
IF @DataSetType = 'MySQL'
SET @DATATYPEDEFF = @DataType + '('+@Size+')'

    -- Return the result of the function
    RETURN @DATATYPEDEFF
END