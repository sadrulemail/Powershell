$BasePath=$PSScriptRoot
$query = "DB_COMPATIBILITY_LEVEL_Change.sql"
$reportpsname="AutoGrowthReport.ps1"

$csvFileName = "queryresults.csv"
$SRVList="ServerList.txt"
$instanceNameList = get-content $BasePath\$SRVList -Force

  
foreach($instanceName in $instanceNameList)
{
        write-host "Executing query against server: " $instanceName
        
		try
		{
			#$results += Invoke-Sqlcmd -Query $query -ServerInstance $instanceName -ErrorAction Stop
			$results += Invoke-Sqlcmd -InputFile $BasePath\$query -ServerInstance $instanceName
		}
		catch
		{
			Write-Output "Something threw an exception"
		}
}
# Output to CSV

Start-Sleep -s 2
#write-host "Saving Query Results in CSV format..."
#$results | export-csv  $BasePath\$csvFileName   -NoTypeInformation
