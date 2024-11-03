Set objLocalAccounts = GetObject("WinNT://.")

objLocalAccounts.Filter = Array("User")
For Each objUser In objLocalAccounts
    Wscript.Echo objUser.Name 
Next

objLocalAccounts.Filter = Array("Group")
For Each objGroup In objLocalAccounts
    Wscript.Echo objGroup.Name 
Next