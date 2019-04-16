<#
    .SYNOPSIS
        Root module file.

    .DESCRIPTION
        The root module loads all classes, helpers and functions into th
        module content.
#>
Function Clear-Directory
{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$myPath,

        [Parameter(Mandatory = $true)]
        [string]$myBackupPath,

        [Parameter(Mandatory = $false)]
        [int]$backupDays = -30,

        [Parameter(Mandatory = $false)]
        [int]$removeDays = -60,

        [switch]$Whatif
    )

    if (!(Get-Module ScriptLogger))
    {
        ## Or check for the cmdlets you need
        ## Load it nested, and we'll automatically remove it during clean up
        Install-Module -Name ScriptLogger -ErrorAction Stop -Scope CurrentUser#
    }


    $TempFile = Join-Path -Path  $ENV:TEMP -ChildPath "CleanDirectory.log"

    # Second options, specify multiple custom settings for the logger
    Start-ScriptLogger -Path $TempFile -Format '{0:yyyy-MM-dd}   {0:HH:mm:ss}   {1}   {2}   {3,-11}   {4}' -Level Warning -Encoding 'UTF8' -NoEventLog -NoConsoleOutput

    If ($backupDays -gt 0)
    {
        $backupDays = 0 - $backupDays
    }


    if ($removeDays -gt 0)
    {
        $removeDays = 0 - $removeDays
    }


    $files = Get-ChildItem -Path $myPath | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays($backupDays) }

    foreach ($f in $files)
    {
        $myFileTestPath = Join-Path -Path $myPath -ChildPath $f
        $myFileBackupPath = Join-Path -Path $myBackupPath -ChildPath $f
        $isFile = Test-Path -Path $myFileTestPath  -PathType Leaf
        If ($isFile -eq $true)
        {
            if ($Whatif -eq $true)
            {
                Write-Information('What-IF:Move from: ' + $myFileTestPath + ' to ' + $myFileBackupPath)
            }
            else
            {
                Move-Item -Path $myFileTestPath -Destination $myFileBackupPath
                Write-Information('Move from: ' + $myFileTestPath + ' to ' + $myFileBackupPath)
            }
        }
    }

    $del_files = Get-ChildItem -Path $myBackupPath | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays($removeDays) }


    foreach ($f in $del_files)
    {
        $myFileTestPath = Join-Path -Path $myBackupPath -ChildPath $f
        $isFile = Test-Path -Path $myFileTestPath  -PathType Leaf
        If ($isFile -eq $true)
        {
            if ($Whatif -eq $true)
            {
                Write-Information('Delete: ' + $myFileTestPath)
            }
            else
            {
                Remove-Item -Path $myFileTestPath
                Write-Information('Delete: ' + $myFileTestPath)
            }
        }
    }
}
