#!/bin/bash
#Brian Taniyama 2019
#Rename/Unbind/Rebind

#Get Serial
serial=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
#Get Logged in User 
user=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
#Define Prefix
prefix='G-'
#Create Asset Name
asset="$prefix$serial"
#Domain
domain="goop.biz"
# Check the domain returned with dsconfigad
olddomain=$(dsconfigad -show | awk '/Active Directory Domain/{print $NF}')
#ping the Domain
ping -c 3 -o rdgw.goop.biz 1> /dev/null 2> /dev/null

if [[ $? == 0 ]]; then
	echo "This machine is on the Goop network"
	if [[ "${olddomain}" == "${domain}" ]]; then 
		echo "This machine is bound to AD. Unbinding"
		#Unbind from AD
		dsconfigad -force -remove -username $5 -password $6
		#re-check domains
		recheckdomain=$(dsconfigad -show | awk '/Active Directory Domain/{print $NF}')
		if [[ "${recheckdomain}" == "${domain}" ]]; then 
			echo "Unbind failed, exiting..."
			exit 1
		else
			echo "Unbind Successsful, Renaming Machine"
			sudo scutil --set HostName $asset
			echo "HostName set to $asset"
			sudo scutil --set LocalHostName $user
			echo "LocalHostName set to $user"
			sudo scutil --set ComputerName $asset
			echo "ComputerName set to $user"
			#Flush Cache
			dscacheutil -flushcache
			#Rebind using policy in JAMF
			/usr/local/bin/jamf policy -event "adbind"
			#confirm bind one last time
			if [[ "${olddomain}" == "${domain}" ]]; then
				echo "Rebind Complete, moving forward"
			else
				echo "Something went wrong, machine has not rebinded"
 				exit 1
 			fi
 		fi
 	else
 		echo "This machine is not bound to AD, renaming without bind"
		sudo scutil --set HostName $asset
		echo "HostName set to $asset"			
		sudo scutil --set LocalHostName $user
		echo "LocalHostName set to $user"
		sudo scutil --set ComputerName $asset
		echo "ComputerName set to $user"
 	fi
else
	echo "Domain Unavailable"
	exit 1
fi

#sleep for 10 to let everything settle in
sleep 10

#Update record in JAMF
/usr/local/bin/jamf setComputerName -name "$asset"

exit 0
