#!/bin/sh

# tfc-backup.sh - Back up Terraform Cloud workspaces and variables to a Restic repository on Backblaze B2
#
# Dale Newby
# SIL International
# July 20, 2023

# Required environment variables:
# ATLAS_TOKEN        - Terraform Cloud access token
# B2_ACCOUNT_ID      - Backblaze keyID
# B2_ACCOUNT_KEY     - Backblaze applicationKey
# FSBACKUP_MODE      - `init` initializes the Restic repository at `$RESTIC_REPOSITORY` (only do this once)
#                      `backup` performs a backup
# ORGANIZATION       - Name of the Terraform Cloud organization to be backed up
# RESTIC_BACKUP_ARGS - additional arguments to pass to 'restic backup' command
# RESTIC_FORGET_ARGS - additional arguments to pass to 'restic forget --prune' command
#                      (e.g., --keep-daily 7 --keep-weekly 5  --keep-monthly 3 --keep-yearly 2)
# RESTIC_HOST        - hostname to be used for the backup
# RESTIC_PASSWORD    - password for the Restic repository
# RESTIC_REPOSITORY  - Restic repository location (e.g., 'b2:bucketname:restic')
# RESTIC_TAG         - tag to apply to the backup
# SOURCE_PATH        - Full path to the directory to be backed up

STATUS=0

case "${BACKUP_MODE}" in
	init)
		/data/${BACKUP_MODE}.sh || STATUS=$?
		;;
	backup)
		echo "tfc-backup: backup: Started"
		echo "tfc-backup: Exporting Terraform Cloud data to ${SOURCE_PATH}"

		mkdir -p ${SOURCE_PATH} && cd ${SOURCE_PATH} && rm -rf *
		if [ $STATUS -ne 0 ]; then
			echo "tfc-backup: FATAL: Cannot create directory ${SOURCE_PATH}: $STATUS"
			exit $STATUS
		fi

		start=$(date +%s)
		/usr/local/bin/tfc-dump.pl --org ${ORGANIZATION} --all --quiet
		end=$(date +%s)

		if [ $STATUS -ne 0 ]; then
			echo "tfc-backup: FATAL: Terraform Cloud export returned non-zero status ($STATUS) in $(expr ${end} - ${start}) seconds."
        		exit $STATUS
		else
        		echo "tfc-backup: Terraform Cloud export completed in $(expr ${end} - ${start}) seconds."
		fi

		/data/${BACKUP_MODE}.sh || STATUS=$?
		if [ $STATUS -ne 0 ]; then
			echo "tfc-backup: FATAL: backup failed: $STATUS"
			exit $STATUS
		fi

		cd .. &&  rm -rf ${SOURCE_PATH} || STATUS=$?
		if [ $STATUS -ne 0 ]; then
			echo "tfc-backup: FATAL: Cannot remove directory ${SOURCE_PATH}: $STATUS"
			exit $STATUS
		fi

		echo "tfc-backup: backup: Completed"
		;;
	*)
		echo "tfc-backup: FATAL: Unknown BACKUP_MODE: ${BACKUP_MODE}"
		exit 1
esac

if [ $STATUS -ne 0 ]; then
	echo "tfc-backup: Non-zero exit: $STATUS"
fi

exit $STATUS
