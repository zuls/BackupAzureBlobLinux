#!/bin/bash
# fecha has a formated date

#blob storage variables
storageAccountName="gbbackup101"
storageAccountKey="U/2reY/R+p7T/Af1f9+TlvKal6agh66bItY9nsXSi/ilu32TRgx2B5XB6b6+826RC7UEISIl8sVHnk3F9CDIBQ=="
storageContainer="gbcore"


fecha=`date +"%d-%m-%Y"`

#Backup location
backup_location="/mnt/resource/gbcore_backup/apps"
#Backup file name 
backupfile="$backup_location/TEST-application-$fecha.tar.bz2"

echo $backupfile

#email_msg
email_msg="/home/auto_backup/email_text_apps"

#Server name
server="gbuilder.com"

#email receipients
#EMAILS="zularbine@arditesbd.com,harri@groupbuilder.fi,marko@groupbuilder.fi"
EMAILS="zularbine@arditesbd.com,zularbine@gmail.com"

# Backup and gzip the directory
#tar jcvf $backupfile /opt/glassfish4/glassfish/domains/domain1/applications/
tar jcvf $backupfile /mnt/resource/gbcore_backup/mysql/

if [ $? -eq 0 ]; then
   echo "Application folder backup is taken at : $(date). \nBackup files are located in: $backup_location\n\n\nHave a good day!\nroot, $server" > $email_msg
   mail -s "(gbuilder.com)- GBCore Application folder backup on $fecha is Successful! " $EMAILS < $email_msg
else
   echo "Application folder backup is FAILED at : $(date). \nPlease fix it. \n\n\nHave a good day!\nroot, $server" > $email_msg
   mail -s "(gbuilder.com)- GBCore Application folder backup on $fecha is FAILED! " $EMAILS < $email_msg
fi

# Rotate the backups, delete older than Five days
find /home/auto_backup/apps/ -mtime +5 -exec rm {} \;

#after tar is finished move to blob storage
azure storage blob upload -a $storageAccountName --container $storageContainer -k $storageAccountKey $backupfile

echo "all done!"