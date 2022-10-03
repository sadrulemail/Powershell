$BasePath=$PSScriptRoot

$query="DB_COMPATIBILITY_LEVEL_Report.sql"

$SRVList="ServerList.txt"
$csvFileName = "DB_COMPATIBILITY_LEVEL_Report.csv"
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
                SERVER_NAME = $_.SRV_Name
                Database_Name = $_.Database_Name
                compatibility_level=$_.compatibility_level
				SQL_Server_Version=$_.SQL_Server_Version
				Supported_compatibility_level=$_.Supported_compatibility_level
				Script=$_.Script
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