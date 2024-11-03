Set objLocalAccounts = GetObject("WinNT://.")

Set objUser = objLocalAccounts.Create("user", "user1")
objUser.SetPassword "P@ssw0rd123"
objUser.SetInfo

Set objUser = objLocalAccounts.Create("user", "user2")
objUser.SetPassword "P@ssw0rd123"
objUser.SetInfo