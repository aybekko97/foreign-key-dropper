DECLARE @schema_name varchar(100) = '__schema_name__' 

DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.objects
WHERE type_desc = 'USER_TABLE' and schema_id = SCHEMA_ID(@schema_name)
ORDER BY name

DECLARE @name VARCHAR(50);
DECLARE @sql VARCHAR(300);

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @name  
WHILE @@FETCH_STATUS = 0  
BEGIN  
	DECLARE drop_cursor CURSOR FOR
	SELECT 'ALTER TABLE ' + SCHEMA_NAME(t.schema_id) + '.' + @name +
	' DROP CONSTRAINT [' + fk.NAME + '];'
	FROM sys.foreign_keys fk
	INNER JOIN sys.objects t on (t.object_id = fk.object_id)
	WHERE object_name(fk.parent_object_id) = @name and t.schema_id = SCHEMA_ID(@schema_name)
	
	OPEN drop_cursor  
	FETCH NEXT FROM drop_cursor INTO @sql
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		EXEC (@sql);
		FETCH NEXT FROM drop_cursor INTO @sql
	END

	CLOSE drop_cursor
	DEALLOCATE drop_cursor

	FETCH NEXT FROM db_cursor INTO @name  
END

CLOSE db_cursor
DEALLOCATE db_cursor
