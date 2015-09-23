#!/bin/bash
# fecha has a formated date
fecha=`date +"%d-%m-%Y"`

#blob storage variables
storageAccountName="gbbackup101"
storageAccountKey="U/2reY/R+p7T/Af1f9+TlvKal6agh66bItY9nsXSi/ilu32TRgx2B5XB6b6+826RC7UEISIl8sVHnk3F9CDIBQ=="
storageContainer="gbcore"


#email_msg
email_msg="/home/auto_backup/email_text_apps"

#Server name
server="gbuilder.com"

#email receipients
#EMAILS="zularbine@arditesbd.com,harri@groupbuilder.fi,marko@groupbuilder.fi"
EMAILS="zularbine@arditesbd.com,zularbine@gmail.com"

#Backup location
BACKUP_LOCATION="/mnt/resource/gbcore_backup/apps"
# Backup and gzip the directory
tar jcvf $BACKUP_LOCATION/application-$fecha.tar.bz2 /opt/glassfish4/glassfish/domains/domain1/applications/
#tar jcvf $BACKUP_LOCATION/application-$fecha.tar.bz2 /home/auto_backup/test_folder/

if [ $? -eq 0 ]; then
   echo "Application folder backup is taken at : $(date). \nBackup files are located in: $BACKUP_LOCATION\n\n\nHave a good day!\nroot, $server" > $email_msg
   mail -s "(gbuilder.com)- GBCore Application folder backup on $fecha is Successful! " $EMAILS < $email_msg
else
   echo "Application folder backup is FAILED at : $(date). \nPlease fix it. \n\n\nHave a good day!\nroot, $server" > $email_msg
   mail -s "(gbuilder.com)- GBCore Application folder backup on $fecha is FAILED! " $EMAILS < $email_msg
fi

# Rotate the backups, delete older than TWO days
find /mnt/resource/gbcore_backup/apps/ -mtime +2 -exec rm {} \;

#after tar is finished move to blob storage
azure storage blob upload -a $storageAccountName --container $storageContainer -k $storageAccountKey $BACKUP_LOCATION/application-$fecha.test.tar.bz2