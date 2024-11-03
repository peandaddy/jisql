' Create a WScript.Network object
Set objNetwork = CreateObject("WScript.Network")
' Get the computer name
strComputer = objNetwork.ComputerName

Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Set colLoggedEvents = objWMIService.ExecQuery _
        ("Select * from Win32_NTLogEvent Where Logfile = 'System' and " & "EventCode = '3004'")

For Each objEvent in colLoggedEvents
    Wscript.Echo "Computer Name: " & objEvent.ComputerName
    Wscript.Echo "Event Code: " & objEvent.EventCode
    Wscript.Echo "Category: " & objEvent.Category
    Wscript.Echo "User: " & objEvent.User
    Wscript.Echo "Message: " & objEvent.Message
    Wscript.Echo "Source Name: " & objEvent.SourceName
    Wscript.Echo "Time Written: " & objEvent.TimeWritten
    Wscript.Echo "Event Type: " & objEvent.Type
Next