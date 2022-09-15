# ADPassAge (Active Directory Password Age) Script
This powershell script queries Active Directory accounts in the Staff OU and makes a CSV report with the name, status, email address and EPOCH time columns.
It does this by performing the following steps.
1. Generates the report in regular windows date time. 
2. Then it imports the same CSV file and runs the PasswordLastSet column through the EPOCH function.
3. Then it exports the results by over writing the original CSV file
4. Then it opens an SSH session with SERVERNAME and dumps the CSV file on "/home/winsvc/ADPassAge" so the emailer script on the Linux side can find it.

## Bonus Features
Included in the comments is code for debugging errors and installing any dependencies. All you need to do is uncomment those lines and you'll be all set. instructions included in comments. :)

## Why does this exist?
I wrote this odd script to solve a common problem with some unique contraints. I'm rather proud that I actualy got it working. My company needed to be PCI complient to work with a few larger clients. Executive leadership decided that going from basicaly zero password policy to having to reset thier passwords every 90 days would be too jarring. The compromise was to send out email notifications several weeks ahead of time warning the users. Where it gets a bit unique was when I was told that I needed to use the current Linux admin's perl scripts to fire off the emails themselves.

I knew I could simply use powershell to email the users, that would be the easy way. Plenty of info out there on how to do that. However, I found the challenge of passing Active Directory data securly over to a Linux box, and then formating it in a way that the current cronjob emailer scripts can natively read it out of the box to be very fun to learn.
