#!/bin/bash

# helper functions
ERROR_MAIL="b.pongratz@lakata.at"
ERROR_LOG="/var/log/backup.log"

function log {
	DATE=`date +%Y-%m-%d-%H:%M`
	echo "$DATE: $1"
	echo "$DATE: $1" >> $ERROR_LOG
}

function mail {
	DATE=`date +%Y-%m-%d-%H:%M`
	echo "$DATE: $1" | mailx $ERROR_MAIL

}

function log_and_mail {
	log "$*"
	mail "$*"
}

# determine mountpoint
DATEPREFIX=`date +%u`
case "$DATEPREFIX" in
[1,3,5])	MOUNTPOINT="/media/backup-mmf"
		;;
[2,4])		MOUNTPOINT="/media/backup-dd"
		;;
*)		log_and_mail "backup script started on invalid day ($DATEPREFIX)"
		exit 1
		;;
esac
log "using mountpoint $MOUNTPOINT"

/usr/local/bin/perform_backup.sh
umount $MOUNTPOINT
if [ $? != 0 ]; then
	log_and_mail "could not unmount filesystem, please check before removing harddrive"
	exit 1
fi

exit 0
