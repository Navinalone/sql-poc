Connect-AzAccount
Get-AzSubscription
Get-AzContext
Get-AzSubscription "AQA-PDD-DEV"


find-module sqlserver | Install-Module -AllowClobber -Force

import-csv -path C:\Users\NPotnuru\sqlpoc\temp_dest.csv
Import-Csv -Path C:\Users\NPotnuru\sqlpoc\temp_source.csv

   
Rename-Item C:\Users\NPotnuru\sqlpoc\temp_source.txt C:\Users\NPotnuru\sqlpoc\temp_source1.csv
Rename-Item C:\Users\NPotnuru\sqlpoc\temp_dest.txt   C:\Users\NPotnuru\sqlpoc\temp_dest1.csv

==============================================================
Add-Content "sourcecount" -Path C:\Users\NPotnuru\sqlpoc\temp_source.txt

======================================
#Compare-Object $csv1 $csv2 -Property col1.col3 -PassThru


Compare-Object -ReferenceObject $CSV1 -DifferenceObject $CSV2 -Property Value -IncludeEqual | 
    Where-Object { $_.SideIndicator -eq "=>" -or $_.SideIndicator -eq "==" } | 
    Sort-Object -Property value |
    Select-Object -Property Value,@{Name="Result";Expression={$_.SideIndicator -replace '==','Match' -replace '=>','Not Match'}}