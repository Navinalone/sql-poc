$rg = "rg name"
$sqluser = "@@@@"
$sqlpwd = "*****"

[parameter(Mandatory=$false)][string]$sourcefile = "C:\Users\NPotnuru\sqlpoc\InvokeSQL.csv"
$sourcefileitems = Import-Csv $sourcefile

Add-Content "Sourcecount" -Path C:\Users\NPotnuru\sqlpoc\SourceFile.csv
Add-Content "Destinationcount" -Path C:\Users\NPotnuru\sqlpoc\DestinationFile.csv

foreach($Item in $sourcefileitems) {

Write-Host "Source DB -" $Item.SourceDB -ForegroundColor Green
Write-Host "Destinaton DB -" $Item.DestinationDB -ForegroundColor Green
Write-Host "Source Query - " $Item.SourceQuery -ForegroundColor Green
Write-Host "Destination Query -" $Item.DestinationQuery -ForegroundColor Green

if ($Item.SourceDB -eq "Product") { 
    $say = Invoke-Sqlcmd -ServerInstance $rg-sql.database.windows.net -Database $rg-sql-db-productmanagementdb -EncryptConnection -Username $sqluser -Password $sqlpwd -Query "$($Item.SourceQuery)"
    $say.Column1 >> C:\Users\NPotnuru\sqlpoc\SourceFile.csv } 
    
if ($Item.DestinationDB -eq "Supplier") { 
    $say = Invoke-Sqlcmd -ServerInstance $rg-sql.database.windows.net -Database $rg-sql-db-suppliermanagementdb -EncryptConnection -Username $sqluser -Password $sqlpwd -Query "$($Item.DestinationQuery)"
    $say.Column1 >> C:\Users\NPotnuru\sqlpoc\DestinationFile.csv }

if ($Item.DestinationDB -eq "Shared") { 
    $say = Invoke-Sqlcmd -ServerInstance $rg-sql.database.windows.net -Database $rg-sql-db-nexusshareddb -EncryptConnection -Username $sqluser -Password $sqlpwd -Query "$($Item.DestinationQuery)"
    $say.Column1 >> C:\Users\NPotnuru\sqlpoc\DestinationFile.csv }

}

#Rename-Item C:\Users\NPotnuru\sqlpoc\temp_source.txt C:\Users\NPotnuru\sqlpoc\SourceFile.csv
#Rename-Item C:\Users\NPotnuru\sqlpoc\temp_dest.txt C:\Users\NPotnuru\sqlpoc\DestinationFile.csv




$CSV1 = Import-Csv -Path C:\Users\NPotnuru\sqlpoc\SourceFile.csv
$CSV2 = import-csv -path C:\Users\NPotnuru\sqlpoc\DestinationFile.csv

$Count = $CSV2.Count

$Results = For ($i = 0; $i -lt $Count; $i++) {
    If ($CSV2[$i].Destinationcount -eq $CSV1[$i].Sourcecount) {
        $Match = "Match"
    } 
    Else {
        $Match = "Not Match"
    }
    [PSCustomObject]@{
       
        Sourcecount = $CSV1[$i].Sourcecount
        Destinationcount = $CSV2[$i].Destinationcount
        Result = $Match
    }
}

$Results | Export-Csv -Path C:\Users\NPotnuru\sqlpoc\OutputFile.csv -NoTypeInformation

