#!/bin/bash
#Brian Taniyama 2022
#Asset Tag Rename

#VARIABLES#

#Get Serial
serial=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
#Define SNow User/Pass safely in JAMF
API_USER="$4"
API_PASS="$5"
#Define Regular Expression for Asset Tag Number
re='^[0-9]+$'
#Create cURL URL
curl_url="https://unitedtalent.service-now.com/api/now/table/alm_hardware?sysparm_query=serial_number%3D${serial}&sysparm_fields=serial_number%2Casset_tag&sysparm_limit=1"

echo $curl_url

#END VARIABLES#

#API Call to SNow to get the Asset Tag
asset_num=$(
curl "$curl_url" \
--request GET \
--header "Accept:application/json" \
--user "$API_USER:$API_PASS"
)

echo $asset_num

asset=$(sed -e 's/.*asset_tag":"//'  -e 's/".*//' <<< $asset_num)

#Confirm the asset tag
echo  "ServiceNow reports the asset tag is $asset"

#If we receive anything other than a number, exit
if ! [[ $asset =~ $re ]] ; then
   echo "error: Asset tag is either not a number or blank" >&2; exit 1
fi

#Get new Comp name
comp_name="MAC-$asset"

echo Computer will be named $comp_name

#Change Computer Name Locally (apparently JAMF writes this back to the device now)
#scutil --set HostName $comp_name
#scutil --set LocalHostName $comp_name
#scutil --set ComputerName $comp_name

# Write to JAMF
/usr/local/bin/jamf setComputerName -name $comp_name
/usr/local/bin/jamf recon
#wait 15 seconds and recon again since the name change never takes on the first recon for some reason
sleep 15
/usr/local/bin/jamf recon

exit 0
