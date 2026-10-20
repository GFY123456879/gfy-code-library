# GFY Windows System Check

function Show-SystemInfo {
    Write-Host ""
    Write-Host "===== WINDOWS SYSTEM INFO =====" -ForegroundColor Cyan

    Get-CimInstance Win32_OperatingSystem |
        Select-Object CSName, Caption, Version, OSArchitecture,
        @{Name="LastBootTime"; Expression={$_.LastBootUpTime}} |
        Format-List

    Read-Host "Press Enter to return"
}

function Show-DiskInfo {
    Write-Host ""
    Write-Host "===== DISK SPACE =====" -ForegroundColor Cyan

    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
        Select-Object DeviceID,
        @{Name="TotalGB"; Expression={[math]::Round($_.Size / 1GB, 2)}},
        @{Name="FreeGB"; Expression={[math]::Round($_.FreeSpace / 1GB, 2)}},
        @{Name="UsedPercent"; Expression={
            if ($_.Size -gt 0) {
                [math]::Round(($_.Size - $_.FreeSpace) / $_.Size * 100, 1)
            }
            else {
                0
            }
        }} |
        Format-Table -AutoSize

    Read-Host "Press Enter to return"
}

function Show-MemoryInfo {
    Write-Host ""
    Write-Host "===== MEMORY INFO =====" -ForegroundColor Cyan

    $os = Get-CimInstance Win32_OperatingSystem

    $totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedGB = [math]::Round($totalGB - $freeGB, 2)

    Write-Host "Total memory: $totalGB GB"
    Write-Host "Used memory:  $usedGB GB"
    Write-Host "Free memory:  $freeGB GB"

    Read-Host "Press Enter to return"
}

while ($true) {
    Clear-Host

    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host "      GFY SYSTEM CHECK" -ForegroundColor Cyan
    Write-Host "===================================="
    Write-Host ""
    Write-Host "1. Windows system information"
    Write-Host "2. Disk space"
    Write-Host "3. Memory usage"
    Write-Host "0. Exit"
    Write-Host ""

    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" { Show-SystemInfo }
        "2" { Show-DiskInfo }
        "3" { Show-MemoryInfo }
        "0" { break }
        default {
            Write-Host "Invalid option." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
}