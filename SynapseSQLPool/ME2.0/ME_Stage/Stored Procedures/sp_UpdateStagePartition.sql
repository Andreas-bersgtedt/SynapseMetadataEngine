CREATE PROC [ME_Stage].[sp_UpdateStagePartition] @Partitionid [int],@State [Int] AS
BEGIN

  UPDATE [ME_Stage].[RawPartitionStage]
  SET [Status]=@State

  WHERE id =@Partitionid


  END