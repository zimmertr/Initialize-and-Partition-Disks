clear
$ErrorActionPreference = "Stop" #Automatically exit script in the event of an unhandled exception.
Write-Host "Welcome to the Disk Preperation script. - $(Get-Date -Format T)" -ForegroundColor "Green"; Write-Host

Write-Host "Detecting raw disks. - $(Get-Date -Format T)" -ForegroundColor "Yellow"; Write-Host
$numDisks = (Get-Disk | Where-Object {$_.PartitionStyle -eq 'RAW'} | Sort-Object -Property Name | Measure-Object).Count
$rawDisks = (Get-Disk | Where 'partitionstyle' -eq 'RAW' | Sort-Object -Property Number)

if ($rawDisks){
    Write-Host "There are $numDisks disks that require initialization and formatting. - $(Get-Date -Format T)" -ForegroundColor "Yellow"; Write-Host
}
else{
    Write-Host "No RAW disks were detected on your machine. Either they've already been initialized or they do not exist. - $(Get-Date -Format T)" -ForegroundColor "Red"
    exit
}

$count = 0
$total = $numDisks
while ($count -lt $total){
    $diskNum = ($rawDisks | Select-Object -Index $count).Number
    Write-Host "Initializing Disk $($diskNum): $($rawDisks[$count].Size /1GB)GB" -ForegroundColor Cyan

    $driveLetter = Read-Host -Prompt "Enter Drive Letter (ex: F)"
    #Function to check for existance of Drive Letter.
    function checkIfDriveLetterExists {
        Param ([string]$funDriveLetter)

        try{
            Get-Partition -DriveLetter $funDriveLetter -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue
        }catch{}
    }
    while (checkIfDriveLetterExists($driveLetter)){
        $driveLetter = Read-Host -Prompt "Drive letter already in use. Please enter a Drive Letter for Disk $($count) (ex: F)"
    }

    $fsLabel = Read-Host -Prompt "Enter Label"
    
    if ($($rawDisks[$count].size -gt 2199023255552)){
        Write-Host "Formatting Disk with a GPT partition table."
        Initialize-Disk -Number $diskNum -PartitionStyle GPT -PassThru -WarningAction SilentlyContinue | New-Partition -DriveLetter $driveLetter -UseMaximumSize -WarningAction SilentlyContinue | Format-Volume -FileSystem NTFS -NewFileSystemLabel $fsLabel -AllocationUnitSize "65536" -Confirm:$false -WarningAction SilentlyContinue > $null
    }
    else{
        Write-Host "Formatting Disk with an MBR partition table."
        Initialize-Disk -Number $diskNum -PartitionStyle MBR -PassThru -WarningAction SilentlyContinue | New-Partition -DriveLetter $driveLetter -UseMaximumSize -WarningAction SilentlyContinue | Format-Volume -FileSystem NTFS -NewFileSystemLabel $fsLabel -AllocationUnitSize "65536" -Confirm:$false -WarningAction SilentlyContinue > $null
    }   
    Write-Host

    $count = $count + 1
}

Write-Host; Write-Host "All steps have completed successfully. Printing a deployment summary now. - $(Get-Date -Format T)" -ForegroundColor "Green"; Write-Host
Get-Disk | Sort-Object -Property Number
Write-Host; Read-Host -Prompt "Press Enter to exit"
