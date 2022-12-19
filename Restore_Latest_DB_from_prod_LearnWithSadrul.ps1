
#############
#Created by:Sadrul
#Created Date: 18 DEC 2022
#Purpose: restore db from a location
#Ticket:
#Source Server: srv1
#Target Server: srv2

#############

$BackupSourceServer = 'srv1';
$BackupSourceDBName = 'LearnWithSadrul';

$DestinationServerName = 'srv2';
$DestinationDBName = 'LearnWithSadrul';
$DestinationDBReplace = 'Y';
$DestinationDataPath='U:\data';
$DestinationLogPath='L:\data';

#############################################################
$OutputMessage = ''

$error.clear()
# find latest backup path name from source server
$find_latest_bkup_path="SELECT  top 1   
   s.database_name,  
   f.physical_device_name,
  case when cast(s.backup_finish_date as date)=cast(getdate() as date) then 1 else 0 end AS isLatestbackup 
FROM 
   msdb.dbo.backupmediafamily  f
   INNER JOIN msdb.dbo.backupset s ON f.media_set_id = s.media_set_id  
WHERE s.type = 'D' and s.database_name='"+$BackupSourceDBName+"' 
ORDER BY  
   s.backup_finish_date desc";

try{	
		$OutputMessage+="`n find latest backup.";
		$path_query_result = Invoke-Sqlcmd -Query $find_latest_bkup_path -ServerInstance $BackupSourceServer -ErrorAction 'Stop';
	} Catch {
		Write-error $OutputMessage
		#throw $error;
	}
if($path_query_result -ne $null)
{
	$bakup_full_path = $path_query_result.physical_device_name
}
#$bakup_full_path

#check backup file exist or not in backup location
if (!(Test-Path $bakup_full_path))
{
	$OutputMessage+="`nBackup file do not exist"
}

$SQL_KILL_EXISTING_SESSIONS = "IF ((select DB_ID('"+$DestinationDBName+"')) is not null)
BEGIN
	ALTER DATABASE ["+$DestinationDBName+"] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	ALTER DATABASE ["+$DestinationDBName+"] SET MULTI_USER;
END";

IF ($DestinationDBReplace -eq 'Y')
{
	try{	
		$OutputMessage+="`n Killing Existing Connections.";
		$DBRestoreResult = Invoke-Sqlcmd -Query $SQL_KILL_EXISTING_SESSIONS -ServerInstance $DestinationServerName -ErrorAction 'Stop';
	} Catch {
		Write-error $OutputMessage
		#throw $error;
	}
}

$replace_db_file = ''
IF ($DestinationDBReplace -eq 'Y')
{
	$replace_db_file = 'REPLACE,'
}

$restore_script="USE [master]
GO
RESTORE DATABASE ["+$DestinationDBName+"] FROM  DISK = N'"+$bakup_full_path+"' 
WITH  FILE = 1,  
MOVE N'AdjudicateV3' TO N'"+$DestinationDataPath+"\AdjudicateV3.mdf',
MOVE N'AdjudicateV3_log' TO N'"+$DestinationLogPath+"\AdjudicateV3_log.ldf',  
NOUNLOAD,  "+$replace_db_file+"  STATS = 5;"

# $restore_script

try{	
	$OutputMessage+="`nStarting Restore.";
	$DBRestoreResult = Invoke-Sqlcmd -Query $restore_script -ServerInstance $DestinationServerName -ErrorAction 'Stop' -ConnectionTimeout 0 -QueryTimeout 0;
} Catch {
	Write-error $OutputMessage
	throw $error;
}
$OutputMessage+="`nRestore Database '$DestinationDBName' Done!"
$OutputMessage