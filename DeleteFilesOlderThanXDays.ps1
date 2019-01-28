$scriptVersion = "1.1"
#http://www.lazyexchangeadmin.com/2016/09/DeleteFilesOlderThanXDays.html
#Region Variables
	$today = '{0:dd/MMM/yyyy hh:mm tt}' -f (Get-Date)
	$script_root = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
	$debugLog = @()
	$debugLog += $today
	$debugLogFile = ($script_root + "\DeleteLog.txt")
	$DirList = get-content ($script_root + "\DirList.txt")
	$deleteLogCSVFile = ($script_root + "\DeleteLog.csv")
	#Change this value to your preferred number of days (in negative)
	$HowManyDaysOld = "-0"
	#Change boolean value to whether you want to receive an email report or not
	$SendEmail = $false	
	$DatetoDelete = (Get-Date).AddDays($HowManyDaysOld)
#EndRegion

$resultLog = @()
foreach ($dirPath in $DirList) {

	#Write-Host $dirPath -ForegroundColor Green
	$logFiles = Get-ChildItem $dirPath -File | Where-Object { $_.LastWriteTime -lt $DatetoDelete }
	
	if (($logFiles.Count) -gt 0) {
	
		foreach ($logFile in $logFiles) {
		$temp = "" | Select-Object FileName,Successful
		
		$debugLog += ($logFile.FullName)
		$temp.FileName = $logFile.FullName

		try {
			Write-Host "Delete $($logFile.FullName).. " -ForegroundColor Green -NoNewline
			Remove-Item -Path ($logFile.FullName) -Force -Confirm:$false -ErrorAction Stop
			$temp.Successful = $true
			Write-Host "Success" -ForegroundColor Green
		}
		catch {
			Write-Host "Failed" -ForegroundColor Red
			$temp.Successful = $false
		}
			$resultLog += $temp
		}
	}	
}
$resultLog | Export-Csv -NoTypeInformation $deleteLogCSVFile
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
		Attachment = $deleteLogCSVFile
		}
	Send-MailMessage @params
}
#EndRegion
