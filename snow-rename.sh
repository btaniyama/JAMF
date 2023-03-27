#!/bin/bash
#Brian Taniyama 2022
#Asset Tag Rename

#VARIABLES#

#Get Serial
serial=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
#Define SNow Username safely in JAMF
SN_U=$4
#Define SNow PW safely in JAMF
SN_P=$5
#Define Regular Expression for Asset Tag Number
re='^[0-9]+$'
#Create cURL URL
curl_url="https://xxxx.service-now.com/api/now/table/alm_hardware?sysparm_query=serial_number%3D${serial}&sysparm_fields=serial_number%2Casset_tag&sysparm_limit=1"

#END VARIABLES#

#API Call to SNow to get the Asset Tag
asset=$(
curl "$curl_url" \
--request GET \
--header "Accept:application/json" \
--user '$SN_U':'$SN_P' | sed -e 's/.*asset_tag":"//'  -e 's/".*//'
)

#If we receive anything other than a number rename to Serial Number then exit as failed
if ! [[ $asset =~ $re ]] ; then
   /usr/local/bin/jamf setComputerName -name $serial 
   echo "error: Asset tag is either not a number or blank, this computer has been named $serial" >&2; exit 1
fi

#Confirm the asset tag
echo  "ServiceNow reports the asset tag is $asset"

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
wait 15
/usr/local/bin/jamf recon

exit 0
