CREATE PROC [Metadata].[sp_manage_UniqueKey_Attribute] @EntityId [bigint],@RowIdColumn [VARCHAR](MAX),@ACTION [VARCHAR](10) AS
BEGIN
	/*
--DEBUG
DECLARE @EntityId bigint , @DeltaColumn VARCHAR(MAX), @RowIdColumn VARCHAR(MAX), @DeltaOperator VARCHAR(MAX), @DeltaSeedValue VARCHAR(MAX)


SET @EntityId = 477
SET  @RowIdColumn = 'rowguid'
--SET  @DeltaColumn = 'ModifiedDate'
--SET  @DeltaOperator = '>='
--DEBUG
*/
	/*DECLARE CONSTANTS*/
	DECLARE @RIDKEY VARCHAR(MAX) = 'EntityRowIdentifier'
	/*Declare Globals*/
	DECLARE @DataSetID BIGINT
		,@DeltaDataType VARCHAR(MAX)

	SET @DataSetID = (
			SELECT DataSetID
			FROM [Metadata].[Entity]
			WHERE id = @EntityId
			)

	/*Flush Previous Data*/
	IF @ACTION = 'D'
		DELETE
		FROM [Metadata].[Attribute]
		WHERE ID IN (
				SELECT v.id
				FROM [Metadata].[Attribute] v
				WHERE v.[Key] = @RIDKEY
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
			,[KEY] = @RIDKEY
			,[Value] = @RowIdColumn
			,[KeyValueDataType] = 'String'
			,[KeyValueRefreshDate] = getutcdate()
			,[RecordProcessTimestamp] = getutcdate()
			,[CreatedUTCTimestamp] = getutcdate()
		) AS XX

	SELECT v.*
	FROM [Metadata].[Attribute] v
	WHERE v.[Key] = @RIDKEY
		AND v.Entityid = @EntityId
END