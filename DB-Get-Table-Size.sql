SELECT TOP 1000 
			(
				row_number() OVER (ORDER BY (a1.reserved + ISNULL(a4.reserved, 0)) DESC)
			) % 2 AS l1
		,a3.name AS [schemaname]
		,a2.name AS [tablename]
		,a1.[rows] AS [row_count]
		, format(ROUND( (a1.reserved + ISNULL(a4.reserved, 0)) * 8.0 / 1024, 0), 'N0') AS [reserved_MB]
		--,(a1.reserved + ISNULL(a4.reserved, 0)) * 8 AS [reserved]
		, format(ROUND(a1.data * 8.0 / 1024, 0), 'N0') AS [data_MB]
		--,a1.data * 8 AS [data]
		-- format(ROUND( [replace here] * 8.0 / 1024, 0), 'N0')
		
		,format(ROUND( (
			CASE 
				WHEN (a1.used + ISNULL(a4.used, 0)) > a1.[data]
					THEN (a1.used + ISNULL(a4.used, 0)) - a1.[data]
				ELSE 0
				END
			) * 8.0 / 1024, 0), 'N0') AS [IndexSize_MB]
		, format(ROUND( (
			CASE 
				WHEN (a1.reserved + ISNULL(a4.reserved, 0)) > a1.used
					THEN (a1.reserved + ISNULL(a4.reserved, 0)) - a1.used
				ELSE 0
				END
			) * 8.0 / 1024, 0), 'N0') AS [unused_MB]
	FROM (
			  SELECT ps.object_id
			 	 ,SUM(CASE 
			 			 WHEN (ps.index_id < 2)
			 				 THEN row_count
			 			 ELSE 0
			 			 END) AS [rows]
			 	 ,SUM(ps.reserved_page_count) AS reserved
			 	 ,SUM(CASE 
			 			 WHEN (ps.index_id < 2)
			 				 THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
			 			 ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count)
			 			 END) AS data
			 	 ,SUM(ps.used_page_count) AS used
			  FROM sys.dm_db_partition_stats ps
			  GROUP BY ps.object_id
			  ) AS a1
	LEFT OUTER JOIN (
			  SELECT it.parent_id
			 	 ,SUM(ps.reserved_page_count) AS reserved
			 	 ,SUM(ps.used_page_count) AS used
			  FROM sys.dm_db_partition_stats ps
			  INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id)
			  WHERE it.internal_type IN (202,204)
			  GROUP BY it.parent_id
			 ) AS a4 ON (a4.parent_id = a1.object_id)
	INNER JOIN sys.all_objects a2 ON (a1.object_id = a2.object_id)
	INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
	WHERE a2.type <> N'S'
		AND a2.type <> N'IT'