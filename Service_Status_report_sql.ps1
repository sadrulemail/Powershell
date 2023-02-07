#for cluster add cluster access point only, because secondary node is not accessable
#for AOAG add all nodes
$InfoDetails = ('Name,Status,ServerName')
$SQLService_Info_Final=@()
$servers=get-content "D:\DBA_REPORTS\SQL & Agent Service Status Report\phl_servers.txt"
foreach($server in $servers)
{
    $error.clear();
    try{
        $ServiceInfo = Get-service -ComputerName $server  | where {($_.name -like "MSSQL$*" -or $_.name -like "MSSQLSERVER" -or $_.name -like "SQL Server (*" -or $_.name -like "SQL Server Agent(*" -or $_.name -like "SQLAGENT*" -or $_.name -like "SQL*AGENT")} | select Name,status
         
    }  
    Catch {
		$ServiceInfo = $error[$error.count-1]
		$ServiceInfo = $server+',,,'+ $ServiceInfo
		$ServiceInfo = ($InfoDetails,$ServiceInfo)
	}
    $ServiceInfo | Add-Member -MemberType NoteProperty -Name 'ServerName' -Value $server
    $SQLService_Info_Final+= [PSCustomObject] $ServiceInfo
}
$SQLService_Info_Final
$StopServiceList=$SQLService_Info_Final | where {($_.status -ne "Running")}
$StopServiceList

if($StopServiceList){
    #$netverhtml = $SQLService_Info_Final| ConvertTo-Html -AS Table -Fragment -Property *
    
    $netverhtml = $StopServiceList| ConvertTo-Html -AS Table -Fragment -Property *
	$netverhtml="<b>please check below stopped services</b>"+"<br><br>"+$netverhtml
      # Sender and Recipient Info
    $MailFrom = "itdba@wcgclinical.com"
    $MailTo = "salom@wcgclinical.com,sazam@wcgclinical.com,mprince@wcgclinical.com,fhossain@wcgclinical.com,msamio@wcgclinical.com"

    # Server Info
    $SmtpServer = "Prodapp01.epsnet.wan"
    $SmtpPort = "25"
    # Message stuff
    $MessageSubject = "SQL Server & Agent Status "+$((get-date).ToLocalTime()).ToString("yyyy-MM-dd HHmmsstt")
    $Message = New-Object System.Net.Mail.MailMessage $MailFrom,$MailTo
    $Message.IsBodyHTML = $true
    $Message.Subject = $MessageSubject
    $Message.Body = $netverhtml
    # Construct the SMTP client object, credentials, and send
    $Smtp = New-Object Net.Mail.SmtpClient($SmtpServer,$SmtpPort)

    $Smtp.Send($Message)
}