
If(-not(Test-Path -Path "T:\")) {
	$connectTestResult = Test-NetConnection -ComputerName STORAGE_ACCOUNT_NAME.file.core.windows.net -Port 445

	if ($connectTestResult.TcpTestSucceeded) {
		# Save the password so the drive will persist on reboot
		cmd.exe /C "cmdkey /add:`"STORAGE_ACCOUNT_NAME.file.core.windows.net`" /user:`"localhost\STORAGE_ACCOUNT_NAME`" /pass:`"LONG_PASSWORD`""

		# Mount the drive
		New-PSDrive -Name T -PSProvider FileSystem -Root \\STORAGE_ACCOUNT_NAME.file.core.windows.net\SHARE_NAME -Persist

	} 
	else {
		Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
	}
}
else {
	Write-Host "Already connected."
}