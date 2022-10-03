#$BasePath="C:\Users\salom-a\Desktop\DBQA"
$BasePath=$PSScriptRoot

$query="AutogrowthReport.sql"
#$queryPath=$BasePath\$QA_SQL_FileName
$SRVList="ServerList.txt"
$csvFileName = "AutoGrowthResults.csv"
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
                LogicalfileName=$_.LogicalfileName
				type_desc=$_.type_desc
				size=$_.size
				growth=$_.growth
				scripts=$_.scripts
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