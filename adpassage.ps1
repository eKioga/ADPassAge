# By Eric Post
# This script queries Active Directory accounts in the Staff OU and makes a CSV report with the name, status, email address and EPOCH time columns.
# It does this by performing the following steps.
# 1. Generates the report in regular windows date time. 
# 2. Then it imports the same CSV file and runs the PasswordLastSet column through the EPOCH function.
# 3. Then it exports the results by over writing the original CSV file
# 4. Then it opens an SSH session with SERVERNAME and dumps the CSV file on "/home/winsvc/ADPassAge" so the emailer script on the Linux side can find it.

#Uncomment the start-transcript line below, and the stop-transcript line at the bottom for debugging.
#Start-Transcript -Path 'F:\scripts\tasks\ADPassAge\ADPassAge_debug.txt' 

# Step 1: 
get-aduser -filter * -properties passwordlastset, emailaddress -searchbase "OU=Staff,OU=COMPANY-HQ,DC=COMPANY,DC=LOCAL" |
  select name, enabled, emailaddress, passwordlastset |
   sort-object name |
    export-csv "F:\scripts\tasks\ADPassAge\ADPassAge.csv"

# Step 2:
Function ConvertTo-Epoch([datetime]$DateTime) {
    [int][double]::Parse((Get-Date ($DateTime).touniversaltime() -UFormat %s))
}

$replaced = Import-Csv -Path "F:\scripts\tasks\ADPassAge\ADPassAge.csv" | Select Name, Enabled, EmailAddress, @{N="PasswordLastSet";E={
    ConvertTo-Epoch -DateTime $_.PasswordLastSet
}}

# Step 3:
$replaced | Export-Csv -Path "F:\scripts\tasks\ADPassAge\ADPassAge.csv" -NoTypeInfo

# Step 4:
#If task scheduler mysteriously fails, uncomment the "Install-Module Posh-SSH" on the line below and run it once. If successfull, comment out the line again. It should now work without it.
#Install-Module Posh-SSH -Repository PSGallery -Verbose -Force
$computer = 'SERVERNAME'
$Credentials = [System.Management.Automation.PSCredential]::new("winsvc",[System.Security.SecureString]::new())
$keyfile  = 'F:\scripts\tasks\ADPassAge\identity\AD_Password_Script_Identity'

Set-SCPItem -ComputerName $computer -Credential $Credentials -KeyFile $keyfile -Path "F:\scripts\tasks\ADPassAge\ADPassAge.csv" -Destination /home/winsvc/ADPassAge

#Stop-Transcript