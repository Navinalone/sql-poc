
$rg = ""
$sqluser = ""
$sqlpwd = ""

[parameter(Mandatory=$false)][string]$sourcefile = "C:\Users\NPotnuru\sqlpoc\InvokeSQL.csv"
$sourcefileitems = Import-Csv $sourcefile

$Spath = "C:\Users\NPotnuru\sqlpoc\SourceFile.csv"         #Source count path
$Dpath = "C:\Users\NPotnuru\sqlpoc\DestinationFile.csv"     #Destination count path


Add-Content "Sourcecount" -Path $Spath
Add-Content "Destinationcount" -Path $Dpath

foreach($Item in $sourcefileitems) {

Write-Host "Source DB -" $Item.SourceDB -ForegroundColor Green
Write-Host "Destinaton DB -" $Item.DestinationDB -ForegroundColor Green
Write-Host "Source Query - " $Item.SourceQuery -ForegroundColor Green
Write-Host "Destination Query -" $Item.DestinationQuery -ForegroundColor Green

if ($Item.SourceDB -eq "Product") { 
    $say = Invoke-Sqlcmd -ServerInstance $rg-sql.database.windows.net -Database $rg-sql-db-productmanagementdb -EncryptConnection -Username $sqluser -Password $sqlpwd -Query "$($Item.SourceQuery)"
    $say.Column1 >> $Spath } 
    
if ($Item.DestinationDB -eq "Supplier") { 
    $say = Invoke-Sqlcmd -ServerInstance $rg-sql.database.windows.net -Database $rg-sql-db-suppliermanagementdb -EncryptConnection -Username $sqluser -Password $sqlpwd -Query "$($Item.DestinationQuery)"
    $say.Column1 >> $Dpath }

if ($Item.DestinationDB -eq "Shared") { 
    $say = Invoke-Sqlcmd -ServerInstance $rg-sql.database.windows.net -Database $rg-sql-db-nexusshareddb -EncryptConnection -Username $sqluser -Password $sqlpwd -Query "$($Item.DestinationQuery)"
    $say.Column1 >> $Dpath }

}


$CSV1 = Import-Csv -Path $Spath
$CSV2 = import-csv -path $Dpath

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


$Results | Export-Csv -Path C:\Users\NPotnuru\sqlpoc\validationoutput.csv -NoTypeInformation



