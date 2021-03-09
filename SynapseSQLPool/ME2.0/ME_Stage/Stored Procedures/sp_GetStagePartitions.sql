CREATE PROC [ME_Stage].[sp_GetStagePartitions] AS
BEGIN
SELECT [Id]
      ,[DatasetID]
      ,[Partition_String]
      ,[Row_Count]
      ,[InsertTimestamp]
      ,[Status]
  FROM [ME_Stage].[RawPartitionStage]

  WHERE STATUS=0
  ORDER BY [InsertTimestamp]

  END