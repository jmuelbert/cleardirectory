<#
    .SYNOPSIS
      Delete templorarly files in a directory after x days.

    .DESCRIPTION
      This cmdlet is usable to clear directories. It will remove files
      i.e. log-files after a adustable time.
      in the first step the file are moved to a backup directory. After the
      second wait time the file removed and waisted.

    .NOTES
      File Name : ClearDirectory
      Author    : Jürgen Mülbert - juergen.muelbert@gmail.com

    .LINK
      https://github.com/jmuelbert/cleardirectory
      License: https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12

    .EXAMPLE
      ClearDirectory -mypath C:\log -mybackuppath c:\backup -backupdays 30 -removedays 60
#>
Function Clear-Directory {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [alias("p")]
    [String]$myPath,

    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [alias("b")]
    [string]$myBackupPath,

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [alias("bd")]
    [int]$backupDays = -30,

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [alias("rd")]
    [int]$removeDays = -60,

    [switch]$Whatif
  )

  if (!(Get-Module PoShLog)) {
    ## Or check for the cmdlets you need
    ## Load it nested, and we'll automatically remove it during clean up
    Install-Module -Name PoShLog -Scope CurrentUser
  }


  $TempFile = Join-Path -Path  $ENV:TEMP -ChildPath "CleanDirectory.log"

  # Second options, specify multiple custom settings for the logger
  Start-ScriptLogger -Path $TempFile -Format '{0:yyyy-MM-dd}   {0:HH:mm:ss}   {1}   {2}   {3,-11}   {4}' -Level Warning -Encoding 'UTF8' -NoEventLog -NoConsoleOutput

  If ($backupDays -gt 0) {
    $backupDays = 0 - $backupDays
  }


  if ($removeDays -gt 0) {
    $removeDays = 0 - $removeDays
  }


  $files = Get-ChildItem -Path $myPath | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays($backupDays) }

  foreach ($f in $files) {
    $myFileTestPath = Join-Path -Path $myPath -ChildPath $f
    $myFileBackupPath = Join-Path -Path $myBackupPath -ChildPath $f
    $isFile = Test-Path -Path $myFileTestPath  -PathType Leaf
    If ($isFile -eq $true) {
      if ($Whatif -eq $true) {
        Write-InfoLog 'What-IF:Move from: {@from} to {@to}' -PropertyValues $myPath, $myFileBackupPath
      }
      else {
        Move-Item -Path $myFileTestPath -Destination $myFileBackupPath
        Write-InfoLog 'Move from: {@from} to {@to}' -PropertyValues $myFileTestPath, $myFileBackupPath
      }
    }
  }

  $del_files = Get-ChildItem -Path $myBackupPath | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays($removeDays) }


  foreach ($f in $del_files) {
    $myFileTestPath = Join-Path -Path $myBackupPath -ChildPath $f
    $isFile = Test-Path -Path $myFileTestPath  -PathType Leaf
    If ($isFile -eq $true) {
      if ($Whatif -eq $true) {
        Write-InfoLog 'WhatIF: Delete: {@FilePath}' -PropertyValues $myFileTestPath
      }
      else {
        Remove-Item -Path $myFileTestPath
        Write-Information 'Delete: {@FilePath}' -PropertyValues $myFileTestPath
      }
    }
  }
}
