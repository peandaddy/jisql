' Create a FileSystemObject
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Create a WScript.Network object
Set objNetwork = CreateObject("WScript.Network")

' Get the computer name
strComputer = objNetwork.ComputerName

' Connect to WMI service
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

' Execute the query to get network shares
Set colShares = objWMIService.ExecQuery("SELECT * FROM Win32_Share")

' Loop through the results and print the share names
For Each objShare in colShares
    WScript.Echo "Share Name: " & objShare.Name
    WScript.Echo "Path: " & objShare.Path
    Wscript.Echo "Type: " & objShare.Type
    Wscript.Echo "Allow Maximum: " & objShare.AllowMaximum
    Wscript.Echo "Maximum Allowed: " & objShare.MaximumAllowed
    WScript.Echo "Description: " & objShare.Description
    WScript.Echo "-----------------------------------"
Next