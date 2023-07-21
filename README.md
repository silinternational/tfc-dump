# tfc-dump
Perl script using the Terraform Cloud API to export workspaces, variables, and variable sets to JSON files.

## Motivation
During the review of a disaster recovery plan, we realized that we didn't have a
record of the values we set for variables in Terraform Cloud workspaces.
It would be difficult to recover from the accidental deletion of a Terraform
Cloud workspace.
This Perl script was quickly written to export information to JSON files
using the Terraform Cloud API.
The exported information includes workspaces, variables, and variable sets
which covers most of what we need.

## How to use tfc-dump.pl
1. Install [tfc-ops](https://github.com/silinternational/tfc-ops). `tfc-dump`
was tested with `tfc-ops` version 3.1.2.
2. Obtain a Terraform Cloud access token. Go to https://app.terraform.io/app/settings/tokens to create an API token.
3. Set and export the environment variable ATLAS\_TOKEN with the Terraform Cloud access token as its value (e.g., use a command like export ATLAS\_TOKEN=_terraform-cloud-access-token_). Note that preceding the `export` command with a space may prevent the command from being stored in the shell history. Refer to the description of the `HISTCONTROL` shell variable in the `bash` man page for details.
4. To dump one workspace:
tfc-dump.pl --org _terraform-cloud-organization_ --workspace _terraform-cloud-workspace-name_
5. To dump all workspaces in an organization:
tfc-dump.pl --org _terraform-cloud-organization_ --all

## Outputs
Two files are created for each Terraform Cloud workspace:

- _workspace-name_-workspace.json
- _workspace-name_-variables.json

Two files are created for each Terraform Cloud Variable Set:

- varset-_variable-set-name_.json
- varset-_variable-set-name_-variables.json

Spaces in the variable set name are replaced with hyphens (`-`).

## Restrictions
The code assumes that all of the Terraform Cloud Variable Sets are contained
within the first result page of 20 entries.

## Example use with Docker and Backblaze
The image created by the Dockerfile will run `tfc-dump` and use Restic to back up the resulting files to a repository stored in a Backblaze B2 bucket.
1. Copy `local.env.dist` to `local.env`.
1. Set the values for the variables contained in `local.env`.
1. Obtain a Terraform Cloud access token. Go to https://app.terraform.io/app/settings/tokens to create an API token.
1. Add the access token value to `local.env`.
1. Obtain a Backblaze Application Key. Ensure it has these capabilities: deleteFiles, listBuckets, listFiles, readBuckets, readFiles, writeBuckets, writeFiles.
1. Add the application key and secret to `local.env` as the values of `B2_ACCOUNT_ID` and `B2_ACCOUNT_KEY`.
1. Create a Backblaze B2 bucket. Set the `File Lifecycle` to `Keep only the last version`.
1. Add the B2 bucket name to `RESTIC_REPOSITORY` in `local.env`.
1. Build the Docker image:  `docker build --tag tfc-backup:latest .`
1. Initialize the Restic repository (one time only):  `docker run --env-file=local.env --env BACKUP_MODE=init tfc-backup:latest`
1. Run the Docker image:  `docker run --env-file=local.env tfc-backup:latest`
