#!/bin/sh
## postinstall

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3

/usr/sbin/installer -dumplog -verbose -pkg "/Library/goop/Assets/NoMAD.pkg" -target /
echo "NoMAD Installed"
/usr/sbin/installer -dumplog -verbose -pkg "/Library/goop/Assets/NoMAD-LaunchAgent.pkg" -target /
echo "NoMAD Launch Agent Installed"
/usr/sbin/installer -dumplog -verbose -pkg "/Library/goop/Assets/DEPNotify-1.1.4.pkg" -target /
echo "DEPNotify Installed"
/usr/sbin/installer -dumplog -verbose -pkg "/Library/goop/Assets/NoMAD-Login-AD.pkg" -target /
echo "NoMAD-Login-AD installed"

sudo defaults write /Library/Preferences/menu.nomad.login.ad ADDomain goop.biz

cat << EOF > /Library/LaunchDaemons/com.depnotify.launch.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>GroupName</key>
	<string>wheel</string>
	<key>InitGroups</key>
	<false/>
	<key>Label</key>
	<string>com.depnotify.launch</string>
	<key>Program</key>
	<string>/var/tmp/launchDEPNotify.sh</string>
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer>10</integer>
	<key>UserName</key>
	<string>root</string>
	<key>StandardErrorPath</key>
	<string>/var/tmp/depnotify.launch.err</string>
	<key>StandardOutPath</key>
	<string>/var/tmp/depnotify.launch.out</string>
</dict>
</plist>
EOF

chmod 644 /Library/LaunchDaemons/com.depnotify.launch.plist
chown root:wheel /Library/LaunchDaemons/com.depnotify.launch.plist

/bin/launchctl load -w /Library/LaunchDaemons/com.depnotify.launch.plist


exit 0		## Success
exit 1		## Failure