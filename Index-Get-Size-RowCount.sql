DECLARE @MinimumPageCount int
SET @MinimumPageCount = 500

SELECT  Databases.name AS [Database], 
        Indexes.name AS [Index],
        Objects.Name AS [Table],                    
        PhysicalStats.page_count as [PageCount],
        CONVERT(decimal(18,2), PhysicalStats.page_count * 8 / 1024.0) AS [Total_Index_Size(MB)],
        CONVERT(decimal(18,2), PhysicalStats.avg_fragmentation_in_percent) AS [Fragmentation(%)],
        ParititionStats.row_count AS [RowCount],
        CONVERT(decimal(18,2), (PhysicalStats.page_count * 8.0 * 1024) / ParititionStats.row_count) AS [IndexSize/Row(Bytes)]
FROM sys.dm_db_index_usage_stats UsageStats
    INNER JOIN sys.indexes Indexes
        ON Indexes.index_id = UsageStats.index_id
            AND Indexes.object_id = UsageStats.object_id
    INNER JOIN sys.objects Objects
        ON Objects.object_id = UsageStats.object_id
    INNER JOIN SYS.databases Databases
        ON Databases.database_id = UsageStats.database_id       
    INNER JOIN sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS PhysicalStats
        ON PhysicalStats.index_id = UsageStats.Index_id 
            and PhysicalStats.object_id = UsageStats.object_id
    INNER JOIN SYS.dm_db_partition_stats ParititionStats
        ON ParititionStats.index_id = UsageStats.index_id
            and ParititionStats.object_id = UsageStats.object_id        
WHERE UsageStats.user_scans = 0
    AND UsageStats.user_seeks = 0
    AND UsageStats.user_lookups = 0
    AND PhysicalStats.page_count > @MinimumPageCount    -- ignore indexes with less than 500 pages of memory
    AND Indexes.type_desc != 'CLUSTERED'                -- Exclude primary keys, which should not be removed    
ORDER BY [Page Count] DESC