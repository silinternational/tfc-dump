#!/bin/sh

# dump-and-save.sh - Dump Terraform Cloud workspaces and variables then save them to 1Password
#
# Dale Newby
# SIL International
# July 7, 2023

# Required environment variables:
# ATLAS_TOKEN              - Terraform Cloud access token ($TFC_API_TOKEN)
# OP_SERVICE_ACCOUNT_TOKEN - 1Password service account access key
# ORGANIZATION             - Name of the Terraform Cloud organization to be backed up
# VAULT_NAME               - 1Password vault name  "Apps Dev"
# VAULT_ITEM               - Item within the 1Password vault  "Terraform Workspace Backups"
# BACKUP_BASE_NAME         - Base name of the backup file (${BACKUP_BASE_NAME}-yyyy-mm-dd.tar.gz)  "tfc-backup"

datestring=`date +%Y-%m-%d`
backupname=${BACKUP_BASE_NAME}-${datestring}
cd /tmp
mkdir ${backupname}
cd ${backupname}
/usr/local/bin/tfc-dump.pl --org ${ORGANIZATION} --all
cd ..
tar zcf ${backupname}.tar.gz ${backupname}
rm -rf ${backupname}

op document edit ${VAULT_ITEM} ${backupname}.tar.gz --vault ${VAULT_NAME}

rm ${backupname}.tar.gz
