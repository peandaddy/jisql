Const JOIN_DOMAIN             = 1
Const ACCT_CREATE             = 2
Const ACCT_DELETE             = 4

strComputer = "172.x.x.x"

strDomain   = "consoto.local"
strPassword = "P@ssw0rd123"
strUser     = "<<domain join account>>"

set objWMIService = GetObject("winmgmts:{impersonationLevel=Impersonate,authenticationLevel=pktPrivacy}!\\" & strComputer & "\root\cimv2")

Set colComputers = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem")

For Each objComputer in colComputers 
	WScript.Echo objComputer.name
	ReturnValue = objComputer.JoinDomainOrWorkGroup _
		(strDomain, strPassword, strDomain & "\" & strUser, NULL, JOIN_DOMAIN + ACCT_CREATE)
Next


Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate,(Shutdown)}!\\" & strComputer & "\root\cimv2")

Set colOperatingSystems = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
For Each objOperatingSystem in colOperatingSystems
    ObjOperatingSystem.Reboot()
Next
