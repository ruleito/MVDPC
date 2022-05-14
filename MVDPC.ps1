$date_with_offset= (Get-Date).AddDays(-45) # time LastLogonDate
$logfile = ".\MVDPC_$(Get-Date -Format "MM-dd-yyyy-HH-mm").txt" # create text log file + date 
$PCname = @((Get-ADComputer -SearchBase "OU=Computers,OU=contoso,DC=org,DC=contoso,DC=com" -Filter {enabled -eq "true" -and OperatingSystem -Like '*Windows *' -and LastLogonDate -lt $date_with_offset } -Properties * ).DistinguishedName) # Get hash win pc on LastLogonDate 
$ActivePC = @() # empty hash active pc 
$empty_array = "array is empty"
if ($PCname.Length -ne 1) {            # if not empty array 
foreach ($pc in $PCname) {
    if ((Test-Connection -ComputerName $pc -Count 1 -Quiet).Equals($false)) {
        $logdate = (Get-ADComputer -Identity $pc -Properties *).LastLogonDate 
        $OSBuild = (Get-ADComputer -Identity $pc -Properties *).OperatingSystem
        Set-ADComputer $pc -Enabled $false
        $CheckPCDissable = (Get-ADComputer -Identity $pc -Properties *).Enabled 
        Move-ADObject -Identity $pc -TargetPath "OU=oldPc,DC=org,DC=almatel,DC=ru" -Verbose
        Write-Host -ForegroundColor Yellow  "$pc : $logdate : $OSBuild : $CheckPCDissable " 
        $HashData = @($pc,$OSBuild,$CheckPCDissable,$logdate) # collect variable in hash
        Add-Content -path $logfile -Value $HashData # send hash to logfile 
    }
    else {
        Write-Host -ForegroundColor White "$pc is active"
        $ActivePC.Add("$pc")
    }
}
}
else {       # if empty - send email with $empty_array
Add-Content -path $logfile -Value $empty_array # send hash to logfile
    }
# send email 

$From = "user@email.org"
$To = "user@email.org"
$Attachment = $logfile
$Subject = "Logs move pc "
$Body = "disabled pc on ad"
$SMTPServer = "mail.mail.com"  # change your smtp server name 
$SMTPPort = "587"  # change port on your smtp server
$encoding = [System.Text.Encoding]::UTF8
# save credential 
$mypasswd = ConvertTo-SecureString "*******" -AsPlainText -Force  # *******   - your password
$Cred = New-Object System.Management.Automation.PSCredential ("user@email.org", $mypasswd)

Send-MailMessage -From $From -to $To -Subject $Subject -Bodyashtml -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Encoding $encoding  -Credential $Cred -Attachments $Attachment
