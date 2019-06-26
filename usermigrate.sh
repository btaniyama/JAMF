#!/bin/bash
# Brian Taniyama, 2019
# Change Username to match AD Username

#Gather our usernames
currentuser=$(stat -f "%Su" /dev/console)
currentUID=$(id -u $currentuser)
olduser=$(osascript -e 'set T to text returned of (display dialog "Enter the CURRENT short username of the user we are trying to change" with icon caution buttons {"Cancel","OK"} default button "OK" default answer "")')
newuser=$(osascript -e 'set T to text returned of (display dialog "Enter the AD username of the user we are trying to change" with icon caution buttons {"Cancel","OK"} default button "OK" default answer "")')
button=$(osascript -e 'display dialog "Confirm that we are going to rename the user account '$olduser' to '$newuser?'" buttons {"No","Yes"} default button "Yes"')

#Double checking that we're acting on the right user
if [ "$button" == "button returned:No" ]; then
	echo "Button returned no, aborting..."
	exit 1
else
	echo "Button returned yes, moving forward"
fi

#Triple check, make sure the user actually exists
if id "$olduser" >/dev/null 2>&1; then
        echo "User exists"
else
        echo "User "$olduser" does not exist"
        osascript -e 'display dialog "Username '$olduser' does not exist, check your spelling and try to run again."'
		exit 1
fi

#Confirming that the logged in user is not the user we're changing
if [ "$currentuser" == "$olduser" ]; then
	echo "We can't run this on the current user, informing user"
	osascript -e 'display dialog "You cant run this process in this user account, log in to localadmin to run this policy!"'
	exit 1
else
	echo "$currentuser is logged in, not $olduser, moving forward"
	dscl . -change /Users/$olduser RecordName $olduser $newuser
	mv /Users/$olduser /Users/$newuser && chown -R "$newuser" /Users/$newuser
	/usr/sbin/sysadminctl -deleteUser $newuser -keepHome
fi

#This file will prevent DEPNotify assets (we don't need them) from being installed. Also puts them in a "Account Migration Script Run" Smart Group
#Account Migration Run Smart Group scopes a policy to remove NoLoAD after next login
touch /Library/Application\ Support/JAMF/Receipts/nodepnotify.pkg

# Update the endUsername in the JSS
/usr/local/bin/jamf recon -endUsername $newuser

# Finish up
osascript -e 'display dialog "Username has been migrated. NoMAD assets being installed now. Machine will restart after installation. Log in as user and sign in to NoMAD to complete migration."'

exit 0
