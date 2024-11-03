' DACL:  discretionary access control list

Set fs = CreateObject("Scripting.FileSystemObject")
strFileName = fs.GetAbsolutePathName(".")
strFileName = strFileName & "\<<Your File name.xxx>>"

strComputer = "." 

SE_DACL_PRESENT = &h4
ACCESS_ALLOWED_ACE_TYPE = &h0
ACCESS_DENIED_ACE_TYPE  = &h1

' Modify: 1245631, Write: 118009, Read only: 1179817
FILE_ALL_ACCESS       = &h1f01ff '2032127
FILE_APPEND_DATA      = &h000004
FILE_DELETE           = &h010000
FILE_DELETE_CHILD     = &h000040
FILE_EXECUTE          = &h000020
FILE_READ_ATTRIBUTES  = &h000080
FILE_READ_CONTROL     = &h020000
FILE_READ_DATA        = &h000001
FILE_READ_EA          = &h000008
FILE_SYNCHRONIZE      = &h100000
FILE_WRITE_ATTRIBUTES = &h000100
FILE_WRITE_DAC        = &h040000
FILE_WRITE_DATA       = &h000002
FILE_WRITE_EA         = &h000010
FILE_WRITE_OWNER      = &h080000

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set objFileSecuritySettings = objWMIService.Get("Win32_LogicalFileSecuritySetting='" & strFileName & "'")
intRetVal = objFileSecuritySettings.GetSecurityDescriptor(objSD)

intControlFlags = objSD.ControlFlags

' Retrieve the DACL array of Win32_ACE objects.
If intControlFlags AND SE_DACL_PRESENT Then
   arrACEs = objSD.DACL
   For Each objACE in arrACEs
      WScript.Echo objACE.Trustee.Domain & "\" & objACE.Trustee.Name
      If objACE.AceType = ACCESS_ALLOWED_ACE_TYPE Then
         WScript.Echo vbTab & "Allowed:"
      ElseIf objACE.AceType = ACCESS_DENIED_ACE_TYPE Then
         WScript.Echo vbTab & "Denied:"
      End If
      If objACE.AccessMask = FILE_ALL_ACCESS Then
         WScript.Echo vbTab & vbTab & "FILE_ALL_ACCESS "
      End If
      If objACE.AccessMask AND FILE_APPEND_DATA Then
         WScript.Echo vbTab & vbTab & "FILE_APPEND_DATA "
      End If
      If objACE.AccessMask AND FILE_DELETE Then
         WScript.Echo vbTab & vbTab & "FILE_DELETE "
      End If
      If objACE.AccessMask AND FILE_DELETE_CHILD Then
         WScript.Echo vbTab & vbTab & "FILE_DELETE_CHILD "
      End If
      If objACE.AccessMask AND FILE_EXECUTE Then
         WScript.Echo vbTab & vbTab & "FILE_EXECUTE "
      End If
      If objACE.AccessMask AND FILE_READ_ATTRIBUTES Then
         WScript.Echo vbTab & vbTab & "FILE_READ_ATTRIBUTES "
      End If
      If objACE.AccessMask AND FILE_READ_CONTROL Then
         WScript.Echo vbTab & vbTab & "FILE_READ_CONTROL "
      End If
      If objACE.AccessMask AND FILE_READ_DATA Then
         WScript.Echo vbTab & vbTab & "FILE_READ_DATA "
      End If
      If objACE.AccessMask AND FILE_READ_EA Then
         WScript.Echo vbTab & vbTab & "FILE_READ_EA "
      End If
      If objACE.AccessMask AND FILE_SYNCHRONIZE Then
         WScript.Echo vbTab & vbTab & "FILE_SYNCHRONIZE "
      End If
      If objACE.AccessMask AND FILE_WRITE_ATTRIBUTES Then
         WScript.Echo vbTab & vbTab & "FILE_WRITE_ATTRIBUTES "
      End If
      If objACE.AccessMask AND FILE_WRITE_DAC Then
         WScript.Echo vbTab & vbTab & "FILE_WRITE_DAC "
      End If
      If objACE.AccessMask AND FILE_WRITE_DATA Then
         WScript.Echo vbTab & vbTab & "FILE_WRITE_DATA "
      End If
      If objACE.AccessMask AND FILE_WRITE_EA Then
         WScript.Echo vbTab & vbTab & "FILE_WRITE_EA "
      End If
      If objACE.AccessMask AND FILE_WRITE_OWNER Then
         WScript.Echo vbTab & vbTab & "FILE_WRITE_OWNER "
      End If

   Next
Else
   WScript.Echo "No DACL present in security descriptor"
End If

