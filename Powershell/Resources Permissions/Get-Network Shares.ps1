<#
Here's the equivalent PowerShell script for listing network shares:

Use Get-WmiObject to query for network shares.
Loop through the results and print the share names, paths, and descriptions.

Make sure to set the execution policy to allow running scripts if it is not already set:
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#>
# Get the computer name
$computerName = $env:COMPUTERNAME

# Query for network shares
$shares = Get-WmiObject -Class Win32_Share -ComputerName $computerName

# Loop through the results and print the share names, paths, and descriptions
foreach ($share in $shares) {
    Write-Output "Share Name: $($share.Name)"
    Write-Output "Path: $($share.Path)"
    Write-Output "Description: $($share.Description)"
    Write-Output "-----------------------------------"
}