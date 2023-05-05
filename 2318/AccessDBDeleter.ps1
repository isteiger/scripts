param(
    [Parameter()]
    [switch]$NoInteraction = $False,

    [Parameter()]
    [switch]$PressToExit = $False,
    
    [Parameter()]
    [switch]$SearchAllDrives = $False,
    
    [Parameter()]
    [String]$SearchDir,

    [Parameter()]
    [string[]]$SearchDirs

)
Write-Host "Access Database Finder & Deleter `n© 2023 Ian Steiger (isteiger.com) `n" -ForegroundColor blue -BackgroundColor white
if (!([Security.Principal.WindowsPrincipal] `
  [Security.Principal.WindowsIdentity]::GetCurrent() `
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
Write-Host "Not in administrator mode. The functionality of this script may be limited.`n" -ForegroundColor red -BackgroundColor white
}
Write-Host "Searching for files..." -ForegroundColor blue -BackgroundColor white
if ($SearchAllDrives) {
    $SearchDirs = (gdr -PSProvider 'FileSystem').Root
} elseif ($SearchDirs) {
    # do nothing, as variable is already defined
} elseif ($SearchDir) {
    $SearchDirs = $SearchDir
} else {
    $SearchDirs = (Get-ChildItem –Path "C:\Users\").FullName
}

$accessDBFiles = gci $SearchDirs *.accdb -file -ea silent -recurse
if (!$accessDBFiles) { # if there are no db files
    Write-Host "No Access database files found! Exiting...." -ForegroundColor red -BackgroundColor white
} else {
    Write-Host "Access database files found! Here is the list: `n" -ForegroundColor white -BackgroundColor Green
    Write-Host "- "($accessDBFiles.FullName -join "`n-  ")
    if ($NoInteraction) { # if the no interaction flag is set, run without requring user interaction.
        Remove-Item $accessDBFiles.FullName -Force
        Write-Host "`nDeletion completed! Exiting..." -ForegroundColor green
    } else {
        $confirmation = Read-Host "Continue to deletion? (y/n) " # confirm deletion because it's destructive.
        if ($confirmation -eq 'y') {
            Remove-Item $accessDBFiles.FullName -Force
            Write-Host "`nDeletion completed! Exiting..." -ForegroundColor White -BackgroundColor Green
        } else {
            Write-Host "`nNo selected, so not deleting. Exiting..." -ForegroundColor blue -BackgroundColor white
        }
    }
}

if (!$psISE -and $PressToExit) { # don't require pressing key to continue if press to exit is not enabled or if running in powershell ise
    Write-Host -NoNewLine 'Press any key to exit...' -ForegroundColor red -BackgroundColor white
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}