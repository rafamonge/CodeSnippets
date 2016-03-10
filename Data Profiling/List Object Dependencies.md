#Lists all object dependencies.

Provides the list of all dependencies in a SQL Server Database.
```sql
 Select 
 SCHEMA_NAME(so.SCHEMA_ID) as referencing_schema_name, 
 so.name as referencing_object_name, 
 so.type_desc as referencing_object_type_desc, 
 referenced_schema_name, 
 referenced_entity_name as referenced_object_name, 
 so1.type_desc as referenced_object_type_desc 
FROM sys.sql_expression_dependencies sed 
INNER JOIN sys.objects so  
ON sed.referencing_id = so.[object_id] 
LEFT OUTER JOIN sys.objects so1  
ON sed.referenced_id = so1.[object_id]
``` 

