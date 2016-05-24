#!/bin/bash
# fecha has a formated date

#blob storage variables
storageAccountName="storage_account"
storageAccountKey="U/2reY/R+p7T/"
storageContainer="storage_container"

fecha=`date +"%d-%m-%Y"`

#All application location
apps_location="/opt/glassfish4/glassfish/domains/domain1/applications"

#Backup location
backup_location="/mnt/resource/apps_backup/apps"

#Backup file name 
backupfile="$backup_location/All-application-$fecha.tar.bz2"

#email_msg
email_msg="/home/auto_backup/email_text_apps"

#Server name
server="myswerver.com"

#email receipients
EMAILS="zularbine@arditesbd.com,zularbine@gmail.com"

#All application name
APPSNAME=( "app1" "app2" "app3" "app4" "app5" )

# Backup and gzip the directory in VM
for i in "${APPSNAME[@]}"
do 
	if [ -d "$apps_location/$i" ]; then
		tar --exclude='META-INF' --exclude='VAADIN' --exclude='WEB-INF' -jcvf "$backup_location/application-$i-$fecha.tar.gz2" "$apps_location/$i"
		#after tar is finished move to blob storage
		azure storage blob upload -a $storageAccountName --container $storageContainer -k $storageAccountKey "$backup_location/application-$i-$fecha.tar.gz2" >> $email_msg
	else 
		echo "no such directory: $i" >> $email_msg
	fi
done 


if [ $? -eq 0 ]; then
   echo "Application folder backup is taken at : $(date). \nBackup files are located in: $backup_location\n\n\nHave a good day!\nroot, $server" > $email_msg
#   mail -s "($server)- Application folder backup on $fecha is Successful! " $EMAILS < $email_msg
else
   echo "Application folder backup is FAILED at : $(date). \nPlease fix it. \n\n\nHave a good day!\nroot, $server" > $email_msg
#   mail -s "($server)- GBCore Application folder backup on $fecha is FAILED! " $EMAILS < $email_msg
fi

# Rotate the backups, delete older than Five days
find "$backup_location/" -mtime +5 -exec rm {} \;



echo "all done!"
