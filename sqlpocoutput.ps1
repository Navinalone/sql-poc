
Clear 
Write-Host "Queries excution started"
$rg      = "rgname"
$sqluser = "@@@@@@@"
$sqlpwd  = "**********"

[parameter(Mandatory=$false)][string]$sourcefile = "C:\Users\NPotnuru\sqlpoc\InvokeSQL.csv"
$sourcefileitems = Import-Csv $sourcefile

$Spath                       = "C:\Users\NPotnuru\sqlpoc\SourceFile.csv"            #Source count path
$Dpath                       = "C:\Users\NPotnuru\sqlpoc\DestinationFile.csv"       #Destination count path
$validationfile              = "C:\Users\NPotnuru\sqlpoc\validationoutput.csv"      #validation file
$BackupRecoveryCheck         = "C:\Users\NPotnuru\sqlpoc\BackupRecoveryCheck.csv"   #Backup&recoverycheck file path


Add-Content "Sourcecount" -Path $Spath                    
Add-Content "Destinationcount" -Path $Dpath               

foreach($Item in $sourcefileitems) {

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
       
        Sourcecount      = $CSV1[$i].Sourcecount
        Destinationcount = $CSV2[$i].Destinationcount
        Result           = $Match
    }
}

$Results | Export-Csv -Path $validationfile -NoTypeInformation

$path1 = Import-Csv -Path $sourcefile
$path2 = Import-Csv -Path $validationfile

$Count1 = $path2.Count

   $ref = For ($i = 0; $i -lt $Count1; $i++){
   
   [PSCustomObject]@{

        PipelineName     = $path1[$i].PipelineName
        ActivityName     = $path1[$i].ActivityName
        SourceDB         = $path1[$i].SourceDB
        SourceQuery      = $path1[$i].SourceQuery
        Sourcecount      = $path2[$i].Sourcecount
        DestinationDB    = $path1[$i].DestinationDB
        DestinationQuery = $path1[$i].DestinationQuery
        Destinationcount = $path2[$i].Destinationcount
        Result           = $path2[$i].Result

    }
  }

  
  $ref | Export-Csv -Path $BackupRecoveryCheck  -NoTypeInformation 
   
  # $ref | Export-Csv -Path C:\Users\NPotnuru\sqlpoc\BackupRecoveryCheck_$((Get-Date).ToString("yyyyMMdd_HHmmss")).csv -NoTypeInformation -Force
        
    Remove-Item -path $Spath
    Remove-Item -path $Dpath
    Remove-Item -path $validationfile

    Write-Host "Queries excution is completed"