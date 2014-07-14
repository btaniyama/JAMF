#!/bin/sh

#################################################################
## Filename: adobecc.sh
## Author: Brian Taniyama, originally by Jared Nichols
##2014
## Purpose: Send an email to the help desk to generate a ticket for a VM install
#################################################################

# we want the computer name
hostname=`jamf getComputerName | sed -e 's/<computer_name>//' -e 's/<\/\computer_name>//'`
jssID=`jamf recon -skipApps -skipFonts -skipPlugins | grep computer_id | sed -e 's/<computer_id>//' -e 's/<\/\computer_id>//'`
user=`ls -l /dev/console | cut -d " " -f 4`
b='@onekingslane.com'
c=$user$b

# set the message we are going to send
message1="I would like to have Adobe Creative Cloud on my Mac.  My Mac's system name is:  "

# set the destination address
email=btaniyama@onekingslane.com

echo "#tags adobecc selfservice \n ***This is an automatically generated message*** \n $message1$hostname \n My logged in user is $user and my JSS ID is $jssID \n" | mail -s "Adobe Creative Cloud Request" $email -f $c

/Applications/Utilities/CocoaDialog.app/Contents/MacOS/CocoaDialog ok-msgbox  --no-cancel --title "Thank You" --text  "Your request has been received by IT."

exit 0