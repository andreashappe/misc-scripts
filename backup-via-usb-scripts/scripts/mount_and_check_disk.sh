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
log "trying to mount $1 on $2"

# test if all needed parameters were passed
if [[ -z "$1" || -z "$2" ]]; then
	log_and_mail "either device:$1 or mountpoint:$2 is invalid"
	exit 1
else
	DEVICE=/dev/$1
	MOUNTPOINT=$2
fi

# check if $DEVICE is already mounted somewhere
for i in `cat /proc/mounts | cut -d' ' -f1`; do
	if [ "x$DEVICE" = "x$i" ]; then
		log "$DEVICE was already mounted, trying to unmount"
		umount $DEVICE
		if [ $? != 0 ]; then
			log_and_mail "$DEVICE was already mounted and could not be unmounted, exiting.."
      			exit 1
		fi
	fi
done

# check if $MOUNTPOINT is already in use
for i in `cat /proc/mounts | cut -d' ' -f2`; do
	if [ "x$MOUNTPOINT" = "x$i" ]; then
		log "$MOUNTPOINT was already mounted, trying to unmount"
		umount $MOUNTPOINT
		if [ $? != 0 ]; then
			log_and_mail "$MOUNTPOINT was already mounted and could not be unmounted, exiting.."
      			exit 1
		fi
	fi
done

# check the filesystem on $DEVICE
fsck.ext4 -p $DEVICE 2>&1 >> $ERROR_LOG
case "$?" in
0) 	log "file system check okay"
	;;
1)	log "file system check okay: errors found but corrected"
	;;
*)	log_and_mail "file system check failed ($?), backup aborted"
	exit 1
	;;
esac

# finally mount the file system
mount -t ext4 -o noatime,data=writeback,nobh,nodiratime $DEVICE $MOUNTPOINT
if [ "$?" != 0 ]; then
	log_and_mail "file system could not be mounted"
	exit 1
fi

# everything is done now
log "mount finished successful"
exit 0
