#!/bin/bash
#Adapted for Goop by Brian Taniyama, 2019
#This Script will remove all accounts that are not
#specified below (e.g. Administrator, etc.)
#Accounts are case sensitive

currentuser=$(stat -f "%Su" /dev/console)
UserList=`ls /Users | grep -v "Shared" | grep -v -i "localadmin" | grep -v -i "$CurrentUser" | grep -v -i "Guest" | grep -v -i "arduser"`

if [[ "$currentuser" == "localadmin" ]]; then
	echo "We're in localadmin, something must've gone wrong, proceeding"
else
	echo "The user logged in is not the localadmin, we don't need to do anything"
	exit 0
fi

Dansarray=( $UserList )
#printf "%s\n" "${Dansarray[@]}"

if [ ${#Dansarray[@]} -eq 0 ]; 
    then
        echo "Nothing to do, exiting"
        exit 0
    else
        for u in ${Dansarray[@]} ; do
        	button=$(osascript -e 'tell app "System Events" to display dialog "Delete user folder '$u'?" buttons {"No", "Yes"}')
        	if [ "$button" == "button returned:No" ]; then
        		echo "No button pressed, skipping account deletion"
        		exit 0
        	else
        		echo "Yes button pressed, moving forward"
        	fi
            echo "$u -- Deleting..."
            `/usr/bin/dscl . delete /Users/$u && /bin/rm -rf /Users/$u`
        done
        #Remove sharepoints and groups
        find /private/var/db/dslocal/nodes/Default/sharepoints -name "*" -type f -delete
        find /private/var/db/dslocal/nodes/Default/groups -name "com.apple.sharepoint*" -type f -delete
fi