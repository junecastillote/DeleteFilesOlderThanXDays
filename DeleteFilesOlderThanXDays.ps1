#http://shaking-off-the-cobwebs.blogspot.com/2016/09/DeleteFilesOlderThanXDays.html

#Region Variables
	$today = '{0:dd/MMM/yyyy hh:mm tt}' -f (Get-Date)
	$script_root = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
	$debugLog = @()
	$debugLog += $today
	$debugLogFile = ($script_root + "\DeleteLog.txt")
	$DirList = gc ($script_root + "\DirList.txt")
	$HowManyDaysOld = "-15"
	$DatetoDelete = (Get-Date).AddDays($HowManyDaysOld)
	$SendEmail = $true
#EndRegion

foreach ($dirPath in $DirList) {

	#Write-Host $dirPath -ForegroundColor Green
	$logFiles = Get-ChildItem $dirPath | Where-Object { $_.LastWriteTime -lt $DatetoDelete }
	
	if (($logFiles.Count) -gt 0) {
	
		foreach ($logFile in $logFiles) {
		
		Write-Host "Delete $($logFile.FullName)" -ForegroundColor Green
		$debugLog += ($logFile.FullName)
		Remove-Item -Path ($logFile.FullName) -Force
		}
	}	
}

$debugLog | Out-File $debugLogFile

#Region

$mail_body = "Deleted IIS Logs older than [$($HowManyDaysOld)] days"
$params = @{
    Body = $mail_body
    BodyAsHtml = $false
    Subject = "MMG IIS Logs Maintenance $($today)"
    From = "MMG PostMaster <Exchange-Admin@mmg.com>"
	To = "gcp.messaging.exchangets@hpe.com"
    SmtpServer = "cust11646-s.out.mailcontrol.com"
	Attachment = $debugLogFile
	
}

Send-MailMessage @params