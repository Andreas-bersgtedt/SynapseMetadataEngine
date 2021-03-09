CREATE VIEW [Metadata].[DeltaConfig]
AS SELECT C.Entityid
	,WhereCol = C.[Value]
	,WhereOperator = o.[value]
	,wherevalue = ISNULL(v.[value], CASE 
			WHEN DT.[Value] LIKE '%DATE%'
				THEN '1900-01-01'
			ELSE '0'
			END)
FROM [Metadata].[Attribute] C WITH (NOLOCK)
INNER JOIN [Metadata].[Attribute] O WITH (NOLOCK) ON C.Entityid = O.Entityid
INNER JOIN [Metadata].[Attribute] V WITH (NOLOCK) ON C.Entityid = V.Entityid
INNER JOIN [Metadata].[Attribute] DT WITH (NOLOCK) ON C.Entityid = DT.Entityid
WHERE C.[Key] = 'EntityDeltaColumn'
	AND O.[Key] = 'EntityDeltaOperator'
	AND V.[Key] = 'EntityDeltaValue'
	AND DT.[Key] = 'EntityDeltaValueType';