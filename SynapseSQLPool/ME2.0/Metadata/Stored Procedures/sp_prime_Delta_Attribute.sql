CREATE PROC [Metadata].[sp_prime_Delta_Attribute] @EntityId [bigint],@DeltaColumn [VARCHAR](MAX),@DeltaOperator [VARCHAR](MAX),@DeltaSeedValue [VARCHAR](MAX) AS
BEGIN
	/*
--DEBUG
DECLARE @EntityId bigint , @DeltaColumn VARCHAR(MAX), @RowIdColumn VARCHAR(MAX), @DeltaOperator VARCHAR(MAX), @DeltaSeedValue VARCHAR(MAX)


SET @EntityId = 477
SET  @RowIdColumn = 'rowguid'
SET  @DeltaColumn = 'ModifiedDate'
SET  @DeltaOperator = '>='
--DEBUG
*/
	/*DECLARE CONSTANTS*/
	--DECLARE @RIDKEY VARCHAR(MAX) = 'EntityRowIdentifier'
	DECLARE @DeltaColumnKEY VARCHAR(MAX) = 'EntityDeltaColumn'
	DECLARE @DeltaOperatorKEY VARCHAR(MAX) = 'EntityDeltaOperator'
	DECLARE @DeltaValueKEY VARCHAR(MAX) = 'EntityDeltaValue'
	DECLARE @DeltaValueTypeKEY VARCHAR(MAX) = 'EntityDeltaValueType'
	/*DECLARE GLOBALS*/
	DECLARE @DataSetID BIGINT
		,@DeltaDataType VARCHAR(MAX)

	SET @DataSetID = (
			SELECT DataSetID
			FROM [Metadata].[Entity]
			WHERE id = @EntityId
			)
	/*GET Metadata*/
	SET @DeltaDataType = (
			SELECT v.[Value]
			FROM [Metadata].[Attribute] v
			INNER JOIN [Metadata].[Object] o ON o.id = v.Objectid
				AND o.[MetadataObjectName] = @DeltaColumn
				AND v.[Key] = 'ObjectDataType'
				AND v.Entityid = @EntityId
			)

	DELETE
	FROM [Metadata].[Attribute]
	WHERE ID IN (
			SELECT v.id
			FROM [Metadata].[Attribute] v
			WHERE v.[Key] IN (
					@DeltaColumnKEY
					,@DeltaOperatorKEY
					,@DeltaValueKEY
					,@DeltaValueTypeKEY
					)
				AND v.Entityid = @EntityId
			)

	INSERT INTO [Metadata].[Attribute] (
		[EntityId]
		,[ObjectId]
		,[MetadataObjectHash]
		,[DataSetID]
		,[KEY]
		,[Value]
		,[KeyValueDataType]
		,[KeyValueRefreshDate]
		,[RecordProcessTimestamp]
		,[CreatedUTCTimestamp]
		)
	SELECT *
	FROM (
		SELECT [EntityId] = @EntityId
			,[ObjectId] = NULL
			,[MetadataObjectHash] = NULL
			,[DataSetID] = @DataSetID
			,[KEY] = @DeltaColumnKEY
			,[Value] = @DeltaColumn
			,[KeyValueDataType] = 'String'
			,[KeyValueRefreshDate] = getutcdate()
			,[RecordProcessTimestamp] = getutcdate()
			,[CreatedUTCTimestamp] = getutcdate()
		
		UNION ALL
		
		SELECT [EntityId] = @EntityId
			,[ObjectId] = NULL
			,[MetadataObjectHash] = NULL
			,[DataSetID] = @DataSetID
			,[KEY] = @DeltaOperatorKEY
			,[Value] = @DeltaOperator
			,[KeyValueDataType] = 'String'
			,[KeyValueRefreshDate] = getutcdate()
			,[RecordProcessTimestamp] = getutcdate()
			,[CreatedUTCTimestamp] = getutcdate()
		
		UNION ALL
		
		SELECT [EntityId] = @EntityId
			,[ObjectId] = NULL
			,[MetadataObjectHash] = NULL
			,[DataSetID] = @DataSetID
			,[KEY] = @DeltaValueKEY
			,[Value] = @DeltaSeedValue
			,[KeyValueDataType] = 'String'
			,[KeyValueRefreshDate] = getutcdate()
			,[RecordProcessTimestamp] = getutcdate()
			,[CreatedUTCTimestamp] = getutcdate()
		
		UNION ALL
		
		SELECT [EntityId] = @EntityId
			,[ObjectId] = NULL
			,[MetadataObjectHash] = NULL
			,[DataSetID] = @DataSetID
			,[KEY] = @DeltaValueTypeKEY
			,[Value] = @DeltaDataType
			,[KeyValueDataType] = 'String'
			,[KeyValueRefreshDate] = getutcdate()
			,[RecordProcessTimestamp] = getutcdate()
			,[CreatedUTCTimestamp] = getutcdate()
		) AS XX

	SELECT v.*
	FROM [Metadata].[Attribute] v
	WHERE v.[Key] IN (
			@DeltaColumnKEY
			,@DeltaOperatorKEY
			,@DeltaValueKEY
			,@DeltaValueTypeKEY
			)
		AND v.Entityid = @EntityId
END