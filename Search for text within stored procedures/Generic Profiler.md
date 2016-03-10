# Description

Searches for some text within MSSQL stored procedures
```sql

SELECT top 100 o.name AS Object_Name,o.type_desc, definition
FROM sys.sql_modules m 
INNER JOIN sys.objects o 
ON m.object_id=o.object_id
WHERE m.definition Like '%As%'
```

sp_helptext @objname = 'stored proc/view/etc. name here'