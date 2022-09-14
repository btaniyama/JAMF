#!/bin/bash
#Brian Taniyama 2022
#If Slack has an App Store Receipt, it should show up in the $slack variable. If not, it will be blank and means it was installed standalone.

#VARIABLES#
path="/Applications/Slack.app"
slack=$(mdfind -onlyin /Applications/ -name "kMDItemAppStoreHasReceipt = 1 && kMDItemKind = Application" | grep "Slack")
#END VARIABLES#

if [[ "$slack" == "$path" ]]; then
	echo "<result>App Store</result>"
else
	echo "<result>Standalone</result>"
fi
