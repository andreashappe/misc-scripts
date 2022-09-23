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

# add some log entry about mount attempt
log "starting backup script"

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

# check if there's a filesystem mounted on mountpoint and check if at least 1GB is free
CMD="df -P | awk '\$6==\"$MOUNTPOINT\" {printf \"%.0f\", \$4/1024/1024}'"
MOUNT_FREE=`eval $CMD`
MOUNT_LIMIT=1

if [ -z "$MOUNT_FREE" ]; then
	log_and_mail "no filesystem mounted at $MOUNTPOINT, aborting"
	exit 1
fi

if [ "$MOUNT_FREE" -lt "$MOUNT_LIMIT" ]; then
	log_and_mail "less than $MOUNT_LIMIT GB free space on disk, aborting"
	exit 1
fi

# just in case mount the filesystem as r/w
mount -o remount,rw $MOUNTPOINT
if [ "$?" != 0 ]; then
	log_and_mail "could not mount $MOUNTPOINT read-write"
	exit 1
fi

# perform the backup
log "starting rsync"

LOGFILE=$DATEPREFIX.log
echo `date` > $MOUNTPOINT/$LOGFILE
mkdir -p $MOUNTPOINT/$DATEPREFIX

rsync -rt --delete /media/raid/* $MOUNTPOINT/$DATEPREFIX/ > $MOUNTPOINT/$LOGFILE-data.log 2>&1
RESULT="$?"
if [ $RESULT != 0 ]; then
	log_and_mail "rsync finished but reported error ($RESULT)"
	exit 1
else
	log "rsync finished successfully"
fi

# check free space
CMD="df -P | awk '\$6==\"$MOUNTPOINT\" {printf \"%.0f\", \$4/1024/1024}'"
MOUNT_FREE=`eval $CMD`
if [ "$MOUNT_FREE" -lt "10" ]; then
	log_and_mail "rsync finished, but WARNING: only $MOUNT_FREE GB free anymore"
fi

# sync and mount r/o
mount -o remount,ro $MOUNTPOINT
/bin/sync

log "backup finished sucessfully"
exit 0
