declare @scripts varchar(max)='';
select @scripts=COALESCE(@scripts,'','') +
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
end
from sys.master_files
where 
is_percent_growth=1 and 
state_desc='online' and 
database_id >1;

print @scripts
if len(@scripts)>5
begin
	exec(@scripts)
	print 'Done'
end
