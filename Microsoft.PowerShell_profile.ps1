# Set the location to start in
Set-Location C:\

# Customize the powershell GUI
$host.ui.RawUI.WindowTitle="ShellPower"
$host.ui.RawUI.BackgroundColor="DarkCyan"
$host.ui.RawUI.ForegroundColor="DarkYellow"
Clear-Host

# List of modules to import
Import-Module PsGet
Import-Module posh-gvm

# Welcome message
"You are now entering PowerShell : " + $env:Username
