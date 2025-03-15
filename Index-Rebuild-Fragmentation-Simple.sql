/*
Ola Hallengren's Maintenance Solution is still my favorite

However, in this special case, Ola's script took forever to get initial metadata collection in a table before running Index rebuild

In this scenario, we have over 300 columns for each table and act as fact tables. Each table might contain over 500 mb - 10 GB+ data with NVARCHAR(max) or binanry type. Database is 46TB+ with over 10k tables.

Thus, I have to just hardcode the index rebuild script

*/
IF OBJECT_ID('DBAMonitor.IndexRebuildList') IS NULL
BEGIN
	CREATE TABLE DBAMonitor.IndexRebuildList (
		[DBName] NVARCHAR(128),
		[TableName] NVARCHAR(128),
		[IndexName] NVARCHAR(128),
		[IndexType] nvarchar(60),
		[page_count] bigint,
		[avg_fragmentation_in_percent] float
	)
END

TRUNCATE TABLE DBAMonitor.IndexRebuildList;

BEGIN
	INSERT INTO DBAMonitor.IndexRebuildList ([DBName],[TableName] , [IndexName], [IndexType],[page_count], [avg_fragmentation_in_percent]) 
	SELECT CAST(DB_NAME() as NVARCHAR(128)),
		OBJECT_NAME(ind.OBJECT_ID) AS TableName,
	    ind.name AS IndexName,
	    indexstats.index_type_desc AS IndexType,
	    indexstats.page_count,
	    indexstats.avg_fragmentation_in_percent
	FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats
	    INNER JOIN sys.indexes ind  
	        ON ind.object_id = indexstats.object_id
	        AND ind.index_id = indexstats.index_id
	WHERE indexstats.avg_fragmentation_in_percent > 30 AND
	    ind.name IS NOT NULL AND
	   -- (OBJECT_NAME(ind.OBJECT_ID) like 'xxxx%' OR OBJECT_NAME(ind.OBJECT_ID) like 'xxxx%') AND
	    (indexstats.page_count > 1000) AND
	    ((indexstats.index_type_desc = 'NONCLUSTERED INDEX') OR (indexstats.index_type_desc = 'CLUSTERED INDEX'))
	ORDER BY indexstats.page_count
END

--SELECT * FROM DBAMonitor.IndexRebuildList
---------------------------
IF OBJECT_ID('tempdb..#t1') IS NOT NULL
BEGIN
	drop table #t1
END

SELECT 'ALTER INDEX [' + [IndexName] + '] ON [' + [TableName] + '] ' + char(10) 
	+ ' REBUILD WITH (FILLFACTOR = 80, ONLINE = ON , DATA_COMPRESSION = ROW);' + char(10) + char(13) as [sqlcmd]
	INTO #t1
FROM DBAMonitor.IndexRebuildList

SET NOCOUNT ON;
DECLARE @sqlcmd NVARCHAR(4000)
PRINT '-------- Rebuild Index --------';

DECLARE vendor_cursor CURSOR FOR
	SELECT [sqlcmd]	FROM #t1
OPEN vendor_cursor

FETCH NEXT FROM vendor_cursor
INTO @sqlcmd

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC sp_executesql @stmt = @sqlcmd

    -- Get the next vendor.
    FETCH NEXT FROM vendor_cursor
    INTO @vendor_id, @vendor_name
END
CLOSE vendor_cursor;
DEALLOCATE vendor_cursor;