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
was tested with `tfc-ops` version 3.0.0.
2. Obtain a Terraform Cloud access token.
3. Set and export the environment variable ATLAS\_TOKEN with the Terraform Cloud access token as its value (e.g., use a command like export ATLAS\_TOKEN=_terraform-cloud-access-token_). Note that preceding the `export` command with a space may prevent the command from being stored in the shell history. Refer to the description of the `HISTCONTROL` shell variable in the `bash` man page for details.
4. To dump one workspace:
tfc-dump.pl --org _terraform-cloud-organization_ --workspace _terraform-cloud-workspace-name_
5. To dump all workspaces in an organization:
tfc-dump.pl --org _terraform-cloud-organization_ --all

## Outputs
Two files are created for each Terraform Cloud workspace:

- _workspace-name_-workspace.json
- _workspace-name_-variables.json

Variable Sets are exported to files named varset-_variable-set-name_.json
with spaces in the variable set name replaced with hyphens (`-`).

## Restrictions
The code assumes that all of the Terraform Cloud Variable Sets are contained
within the first result page of 20 entries.
