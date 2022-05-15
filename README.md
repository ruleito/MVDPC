# MVDPC
search, disable, move pc 

Данный скрипт выбирает из каталога Active Directory компьютеры соответствующие по условию - последний логин более 45 дней ($date_with_offset) из атрибута LastLogonDate.

Создается логфайл - $logfile в формате MVDPC_05-15-2022-03-00.txt

В переменную массива ($PCname) складываются компьютеры соответствующие значению атрибута LastLogonDate из указанной OU -SearchBase "OU=Computers,OU=contoso,DC=org,DC=contoso,DC=com".

Перед началом работы цикла проверяется длинна массива >1  - имеются ПК подходящие условию $date_with_offset, если = 1, скрипт отправит в письме, что по условию не выявленны ПК.


# отправка email:
$From = "user@contoso.com"                                          # sender email

$To = "user@contoso.com"                                            # email TO 

$Attachment = $logfile                                              # add to email logfile

$Subject = "Logs move pc "                                          # plain text in email

$Body = "disabled pc on ad"                                         # text on body email

$SMTPServer = "mail.contoso.com"                                    # change your smtp server name 

$SMTPPort = "587"                                                   # change port on your smtp server

$encoding = [System.Text.Encoding]::UTF8                            # convert email encoding to UTF-8 
 

$mypasswd = ConvertTo-SecureString "Pa$$W0rD" -AsPlainText -Force   # get pass on email

$Cred = New-Object System.Management.Automation.PSCredential ("user@contoso.com", $mypasswd) # save cred sender 

Send-MailMessage -From $From -to $To -Subject $Subject -Bodyashtml -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Encoding $encoding  -Credential $Cred -Attachments $Attachment
