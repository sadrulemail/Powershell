select @@servername as srv_name, db_name(database_id) as DBName, name as LogicalfileName, type_desc,size,growth,
--case 
--	when (size/128)<1024 then
--		'ALTER DATABASE ['+db_name(database_id)+'] MODIFY FILE ( NAME = N'''+name+''', FILEGROWTH = '+
--		case when type_desc='LOG' then '32768KB' else '65536KB' end+' );'
--	when  (size/128) between 1024 and 10240    then 
--		'ALTER DATABASE ['+db_name(database_id)+'] MODIFY FILE ( NAME = N'''+name+''', FILEGROWTH = '+
--		case when type_desc='LOG' then '65536KB' else '131072KB' end+' );'
--	when  (size/128)>10240 and (size/128)<102400 then
--	'ALTER DATABASE ['+db_name(database_id)+'] MODIFY FILE ( NAME = N'''+name+''', FILEGROWTH = '+
--		case when type_desc='LOG' then '131072KB' else '524288KB' end+' );'
--	else
--	'ALTER DATABASE ['+db_name(database_id)+'] MODIFY FILE ( NAME = N'''+name+''', FILEGROWTH = '+
--		case when type_desc='LOG' then '524288KB' else '1048576KB' end+' );'
--end scripts
case 
	when database_id in (3,4) then
		'ALTER DATABASE ['+db_name(database_id)+'] MODIFY FILE ( NAME = N'''+name+''', FILEGROWTH = '+
		case when type_desc='LOG' then '32768KB' else '65536KB' end+' );'
	when  (size/128) <1024 and database_id not in (3,4)    then 
		'ALTER DATABASE ['+db_name(database_id)+'] MODIFY FILE ( NAME = N'''+name+''', FILEGROWTH = '+
		case when type_desc='LOG' then '32768KB' else '65536KB' end+' );'	
	else
	'ALTER DATABASE ['+db_name(database_id)+'] MODIFY FILE ( NAME = N'''+name+''', FILEGROWTH = '+
		case when type_desc='LOG' then '131072KB' else '131072KB' end+' );'
end scripts
from sys.master_files
where 
is_percent_growth=1 and 
state_desc='online' and 
database_id >1;