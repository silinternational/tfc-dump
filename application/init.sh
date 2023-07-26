#!/usr/bin/env sh

STATUS=0

echo "tfc-backup: init: Started"

start=$(date +%s)
/usr/local/bin/restic init || STATUS=$?
end=$(date +%s)

if [ $STATUS -ne 0 ]; then
	echo "tfc-backup: FATAL: Repository initialization returned non-zero status ($STATUS) in $(expr ${end} - ${start}) seconds."
	exit $STATUS
else
	echo "tfc-backup: Repository initialization completed in $(expr ${end} - ${start}) seconds."
fi

echo "tfc-backup: init: Completed"
exit $STATUS
