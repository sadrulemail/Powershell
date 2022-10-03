#$BasePath="C:\Users\salom-a\Desktop\DBQA"
$BasePath=$PSScriptRoot

$query="dbowner_report.sql"
#$queryPath=$BasePath\$QA_SQL_FileName
$SRVList="ServerList.txt"
$csvFileName = "DBOwnerResults.csv"
$ErrorSrvListFileNAme="ErrorServerList.txt"
$ErrorServerList=""
if(Test-Path $BasePath\$csvFileName)
{
    remove-item $BasePath\$csvFileName

}

$instanceNameList = get-content $BasePath\$SRVList -Force

$TotalServersCount=0
$ErrorServersCount=0

$TotalServersCount=$instanceNameList.Count

foreach($instanceName in $instanceNameList)
{
$instanceName
        write-host "Executing query against server: " $instanceName -BackgroundColor DarkGreen -ForegroundColor White
		try
		{
			#$results = Invoke-Sqlcmd -InputFile $queryPath -ServerInstance $instanceName

        Invoke-Sqlcmd -InputFile $BasePath\$query -ServerInstance $instanceName  -ErrorAction SilentlyContinue | foreach {[PSCustomObject]@{
                SERVER_NAME = $_.srv_name
                DBName = $_.DBName
                ownerName=$_.ownerName
            }

        }|  export-csv  $BasePath\$csvFileName   -NoTypeInformation -Append 
		}
		catch
		{
            $ErrorServersCount+=1
            write-host "Error on Server: " $instanceName -BackgroundColor DarkRed -ForegroundColor White
			$ErrorServerList+=$instanceName +"`n"
		}
} 
 
# Output to CSV
 Write-Host "Error on " $ErrorServersCount  " out of " $TotalServersCount -BackgroundColor Red -ForegroundColor White

$ErrorServerList | Out-File -FilePath $BasePath\$ErrorSrvListFileNAme