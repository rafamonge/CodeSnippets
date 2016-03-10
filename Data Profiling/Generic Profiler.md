# Generic profiler 

Creates 4 tables with information regarding the tables in the database

```sql
CREATE TABLE [dbo].[Data_Profile_ColumnStatistics](
	[Database_Name] [varchar](100) NULL,
	[Table_Name] [varchar](200) NULL,
	[Column_Name] [varchar](200) NULL,
	[Row_Count] [int] NULL,
	[Min_Value] [varchar](50) NULL,
	[Max_Value] [varchar](50) NULL,
	[Mean] [varchar](50) NULL,
	[StdDev] [varchar](50) NULL,
	[JobId] [int] NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[Data_Profile_LengthDistribution](
	[Database_Name] [varchar](100) NULL,
	[Table_Name] [varchar](200) NULL,
	[Column_Name] [varchar](200) NULL,
	[Row_Count] [int] NULL,
	[Min_Length] [int] NULL,
	[Max_Length] [int] NULL,
	[Length] [int] NULL,
	[Count] [int] NULL,
	[JobId] [int] NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[Data_Profile_NULL_Counts](
	[Database_Name] [varchar](100) NULL,
	[Table_Name] [varchar](200) NULL,
	[Column_Name] [varchar](200) NULL,
	[SqlDbType] [varchar](100) NULL,
	[Max_Length] [int] NULL,
	[Precision] [int] NULL,
	[Scale] [int] NULL,
	[IsNullable] [varchar](100) NULL,
	[Row_Count] [int] NULL,
	[Null_Count] [int] NULL,
	[JobId] [int] NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[Data_Profile_ValueDistribution](
	[Database_Name] [varchar](100) NULL,
	[Table_Name] [varchar](200) NULL,
	[Column_Name] [varchar](200) NULL,
	[Row_Count] [int] NULL,
	[NumberOfDistinctValues] [int] NULL,
	[Value] [varchar](max) NULL,
	[Count] [int] NULL,
	[JobId] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

go 
Create Procedure [dbo].[Data_Profiling](@dbname varchar(50)) as
 begin
--declare @dbname varchar(50)='tm_toe2'
--declare @dbname varchar(50)='DBName
Declare @dataprofiling TABLE
(
      
    [ColumnName] [nvarchar](128) NULL,
       [SchemaName] [nvarchar](128) NULL,
       [TableName] [nvarchar](128) NULL,
       [ObjectType] [nvarchar](60) NULL,
       [DataType] [nvarchar](128) NULL,
       [max_length] [smallint] NULL,
       [is_nullable] [bit] NULL,
       [column_id] [int] NULL,
       [column_id_1] [int] NULL,
       [object_id] [int] NULL,
       [definition] [ntext] NULL,
       precision int null,
       scale int null,
       seed_value int,
       increment_value int,
       last_value int,
       scdefination nvarchar(max),
       ccdefination nvarchar(max)
)
declare @sql nvarchar(max);

    set @sql=
    'select
  rtrim(ltrim(s.name)) as ColumnName,
    sh.name as SchemaName,
    o.name as TableName,
    o.type_desc AS ObjectType,
    t.name as DataType,
    s.max_length,
    s.is_nullable,
    ic.column_id,
    sc.column_id as column_id_1,
    cc.object_id,
    cc.definition,
    cast(S.precision as int) as precision,
    cast(s.scale as int) as scale,
   cast(ic.seed_value as int) as seed_value,
   cast(increment_value as int) as increment_value,
  cast(last_value as int) as last_value,
  sc.definition as scdefination,
 cc.definition as ccdefination
     from ' 
    +@dbname+'.sys.tables  tx  join
    ' +@dbname+'.sys.columns                           s on tx.object_id=s.object_id
        INNER JOIN ' 
    +@dbname+'.sys.types                   t ON s.system_type_id=t.user_type_id and t.is_user_defined=0
        INNER JOIN ' 
    +@dbname+'.sys.objects                 o ON s.object_id=o.object_id
        INNER JOIN ' 
    +@dbname+'.sys.schemas                sh on o.schema_id=sh.schema_id
        LEFT OUTER JOIN ' 
    +@dbname+'.sys.identity_columns  ic ON s.object_id=ic.object_id AND s.column_id=ic.column_id
        LEFT OUTER JOIN ' 
    +@dbname+'.sys.computed_columns  sc ON s.object_id=sc.object_id AND s.column_id=sc.column_id
        LEFT OUTER JOIN ' 
    +@dbname+'.sys.check_constraints cc ON s.object_id=cc.parent_object_id AND s.column_id=cc.parent_column_id where s.name not like ''%-%'' and s.name not like ''%[%'' and s.name not like '' '''; 
       
 insert into @dataprofiling
      
       exec(@sql)


     declare @BIP_sourcetable table(
       [ColumnName] [nvarchar](128) NULL,
       [ObjectName] [nvarchar](257) NULL,
       [ObjectType] [nvarchar](60) NULL,
       [DataType] [nvarchar](151) NULL,
       [Nullable] [varchar](8) NULL,
       [MiscInfo] [ntext] NULL,
       [DatabaseName] [nvarchar](100) NULL,
       length int,
       precision int null,
       scale int null,
       [is_nullable] [bit] NULL
       )
          
       insert into @BIP_sourcetable
       (
       [ColumnName]
      ,[ObjectName]
      ,[ObjectType]
      ,[DataType]
      ,[Nullable]
      ,[MiscInfo]
      ,DatabaseName
      ,length
      ,precision ,
          scale,
          [is_nullable]
     )
      
        select 

      '['+rtrim(ltrim(ColumnName))+']'
       
         ,SchemaName+'.'+'['+TableName+']' AS ObjectName
        ,ObjectType
        ,CASE
             WHEN [DataType] IN ('char','varchar') THEN [DataType]+'('+CASE WHEN max_length<0 then 'MAX' ELSE CONVERT(varchar(10),max_length) END+')'
             WHEN [DataType] IN ('nvarchar','nchar') THEN [DataType]+'('+CASE WHEN max_length<0 then 'MAX' ELSE CONVERT(varchar(10),max_length/2) END+')'
             WHEN [DataType] IN ('numeric') THEN [DataType]+'('+CONVERT(varchar(10),precision)+','+CONVERT(varchar(10),scale)+')'
             ELSE [DataType]
         END AS DataType

        ,CASE
             WHEN is_nullable=1 THEN 'NULL'
            ELSE 'NOT NULL'
        END AS Nullable
        ,CASE
             WHEN column_id IS NULL THEN ''
             ELSE ' identity('+ISNULL(CONVERT(varchar(10),seed_value),'')+','+ISNULL(CONVERT(varchar(10),increment_value),'')+')='+ISNULL(CONVERT(varchar(10),last_value),'null')
         END
        +CASE
             WHEN column_id_1 IS NULL THEN ''
             ELSE ' computed('+ISNULL(scdefination,'')+')'
         END
        +CASE
             WHEN object_id IS NULL THEN''
             ELSE ' check('+ISNULL(ccdefination,'')+')'
         END
            AS MiscInfo,
            @dbname,
             max_length,
             precision ,
                scale,
                [is_nullable]
            from @dataprofiling

       
declare @temptable table
  (
  id int identity(1,1),
  [ColumnName] nvarchar(200),
  [ObjectName] nvarchar(200),
  DatabaseName nvarchar(100),
  DataType varchar(50),
   length int,
   precision int null,
       scale int null,
       [is_nullable] bit

 
  )

declare @temptable1 table
  (
  id int identity(1,1),
  [ColumnName] nvarchar(200),
  [ObjectName] nvarchar(200),
  DatabaseName nvarchar(100),
  DataType varchar(50) ,
   length int ,
   precision int null,
       scale int null,
       [is_nullable] bit
 
  )             

  declare @ColumnObjectName table
  (
  id int identity(1,1),
  ColumnName nvarchar(50) null,
  ObjectName nvarchar(50) null,
  DataType varchar(50),
  DBName varchar(50),
   length int,
    precision int null,
       scale int null,
       [is_nullable] bit
  )

   declare @ColumnObjectName1 table
  (
  id int identity(1,1),
  [ColumnName] nvarchar(50) null,
  [ObjectName] nvarchar(50) null,
  DataType varchar(50),
  DBName varchar(50),
   length int,
    precision int null,
       scale int null,
       [is_nullable] bit
  )
 
  declare @minMax table
  (
  id int identity(1,1),
  Minvalue float,
  MaxValue float,
  AvgValue Float,
  STDEVValue float,
  DistinctCount int,
  Count int,
  ColumnName nvarchar(50) null,
  ObjectName nvarchar(50) null,
  P float null,
  NullCount int,
  minLen nvarchar(50) null,
  Maxlen nvarchar(50) null

  )
 
  declare @Count_Distinct table
  (
  id int identity(1,1),
  Minvalue float,
  MaxValue float,
  AvgValue Float,
  STDEVValue float,
  DistinctCount int,
  Count int,
  ColumnName nvarchar(50) null,
  ObjectName nvarchar(50) null,
   P float null,
   NullCount int,
    minLen nvarchar(50) null,
  Maxlen nvarchar(50) null

  )
 
  insert into @temptable([ColumnName],[ObjectName],DatabaseName,DataType,length,precision,scale,[is_nullable])
  select [ColumnName],[ObjectName],DatabaseName,DataType,length,precision,scale,[is_nullable] from @BIP_sourcetable where   DataType
 in ('int','float','decimal','tinyint','smallint')

insert into @temptable1([ColumnName],[ObjectName],DatabaseName,DataType,length,precision,scale,[is_nullable])
  select [ColumnName],[ObjectName],DatabaseName,DataType,length,precision,scale,[is_nullable] from @BIP_sourcetable where   DataType
 not in ('int','float','decimal','tinyint','smallint','xml','Image','ntext')


 declare @dbname1 varchar(50)=@dbname
  declare @max int =(select MAX(id) from @temptable)
 
  declare @i int =1
 
   while @i<=@max
  begin
  declare @ColumnName varchar(50)=(select  [ColumnName] from @temptable where id=@i)
  declare @ObjectName varchar(50)=(select  [ObjectName] from @temptable where id=@i) 
  Declare @DataType varchar(50)=(select DataType from @temptable where id=@i)
  declare @length int =(select  length from @temptable where id=@i)
  declare @precision int =(select precision from @temptable where id=@i)
  declare @scale int =(select scale from @temptable where id=@i)
  declare @is_nullable bit =(select [is_nullable] from @temptable where id=@i)
  declare @sql1 nvarchar(max)
  set @sql1=('select  min('+@ColumnName+'),max('+@ColumnName+'),avg(cast('+@ColumnName+' as bigint)) ,STDEV('+@ColumnName+'),Count(distinct '+@ColumnName+' ) as DistinctCount ,
  Count(*) as Count,'''+@columnName+''','''+@ObjectName+''',(100.0 * SUM(CASE WHEN '+@ColumnName+' IS NULL THEN 1 ELSE 0 END) / COUNT(*)) as p,
  SUM(CASE WHEN '+@ColumnName+' IS NULL THEN 1 ELSE 0 END) as NullCount,Min(len('+@ColumnName+')),Max(len('+@ColumnName+'))  from ' + @dbname1+'.'+@ObjectName+ '' )
  insert into @minMax(minvalue,maxvalue,AvgValue,STDEVValue,DistinctCount,Count,ColumnName,ObjectName,P,NullCount,minLen,Maxlen )
  exec(@sql1)
  insert into @ColumnObjectName(ColumnName,ObjectName,DataType,DBName,length,precision,scale,[is_nullable])
  select @ColumnName,@ObjectName,@DataType,@dbname1,@length,@precision,@scale,@is_nullable
 
  set @i=@i+1
end

declare @max1 int =(select MAX(id) from @temptable1)
 declare @i1 int =1
 
   while @i1<=@max1
  begin
  declare @ColumnName1 varchar(50)=(select  [ColumnName] from @temptable1 where id=@i1)
  declare @ObjectName1 varchar(50)=(select  [ObjectName] from @temptable1 where id=@i1) 
  Declare @DataType1 varchar(50)=(select DataType from @temptable1 where id=@i1)
  declare @length1 int =(select  length from @temptable1 where id=@i1)
   declare @precision1 int =(select precision from @temptable1 where id=@i1)
  declare @scale1 int =(select scale from @temptable1 where id=@i1)
  declare @is_nullable1 bit =(select [is_nullable] from @temptable1 where id=@i1)
  declare @sql2 nvarchar(max)
  set @sql2=('select  Null,Null,Null,Null,Count(distinct '+@ColumnName1+' ) as DistinctCount ,Count(*) as Count, '''+@columnName1+''',
  '''+@ObjectName1+''' ,(100.0 * SUM(CASE WHEN '+@ColumnName1+' IS NULL THEN 1 ELSE 0 END) / COUNT(*)) as p,SUM(CASE WHEN '+@ColumnName1+' IS NULL THEN 1 ELSE 0 END) as NullCount,
  Min(len('+@ColumnName1+')),Max(len('+@ColumnName1+'))  from ' + @dbname1+'.'+@ObjectName1+ '' )
  insert into @Count_Distinct(minvalue,maxvalue,AvgValue,STDEVValue,DistinctCount,Count,ColumnName,ObjectName,p,NullCount,minLen,Maxlen )
  exec(@sql2)
  insert into @ColumnObjectName1(ColumnName,ObjectName,DataType,DBName,length,precision,scale,[is_nullable])
  select @ColumnName1,@ObjectName1,@DataType1,@dbname1,@length1,@precision1,@scale1,@is_nullable1
 
  set @i1=@i1+1
end

delete from .[dbo].[Data_Profile_NULL_Counts] where [Database_Name]=@dbname

insert into .[dbo].[Data_Profile_NULL_Counts] (
[Database_Name]
      ,[Table_Name]
      ,[Column_Name]
      ,[SqlDbType]
      ,[Max_Length]
      ,[Precision]
      ,[Scale]
      ,[IsNullable]
      ,[Row_Count]
      ,[Null_Count])


select distinct t.DataBaseName,t.TableName,t.ColumnName,t.DataType,t.length,t.precision,t.scale,case when t.is_nullable=0 then 'No' else 'Yes' end as Nullable ,t.Count,
case when  t.NullCount is null then 0 else t.NullCount end as NullCount from (

select c.ColumnName,c.ObjectName as TableName,c.DBName as DataBaseName,DataType,m.Minvalue,m.MaxValue,AvgValue,
m.STDEVValue as StdValue,DistinctCount,Count,case when P IS null then 100 else P end as NullPercentage,isnull(minLen,0) as MinLen,isnull(Maxlen,0) as MaxLen,
c.length,m.NullCount ,c.precision,c.scale,cast(c.is_nullable as varchar) as is_nullable

 from @minMax m
join @ColumnObjectName c on c.ColumnName=m.ColumnName and m.ObjectName=c.ObjectName
union
select c.ColumnName,c.ObjectName,c.DBName as DataBaseName,DataType,m.Minvalue,m.MaxValue,AvgValue,
m.STDEVValue as StdValue,DistinctCount,Count,case when P IS null then 100 else P end as NullPercentage,isnull(minLen,0) as MinLen,isnull(Maxlen,0) as MaxLen,
c.length,m.NullCount ,c.precision,c.scale,cast(c.is_nullable as varchar) as is_nullable from
 @Count_Distinct m join @ColumnObjectName1 c on  c.ColumnName=m.ColumnName and m.ObjectName=c.ObjectName
) t

delete from .[dbo].[Data_Profile_ColumnStatistics] where [Database_Name]=@dbname

insert into .[dbo].[Data_Profile_ColumnStatistics]
(
      [Database_Name]
      ,[Table_Name]
      ,[Column_Name]
      ,[Row_Count]
      ,[Min_Value]
      ,[Max_Value]
      ,[Mean]
      ,[StdDev]
  )

select distinct t.DataBaseName,t.TableName,t.ColumnName,t.Count,t.Minvalue,t.MaxValue,t.AvgValue,t.StdValue
 from (

select c.ColumnName,c.ObjectName as TableName,c.DBName as DataBaseName,DataType,m.Minvalue,m.MaxValue,AvgValue,
m.STDEVValue as StdValue,DistinctCount,Count,case when P IS null then 100 else P end as NullPercentage,isnull(minLen,0) as MinLen,isnull(Maxlen,0) as MaxLen,
c.length,m.NullCount ,c.precision,c.scale,cast(c.is_nullable as varchar) as is_nullable

 from @minMax m
join @ColumnObjectName c on c.ColumnName=m.ColumnName and m.ObjectName=c.ObjectName
union
select c.ColumnName,c.ObjectName,c.DBName as DataBaseName,DataType,m.Minvalue,m.MaxValue,AvgValue,
m.STDEVValue as StdValue,DistinctCount,Count,case when P IS null then 100 else P end as NullPercentage,isnull(minLen,0) as MinLen,isnull(Maxlen,0) as MaxLen,
c.length,m.NullCount ,c.precision,c.scale,cast(c.is_nullable as varchar) as is_nullable from
 @Count_Distinct m join @ColumnObjectName1 c on  c.ColumnName=m.ColumnName and m.ObjectName=c.ObjectName
) t

delete from .[dbo].[Data_Profile_LengthDistribution] where  [Database_Name]=@dbname

insert into .[dbo].[Data_Profile_LengthDistribution]
(
      [Database_Name]
      ,[Table_Name]
      ,[Column_Name]
      ,[Row_Count]
      ,[Min_Length]
      ,[Max_Length]
      ,[Length]
      ,[Count]
     
)

select distinct t.DataBaseName,t.TableName,t.ColumnName,t.Count,t.MinLen,t.MaxLen,t.length,t.DistinctCount
 from (

select c.ColumnName,c.ObjectName as TableName,c.DBName as DataBaseName,DataType,m.Minvalue,m.MaxValue,AvgValue,
m.STDEVValue as StdValue,DistinctCount,Count,case when P IS null then 100 else P end as NullPercentage,isnull(minLen,0) as MinLen,isnull(Maxlen,0) as MaxLen,
c.length,m.NullCount ,c.precision,c.scale,cast(c.is_nullable as varchar) as is_nullable

 from @minMax m
join @ColumnObjectName c on c.ColumnName=m.ColumnName and m.ObjectName=c.ObjectName
union
select c.ColumnName,c.ObjectName,c.DBName as DataBaseName,DataType,m.Minvalue,m.MaxValue,AvgValue,
m.STDEVValue as StdValue,DistinctCount,Count,case when P IS null then 100 else P end as NullPercentage,isnull(minLen,0) as MinLen,isnull(Maxlen,0) as MaxLen,
c.length,m.NullCount ,c.precision,c.scale,cast(c.is_nullable as varchar) as is_nullable from
 @Count_Distinct m join @ColumnObjectName1 c on  c.ColumnName=m.ColumnName and m.ObjectName=c.ObjectName
) t

/*
-------------------------------------------------------------
insert into .[dbo].[Data_Profile_CandiateKey2]
(
      [Database_Name]
      ,[Table_Name]
      ,[Column_Name]
      ,[Keycolumn]
 )


 select distinct t.DataBaseName,t.TableName,t.ColumnName,(t.DistinctCount/t.Count)*100
 from (


select c.ColumnName,c.ObjectName as TableName,c.DBName as DataBaseName,DataType,m.Minvalue,m.MaxValue,AvgValue,
m.STDEVValue as StdValue,DistinctCount,Count,case when P IS null then 100 else P end as NullPercentage,isnull(minLen,0) as MinLen,isnull(Maxlen,0) as MaxLen,
c.length,m.NullCount ,c.precision,c.scale,cast(c.is_nullable as varchar) as is_nullable

 from @minMax m
join @ColumnObjectName c on c.ColumnName=m.ColumnName and m.ObjectName=c.ObjectName
union
select c.ColumnName,c.ObjectName,c.DBName as DataBaseName,DataType,m.Minvalue,m.MaxValue,AvgValue,
m.STDEVValue as StdValue,DistinctCount,Count,case when P IS null then 100 else P end as NullPercentage,isnull(minLen,0) as MinLen,isnull(Maxlen,0) as MaxLen,
c.length,m.NullCount ,c.precision,c.scale,cast(c.is_nullable as varchar) as is_nullable from
 @Count_Distinct m join @ColumnObjectName1 c on  c.ColumnName=m.ColumnName and m.ObjectName=c.ObjectName
) t


-----------------------------------------------------
*/
       
declare @temptable3 table
  (
  id int identity(1,1),
  [ColumnName] nvarchar(50),
  [ObjectName] nvarchar(50),
  DatabaseName nvarchar(50),
  DataType varchar(50),
   length int

 
  )     

   declare @minMax3 table
  (
  id int identity(1,1),
  value varchar(50),
  count int,
  ColumnName varchar(50),
  ObjectName varchar(50),
  DBName varchar(50)

  )
 
   declare @minMax4 table
  (
  id int identity(1,1),
  Minvalue float,
  MaxValue float,
  AvgValue Float,
  STDEVValue float,
  DistinctCount int,
  Count int,
  ColumnName nvarchar(50) null,
  ObjectName nvarchar(50) null,
  P float null,
  minLen nvarchar(50) null,
  Maxlen nvarchar(50) null
  )


  Insert into @temptable3([ColumnName],[ObjectName],DatabaseName,DataType,length)
  select [ColumnName],[ObjectName],DatabaseName,DataType,length from @BIP_sourcetable where   DataType
 in ('int','float','decimal','tinyint','smallint')

   declare @max3 int =(select MAX(id) from @temptable3)
 
  declare @i3 int =1
 
   while @i3<=@max3
  begin
  declare @ColumnName3 varchar(50)=(select  [ColumnName] from @temptable3 where id=@i3)
  declare @ObjectName3 varchar(50)=(select  [ObjectName] from @temptable3 where id=@i3) 
  Declare @DataType3 varchar(50)=(select DataType from @temptable3 where id=@i3) 
  declare @sql3 nvarchar(max)
  declare @sql4 nvarchar(max)
  set @sql3=('select '+@ColumnName3+',count('+@ColumnName3+') , '''+@ColumnName3+''','''+ @ObjectName3+''','''+ @dbname1+''' from ' + @dbname1+'.'+@ObjectName3+ ' group by '+@ColumnName3+'' )
  insert into @minMax3(value,count,ColumnName,ObjectName,DBName )
  exec(@sql3)
 
   set @sql4=('select  min('+@ColumnName3+'),max('+@ColumnName3+'),avg(cast('+@ColumnName3+' as bigint)) ,STDEV('+@ColumnName3+'),Count(distinct '+@ColumnName3+' ) as DistinctCount ,
  Count(*) as Count,'''+@columnName3+''','''+@ObjectName3+''',(100.0 * SUM(CASE WHEN '+@ColumnName3+' IS NULL THEN 1 ELSE 0 END) / COUNT(*)) as p,Min(len('+@ColumnName3+')),Max(len('+@ColumnName3+'))  from ' + @dbname1+'.'+@ObjectName3+ '' )
  insert into @minMax4(minvalue,maxvalue,AvgValue,STDEVValue,DistinctCount,Count,ColumnName,ObjectName,P,minLen,Maxlen )
  exec(@sql4)
  set @i3=@i3+1
end

delete from .[dbo].[Data_Profile_ValueDistribution] where [Database_Name]=@dbname

insert into .[dbo].[Data_Profile_ValueDistribution]
(

   [Database_Name]
      ,[Table_Name]
      ,[Column_Name]
      ,[Row_Count]
      ,[NumberOfDistinctValues]
      ,[Value]
      ,[Count]
)

select m.DBName,m.ObjectName,m.ColumnName,m1.Count AS [RowCount],m1.DistinctCount, m.value,m.count from @minMax3 m
join @minMax4 m1 on m1.ColumnName=m.ColumnName and m.ObjectName=m1.ObjectName


end



GO
SET ANSI_PADDING ON
GO
```