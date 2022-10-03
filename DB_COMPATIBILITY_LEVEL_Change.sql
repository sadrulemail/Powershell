declare @scripts varchar(max)='';

select @scripts=COALESCE(@scripts,'','') +
'use master;ALTER DATABASE ['+t1.Database_Name+'] SET COMPATIBILITY_LEVEL = '+t1.Supported_compatibility_level+';'
from (SELECT
   d.name AS [Database_Name]
   ,d.compatibility_level
   ,CASE
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '8%' THEN 'SQL2000'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '9%' THEN 'SQL2005'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '10.0%' THEN 'SQL2008'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '10.5%' THEN 'SQL2008 R2'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '11%' THEN 'SQL2012'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '12%' THEN 'SQL2014'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '13%' THEN 'SQL2016'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '14%' THEN 'SQL2017'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '15%' THEN 'SQL2019'
        ELSE 'unknown'
    END AS SQL_Server_Version,
	CASE
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '8%' THEN '80'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '9%' THEN '90'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '10.0%' THEN '100'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '11%' THEN '110'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '12%' THEN '120'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '13%' THEN '130'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '14%' THEN '140'
        WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '15%' THEN '150'
        ELSE 'unknown'
    END AS Supported_compatibility_level	
FROM sys.databases d
WHERE d.database_id > 4 and state_desc='online')t1
where t1.compatibility_level <> t1.Supported_compatibility_level

print @scripts

--exec(@scripts)