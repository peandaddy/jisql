I recently received an interesting SQL question from a network connection.

How may duplicate rows be removed from a table without utilizing DISTINCT or Windows Functions like ROW_NUMBER()?

My quick response, without a test: Use Cursor

```sql
-- assume TABLE1 has duplicated records
SELECT c1, c2 into #temptable1 from table1 group by c1, c2 HAVING count(*) > 1;

-- create temp table 2 to hold unique record
    IF OBJECT_ID('tempdb..#temptable2') is not null
    BEGIN
        DROP TABLE #temptable2;
    END
    ELSE
    BEGIN
        CREATE TABLE #temptable2 (c1 int, c2 int);
    END

-- use Cursor
DECLARE @c11 int, @c22 int;
DECLARE cursor1 CURSOR FOR
    SELECT c1, c2 FROM #temptable1
OPEN cursor1;
FETCH NEXT FROM cursor INTO @c11, @c22;
WHILE @@FETCH_STATUS=0
BEGIN
    INSERT INTO #temptable2 (c1, c2)
    SELECT TOP 1 c1, c2 FROM table1
    WHERE c1 = @c11 and c2 = @c22
    
    FETCH NEXT FROM cursor INTO @c11, @c22;
END
CLOSE cursor1;
DEALLOCATE cursor1;

-- Clean up duplication
DELETE table1
FROM table1, #temptable2
WHERE table1.c1 = #temptable2.c1
AND table1.c2 = #temptable2.c2;

-- INSERT unique record back
INSERT INTO table1(c1, c2)
SELECT c1, c2 FROM #temptable2;
```

