Set objUser = GetObject("WinNT://./user1")
objUser.AccountDisabled = False
objUser.SetInfo
