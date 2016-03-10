#Lists all object dependencies.

List columns for datatabase and table

```sql
SELECT *
FROM DBC.Columns
WHERE 
DatabaseName='Demo'AND 
TableName='Temp1' AND
ColumnName =  'cmdt_cd'
order by DatabaseName, TableName
``` 





Extended inforomation version
```sql
SELECT DatabaseName, TableName, ColumnName
,CASE 
    WHEN COLUMNTYPE='CF' THEN 'CHAR'
    WHEN COLUMNTYPE='CV' THEN 'VARCHAR'
    WHEN COLUMNTYPE='D'  THEN 'DECIMAL' 
    WHEN COLUMNTYPE='TS' THEN 'TIMESTAMP'      
    WHEN COLUMNTYPE='I'  THEN 'INTEGER'
    WHEN COLUMNTYPE='I2' THEN 'SMALLINT'
    WHEN COLUMNTYPE='DA' THEN 'DATE' 
    ELSE COLUMNTYPE
  END AS ColumnType
 ,CASE 
    WHEN COLUMNTYPE='CF' THEN COLUMNLENGTH
    WHEN COLUMNTYPE='CV' THEN COLUMNLENGTH
    WHEN COLUMNTYPE='D'  THEN (DECIMALTOTALDIGITS||','||DECIMALFRACTIONALDIGITS)
    WHEN COLUMNTYPE='TS' THEN COLUMNLENGTH     
    WHEN COLUMNTYPE='I'  THEN DECIMALTOTALDIGITS
    WHEN COLUMNTYPE='I2' THEN DECIMALTOTALDIGITS
    WHEN COLUMNTYPE='DA' THEN NULL
  END AS ColumnNum
  , case when TableName like 'v_%' then 1 else 0 END as IsView
FROM DBC.Columns
WHERE 
DatabaseName='Demo'AND 
TableName='Temp1' AND
ColumnName like  '%epm%'
order by DatabaseName, TableName
``` 