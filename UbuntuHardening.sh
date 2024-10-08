#!/bin/bash

if [[ $EUID -ne 0 ]]
then
  echo "You MUST be --root-- to run this script."
  exit 1
fi

log()
{
	echo -e "$1"
	echo -e "$1" >> ~/work/Script.log
}


echo > ~/work/Script.log
chmod 777 ~/work/Script.log

read -p "<Press Enter To Start The Script>"

mkdir -p ~/work/backups
chmod 777 ~/work/backups
log "Backups folder created on Work folder"

cp /etc/group ~/work/backups/
cp /etc/passwd ~/work/backups/
log "etc/group and etc/passwd files backup"

echo "Please Copy Paste the list of Authorized Users from the ReadME (Hit Ctrl-D when finished)"
while read line
do
    authUsers=("${authUsers[@]}" $line)
done

currentUsers=`awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534) print $1}' /etc/passwd`
userArr=($currentUsers)

echo "Please copy/paste the list of Authorized Admin from the ReadME Line By Line (Hit Ctrl-D when finished)"

while read line
do
	authAdmins=("${authAdmins[@]}" $line)
done

allAuthUsers=( "${authUsers[@]}" "${authAdmins[@]}" )

unwantedUsers=`echo  ${allAuthUsers[@]} ${currentUsers[@]} | tr ' ' '\n' | sort | uniq -u`

for unwantedUser in `echo $unwantedUsers`
do
	isUser=false
	case "${currentUsers[@]}" in  *"$unwantedUser"*) isUser=true ;; esac
	if [ "$isUser" = true ]; then
	while true; do
     	read -p "Would you like to delete user $unwantedUser? [y/n]" yn
	case $yn in
		[Yy]* ) userdel "$unwantedUser"; log "user $unwantedUser has been deleted."; break;;
		[Nn]* ) break;;
		* ) echo "Please answer y or n only.";;
	esac
done
else
	while true; do
	read -p "Would you like to add user $unwantedUser? [y/n]" yn1
	case $yn1 in 
		[Yy]* ) useradd "$unwantedUser"; chage -d 0 "$i"; log "user $unwantedUser has been added."; break;;
		[Nn]* ) break;;
		* ) echo "Please answer y or n only.";;
	esac
done
fi
done

for admin in `echo $authAdmins`
do
	while true; do
	read -p "Would you like to make user $admin an admin? [y/n]" yn2
	case $yn2 in
		[Yy]* ) gpasswd -a $admin sudo; gpasswd -a $admin adm; gpasswd -a $admin lpadmin; gpasswd -a $admin sambashare; log "user $admin is now an admin"; break;;
		[Nn]* ) break;;
		* ) echo "Please answer y or n only.";;
	esac
	done
done

for user in `echo $authUsers`
do
	while true; do
	read -p "Would you like to make user $user a normal user? [y/n]" yn3
	case $yn3 in
		[Yy]* ) gpasswd -d $user sudo; gpasswd -d $user adm; gpasswd -d $user lpadmin; gpasswd -d $user sambashare; gpasswd -d $user root; log "user $user is now a standard user"; break;;
		[Nn]* ) break;;
		* ) echo "Please answer y or n only.";;
	esac
	done
done

log "CAUTION: Make sure to not change the password of the autologin user if you don't have to."
log "NOTE: All Passwords are changed to Cyb3rPatr!0tPa%%WORD2016"

for secureUser in `echo $allAuthUsers`
do
	while true; do
		read -p "Would you like to change the password of user $secureUser? [y/n]" yn4
		case $yn4 in
			[Yy]* ) echo "$secureUser:Cyb3rPatr!0tPa%%W0RD2016" | chpasswd; log "Password of user $secureUser has been changed."; break;;
			[Nn]* ) break;;
			* ) echo "Please answer y or n only.";;
		esac
	done
done
