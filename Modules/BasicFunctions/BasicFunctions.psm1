<#
These are basic functions that save keystrokes when 
navigating in PowerShell. Most of the scripts bring back 
system information which may be cumbersome to look up
in Windows Explorer.
#>


<#
   .Synopsis
     Looks for the module path folder, copies module files to folder
   .Description
     This script looks for the module path folderon either xp family
     or vista family computer. if the module folder is missing, it 
     will create it. It then copies the module files into the folder.
     When copying new module files, it creates a parent folder for each
     new module as required by the module architecture. 
   .Example
     Copy-Modules.ps1 -Path c:\fso
     This command checks for existence of module folder and copies
     all module files from the c:\fso directory into their own folder
     in the users modules directory. 
   .Inputs
     [String]
   .OutPuts
     [System.Io.DirectoryInfo]
   .Notes
    NAME:      Copy-Modules.ps1
    AUTHOR:    ed wilson 
    LASTEDIT:  4/12/2009
    KEYWORDS:  modules, test-path, new-item, environment
               PowerShell Best Practices
   .Link
     Test-Path
     New-Item
     Get-WmiObject
     Http://www.ScriptingGuys.com
#Requires -Version 2.0
#>
[CmdletBinding()]
Param(
      [Parameter(Position=0,
      Mandatory=$True,
      ValueFromPipeline=$True)]
      [string]$path
     )
      
Function Get-OperatingSystemVersion
{
 (Get-WmiObject -Class Win32_OperatingSystem).Version
} #end Get-OperatingSystemVersion

Function Test-ModulePath
{
 $VistaPath = "$env:userProfile\documents\WindowsPowerShell\Modules"
 $XPPath =  "$env:Userprofile\my documents\WindowsPowerShell\Modules" 
 if ([int](Get-OperatingSystemVersion).substring(0,1) -ge 6) 
   { 
     if(-not(Test-Path -path $VistaPath))
       {
         New-Item -Path $VistaPath -itemtype directory | Out-Null
       } #end if
   } #end if
 Else 
   {  
     if(-not(Test-Path -path $XPPath))
       {
         New-Item -path $XPPath -itemtype directory | Out-Null
       } #end if
   } #end else
} #end Test-ModulePath

Function Copy-Module([string]$name)
{
 $UserPath = $env:PSModulePath.split(";")[0]
 $ModulePath = Join-Path -path $userPath `
               -childpath (Get-Item -path $name).basename
 If(-not(Test-Path -path $modulePath))
   {
    New-Item -path $modulePath -itemtype directory | Out-Null
    Copy-item -path $name -destination $ModulePath | Out-Null
   }
 Else
   { 
    Copy-item -path $name -destination $ModulePath | Out-Null
   }
}

# *** Entry Point to Script *** 
Test-ModulePath
Get-ChildItem -Path $path -Include *.psm1,*.psd1 -Recurse |
Foreach-Object { Copy-Module -name $_.fullName }

function Get-OptimalSize
{
 <#
  .Synopsis
    Converts Bytes into the appropriate unit of measure. 
   .Description
    The Get-OptimalSize function converts bytes into the appropriate unit of 
    measure. It returns a string representation of the number.
   .Example
    Get-OptimalSize 1025
    Converts 1025 bytes to 1.00 KiloBytes
    .Example
    Get-OptimalSize -sizeInBytes 10099999 
    Converts 10099999 bytes to 9.63 MegaBytes
   .Parameter SizeInBytes
    The size in bytes to be converted
   .Inputs
    [int64]
   .OutPuts
    [string]
   .Notes
    NAME:  Get-OptimalSize
    AUTHOR: Ed Wilson
    LASTEDIT: 1/4/2010
    KEYWORDS:
   .Link
     Http://www.ScriptingGuys.com
 #Requires -Version 2.0
 #>
[CmdletBinding()]
param(
      [Parameter(Mandatory = $true,Position = 0,valueFromPipeline=$true)]
      [int64]
      $sizeInBytes
) #end param
 Switch ($sizeInBytes) 
  {
   {$sizeInBytes -ge 1TB} {"{0:n2}" -f  ($sizeInBytes/1TB) + " TeraBytes";break}
   {$sizeInBytes -ge 1GB} {"{0:n2}" -f  ($sizeInBytes/1GB) + " GigaBytes";break}
   {$sizeInBytes -ge 1MB} {"{0:n2}" -f  ($sizeInBytes/1MB) + " MegaBytes";break}
   {$sizeInBytes -ge 1KB} {"{0:n2}" -f  ($sizeInBytes/1KB) + " KiloBytes";break}
   Default { "{0:n2}" -f $sizeInBytes + " Bytes" }
  } #end switch
  $sizeInBytes = $null
} #end Function Get-OptimalSize 

function Get-ComputerInfo
{
 <#
  .Synopsis
    Retrieves basic information about a computer. 
   .Description
    The Get-ComputerInfo cmdlet retrieves basic information such as
    computer name, domain name, and currently logged on user from
    a local or remote computer.
   .Example
    Get-ComputerInfo 
    Returns comptuer name, domain name and currently logged on user
    from local computer.
    .Example
    Get-ComputerInfo -computer berlin
    Returns comptuer name, domain name and currently logged on user
    from remote computer named berlin.
   .Parameter Computer
    Name of remote computer to retrieve information from
   .Inputs
    [string]
   .OutPuts
    [object]
   .Notes
    NAME:  Get-ComputerInfo
    AUTHOR: Ed Wilson
    LASTEDIT: 1/11/2010
    KEYWORDS:
   .Link
     Http://www.ScriptingGuys.com
 #Requires -Version 2.0
 #>
 Param([string]$computer="localhost")
 $wmi = Get-WmiObject -Class win32_computersystem -ComputerName $computer
 $pcinfo = New-Object -TypeName system.object
 $pcInfo | Add-Member -MemberType noteproperty -Name host -Value $($wmi.DNSHostname)
 $pcInfo | Add-Member -MemberType noteproperty -Name domain -Value $($wmi.Domain)
 $pcInfo | Add-Member -MemberType noteproperty -Name user -Value $($wmi.Username)
 $pcInfo
}

function Get-ProductKey {
 <#
  .Synopsis
    Retrieves Formatted Registry Key. 
   .Description
    The Get-ProductKey cmdlet retrieves the windows product key from the registry and returns the value 
    in a readable format.
   .Notes
    NAME:  Get-ProductKey
    AUTHOR: Nathan Maynes
    LASTEDIT: 1/27/2016
    KEYWORDS:
 #Requires -Version 2.0
 #>
$map = "BCDEFGHJKMPQRTVWXY2346789"
$value = (get-itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").digitalproductid[0x34..0x42] 
$ProductKey = ""
for ($i = 24; $i -ge 0; $i--) { 
      $r = 0 
      for ($j = 14; $j -ge 0; $j--) { 
        $r = ($r * 256) -bxor $value[$j] 
        $value[$j] = [math]::Floor([double]($r/24)) 
        $r = $r % 24 
      } 
      $ProductKey = $map[$r] + $ProductKey 
      if (($i % 5) -eq 0 -and $i -ne 0) { 
        $ProductKey = "-" + $ProductKey 
      } 
    } 
    $ProductKey
}

function Get-Foldersize
{
 <#
  .Synopsis
    Retrieves basic information about a computer. 
   .Description
    The Get-Foldersize cmdlet displays the size of a folder recursively in MB.
    Be careful when using in high level folders. It can take quite a bit of time.
   .Example
    Get-Foldersize 
    Returns the current directory size with all child folders.
    .Example
    Get-Foldersize
    Returns the current directory size with recursive search.
   .Notes
    NAME:  Get-Foldersize
    AUTHOR: Nathan Maynes
    LASTEDIT: 1/26/2016
 #Requires -Version 2.0
 #>

 $startFolder = (Get-Item -Path ".\" -Verbose).FullName

 $colItems = (Get-ChildItem $startFolder | Measure-Object -property length -sum)
 "$startFolder -- " + "{0:N2}" -f ($colItems.sum / 1MB) + " MB"

 $colItems = (Get-ChildItem $startFolder -recurse | Where-Object {$_.PSIsContainer -eq $True} | Sort-Object)
 foreach ($i in $colItems)
    {
        $subFolderItems = (Get-ChildItem $i.FullName | Measure-Object -property length -sum)
        $i.FullName + " -- " + "{0:N2}" -f ($subFolderItems.sum / 1MB) + " MB"
    }

    $colItems
} #end Function Get-Foldersize
