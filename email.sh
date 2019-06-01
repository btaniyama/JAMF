#!/bin/bash
#Brian Taniyama 2019
#Grab Username via JAMF API

#Get logged in user
loggedInUser=$( ls -l /dev/console | awk '{print $3}' )

#set up email capture
while [ "$button" != "button returned:Yes" ]
do
	# Prompt User to enter email address
	email=$(osascript -e 'set T to text returned of (display dialog "Hi! The IT Team needs to update some information on your computer. Can you confirm your email address?" with icon caution buttons {"Cancel","OK"} default button "OK" default answer "")')

	#Confirm the email is correct
	button=$(osascript -e 'tell app "System Events" to display dialog "You entered '$email', is this correct?" buttons {"No", "Yes"}')
	if [ "$button" == "button returned:No" ]; then
		echo "Button Returned No" 
	else
		echo "Button Returned Yes"
	fi	
done

#Remove trailing substring
newUser=${email%%@*}

#Now that we have the username, let's create the LaunchDaemon
cat << EOF > /Library/LaunchDaemons/com.goop.rename.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>goop.rename</string>
	<key>Program</key>
	<string>/usr/local/bin/rename.sh</string>
	<key>RunAtLoad</key>
	<true/>
	<key>LaunchOnlyOnce</key>        
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/startup.stdout</string>
    <key>StandardErrorPath</key>
    <string>/tmp/startup.stderr</string>
</dict>
</plist>
EOF

chmod 644 /Library/LaunchDaemons/com.goop.rename.plist
chown root:wheel /Library/LaunchDaemons/com.goop.rename.plist
sudo launchctl load -w /Library/LaunchDaemons/com.goop.rename.plist
echo "LaunchDaemon script created in /Library/LaunchDaemons/"

#Create the rename script
cat << EOF > /usr/local/bin/rename.sh
#!/bin/bash
#Brian Taniyama 2019

currentUser=$(stat -f %Su "/dev/console")
echo $currentUser

if [[ "$currentUser" == "root" ]]; then
	echo "No User is logged in, moving forward"
	dscl . change /Users/$loggedInUser RecordName $loggedInUser $newUser
	sudo mv /Users/$loggedInUser /Users/$newUser
	sudo chown -R "$newUser" /Users/$newUser
else
	echo "There must be someone logged in, aborting" && exit 0
fi
#Confirm changes
if [ -d "/Users/$newUser" ]; then
	echo "Change successful, cleaning up"
	sudo launchctl unload -w /Library/LaunchDaemons/com.goop.rename.plist
	rm -rf /Library/LaunchDaemons/com.goop.rename.plist
	rm -- "$0"
else
	echo "Something's not right" && exit 1
fi

exit 0

EOF

chmod 777 /usr/local/bin/rename.sh
chown root:wheel /usr/local/bin/rename.sh
echo "Rename script created in /usr/local/bin"

exit 0