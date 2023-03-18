<#
Author: Sadrul (sadrul.email@gmail.com)
Date: 18 March 2023
Linkedin: https://www.linkedin.com/in/sadrulalom
#>
$DBInventorySRV = "INV_DB_SRV_NAME"
$InventoryDBName="DB_NAME"
$DBSRVList = invoke-sqlcmd -ServerInstance $DBInventorySRV -Database $InventoryDBName `
-Query "select  rtrim(ltrim(HostName)) as SrvName from TBL_NAME where isactive=1 and islistener=0"
#write-host $DBSRVList.SrvName
foreach($DBSRVName in $DBSRVList)
{
    $Inst= $DBSRVName.SrvName
    #write-host $Inst
    $SrvSQLProductInfo = invoke-sqlcmd -ServerInstance $Inst  `
        -Query "SELECT cpu_count,CEILING(physical_memory_kb/1048576.0) RAM,SERVERPROPERTY('ProductVersion') AS ProductVersion,SERVERPROPERTY('Edition') AS Edition FROM sys.dm_os_sys_info OPTION (RECOMPILE);"

    $CPU = $SrvSQLProductInfo.cpu_count
    $Memory = $SrvSQLProductInfo.RAM
    $ProductVersion = $SrvSQLProductInfo.ProductVersion
    $Edition = $SrvSQLProductInfo.Edition

    $InvUpdateScript = "update TBL_NAME set [CPU] = "+$CPU+", [Memory] = "+$Memory+", [Version] = '"+$ProductVersion+"', [Edition] = '"+ $Edition `
        +"' where HostName='"+$Inst+"';"

    write-host $InvUpdateScript

    invoke-sqlcmd -ServerInstance $DBInventorySRV -Database $InventoryDBName -Query $InvUpdateScript
}