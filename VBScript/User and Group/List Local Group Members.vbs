Set objGroup = GetObject("WinNT://./Group1")

Wscript.Echo objGroup.Name 
For Each objUser in objGroup.Members
    Wscript.Echo vbTab & objUser.Name
Next
