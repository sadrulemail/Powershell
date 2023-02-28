
$RootPath = '\\phl-svm-cifs-01.WCGCLINICAL.COM\phl_sql_non_prod_backup\'
 
#gets a list of folders under the $startDirectory directory
$directoryItems = Get-ChildItem $RootPath 
#| Where-Object {$_.PSIsContainer -eq $true} | Sort-Object
#$directoryItems
 
 $List=$directoryItems | Select name, CreationTime, @{N="Owner";E={ (Get-Acl $_.FullName).Owner }}|Where-Object {$_.Owner -eq "WCGCLINICAL\salom-a"}
 $List
 #$FilterData=$List|Where-Object {$_.Owner -eq "WCGCLINICAL\salom-a"}
