#!bin/bash
#Loaner Registration
#Brian Taniyama
#2014
#One Kings Lane

//Get Current Hardware ID

ioreg -c "IOPlatformExpertDevice" | awk -F '"' '/IOPlatformSerialNumber/ {print $4}'



//Prompt Loaner T&C

//Prompt for username

//Check if User exists

//If User doesn't exist, create user

//Assign Machine to User 

