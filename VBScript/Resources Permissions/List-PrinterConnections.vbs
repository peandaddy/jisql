' Create a WScript.Network object
Set objNetwork = CreateObject("WScript.Network")

' Enumerate printer connections
Set colPrinters = objNetwork.EnumPrinterConnections()

' Loop through the results and print the printer names and their corresponding ports
For i = 0 To colPrinters.Count - 1 Step 2
    WScript.Echo "Port: " & colPrinters.Item(i)
    WScript.Echo "Printer: " & colPrinters.Item(i + 1)
    WScript.Echo "-----------------------------------"
Next

'--------------------------------------
' 2nd method
'--------------------------------------
' Create a WScript.Network object
Set objNetwork = CreateObject("WScript.Network")
' Get the computer name
strComputer = objNetwork.ComputerName

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

Set colInstalledPrinters =  objWMIService.ExecQuery ("Select * from Win32_Printer")

For Each objPrinter in colInstalledPrinters
    Wscript.Echo "Name: " & objPrinter.Name
    Wscript.Echo "Location: " & objPrinter.Location
    Wscript.Echo "Default: " & objPrinter.Default
Next