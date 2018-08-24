$scriptVersion = "1.0"
#http://www.lazyexchangeadmin.com/2016/09/DeleteFilesOlderThanXDays.html
#Region Variables
	$today = '{0:dd/MMM/yyyy hh:mm tt}' -f (Get-Date)
	$script_root = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
	$debugLog = @()
	$debugLog += $today
	$debugLogFile = ($script_root + "\DeleteLog.txt")
	$DirList = gc ($script_root + "\DirList.txt")
	
	#Change this value to your preferred number of days (in negative)
	$HowManyDaysOld = "-15"
	#Change boolean value to whether you want to receive an email report or not
	$SendEmail = $true
	
	$DatetoDelete = (Get-Date).AddDays($HowManyDaysOld)
#EndRegion

foreach ($dirPath in $DirList) {

	#Write-Host $dirPath -ForegroundColor Green
	$logFiles = Get-ChildItem $dirPath | Where-Object { $_.LastWriteTime -lt $DatetoDelete }
	
	if (($logFiles.Count) -gt 0) {
	
		foreach ($logFile in $logFiles) {
		
		Write-Host "Delete $($logFile.FullName)" -ForegroundColor Green
		$debugLog += ($logFile.FullName)
		Remove-Item -Path ($logFile.FullName) -Force -ErrorAction SilentlyContinue
		}
	}	
}

$debugLog | Out-File $debugLogFile

#Region Mail
if ($SendEmail -eq $true) {
	$mail_body = "Deleted IIS Logs older than [$($HowManyDaysOld)] days"
	$params = @{
		Body = $mail_body
		BodyAsHtml = $false
		Subject = "IIS Logs Maintenance $($today)"
		From = "PostMaster <Exchange-Admin@domain.com>"
		To = "someone@domain.com"
		SmtpServer = "smtp.server.here"
		Attachment = $debugLogFile	
		}
	Send-MailMessage @params
}
#EndRegion
