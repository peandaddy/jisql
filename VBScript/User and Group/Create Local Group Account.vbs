Set objLocalAccounts = GetObject("WinNT://.")

Set objGroup = objLocalAccounts.Create("group", "Group1")
objGroup.SetInfo

