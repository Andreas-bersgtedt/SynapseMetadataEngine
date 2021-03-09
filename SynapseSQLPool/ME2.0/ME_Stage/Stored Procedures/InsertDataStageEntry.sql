CREATE PROC [ME_Stage].[InsertDataStageEntry] @Partition_String [VARCHAR](100),@DatasetID [INT],@Row_Count [BIGINT] AS 
BEGIN

INSERT INTO  ME_Stage.RawPartitionStage
			(
			DatasetID,	Partition_String,	Row_Count,	InsertTimestamp
			)
SELECT		@DatasetID,	@Partition_String,	@Row_Count,	GETUTCDATE()

END