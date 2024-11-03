strComputer   = "."
strShareName  = "<<Share Folder Name>>"

Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set objSecuritySettings=objWMIService.Get("Win32_LogicalShareSecuritySetting='" & strShareName & "'")

' Retrieve the DACL array of Win32_ACE objects.
objSecuritySettings.GetSecurityDescriptor objSD
colACEs = objSD.DACL

For each objItem in colACEs
	Set objTrustee = objItem.Trustee
	WScript.echo objTrustee.Domain & "\" & objTrustee.Name
	If objItem.AceType=0 Then
		WScript.echo vbTab & "Permit:" & CAccessMask(objItem.AccessMask)
	else
		WScript.echo vbTab & "Reject:" & CAccessMask(objItem.AccessMask)
	End If
Next

' &H: Indicate Hex number
Function CAccessMask(AccessMask)
Select Case AccessMask
	Case &H1F01FF
		CAccessMask="All ACCESS"
	Case &H1301BF
		CAccessMask="Modify"
	Case &H1200A9
		CAccessMask="Read Only"
    Case &H1CCF9
		CAccessMask="Write Only"
	Case ELSE
		CAccessMask="Unknown"
End Select
END Function