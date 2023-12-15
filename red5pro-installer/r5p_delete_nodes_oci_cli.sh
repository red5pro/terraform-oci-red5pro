#!/bin/bash

NODE_INSTANCE_NAME="$1"       # "todd0711-mixer-node-us-ashburn-1"
OCI_CLI_COMPARTMENT_ID="$2"   # "ocid1.compartment.oc1..aaaaaaaafasbmuztg2fuetes66exq4gwq2svqptmepsfwsw53f2zd7ts4kiq"
OCI_CLI_USER="$3"             
OCI_CLI_FINGERPRINT="$4"
OCI_CLI_TENANCY="$5"
OCI_CLI_REGION="$6"
OCI_CLI_KEY_FILE="$7"

log_i() {
    log
    printf "\033[0;32m [INFO]  --- %s \033[0m\n" "${@}"
}
log_w() {
    log
    printf "\033[0;35m [WARN] --- %s \033[0m\n" "${@}"
}
log_e() {
    log
    printf "\033[0;31m [ERROR]  --- %s \033[0m\n" "${@}"
    exit 1
}
log() {
    echo -n "[$(date '+%Y-%m-%d %H:%M:%S')]"
}

if [[ -z "$NODE_INSTANCE_NAME" ]]; then
    log_e "NODE_INSTANCE_NAME is not set!"
fi
if [[ -z "$OCI_CLI_COMPARTMENT_ID" ]]; then
    log_e "OCI_CLI_COMPARTMENT_ID is not set!"
fi
if [[ -z "$OCI_CLI_USER" ]]; then
    log_e "OCI_CLI_USER is not set!"
fi
if [[ -z "$OCI_CLI_FINGERPRINT" ]]; then
    log_e "OCI_CLI_FINGERPRINT is not set!"
fi
if [[ -z "$OCI_CLI_TENANCY" ]]; then
    log_e "OCI_CLI_TENANCY is not set!"
fi
if [[ -z "$OCI_CLI_REGION" ]]; then
    log_e "OCI_CLI_REGION is not set!"
fi
if [[ -z "$OCI_CLI_KEY_FILE" ]]; then
    log_e "OCI_CLI_KEY_FILE is not set!"
fi

export OCI_CLI_USER="$OCI_CLI_USER"
export OCI_CLI_FINGERPRINT="$OCI_CLI_FINGERPRINT"
export OCI_CLI_TENANCY="$OCI_CLI_TENANCY"
export OCI_CLI_REGION="$OCI_CLI_REGION"
export OCI_CLI_KEY_FILE="$OCI_CLI_KEY_FILE"

oci compute instance list --compartment-id "$OCI_CLI_COMPARTMENT_ID" |jq -r '.data[] | [."display-name", .id, ."lifecycle-state"] | join(" ")' | grep "$NODE_INSTANCE_NAME" | grep "RUNNING" > instances.txt

while read -r line; do
    instance_name=$(echo "$line" | awk '{print $1}')
    instance_id=$(echo "$line" | awk '{print $2}')
    echo "Delete instance with name: $instance_name and ID: $instance_id"
    oci compute instance terminate --instance-id "$instance_id" --force
done < instances.txt

if [[ -f instances.txt ]]; then
    rm instances.txt
fi