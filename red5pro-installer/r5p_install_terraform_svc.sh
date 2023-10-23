#!/bin/bash
##############################################################################################################
# Install and configure Terraform service for OCI
# Before start this script you need copy terraform-service-build.zip into the same folder with this script!!!
##############################################################################################################

# TERRA_API_KEY="abc123"
# TERRA_PARALLELISM="20"
# TENANCY_OCID=""
# USER_OCID=""
# FINGERPRINT=""
# PRIVATE_KEY_PATH=""
# COMPARTMENT_ID=""
# SUBNET_NAME=""
# PUBLIC_KEY_PATH=""
# NETWORK_SECURITY_GROUP=""
# DB_HOST="test.com"
# DB_PORT="3306"
# DB_USER="smuser"
# DB_PASSWORD="abc123"
# TF_SVC_ENABLE="true"

TERRA_FOLDER="/usr/local/red5service"
CURRENT_DIRECTORY=$(pwd)
PACKAGES=(default-jre unzip ntp)

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
}
log() {
    echo -n "[$(date '+%Y-%m-%d %H:%M:%S')]"
}

check_terraform_variables(){
    log_i "Check TERRAFORM variables..."
    
    if [ -z "$TERRA_API_KEY" ]; then
        log_w "Variable TERRA_API_KEY is empty."
        var_error=1
    fi
    if [ -z "$TERRA_PARALLELISM" ]; then
        log_w "Variable TERRA_PARALLELISM is empty."
        var_error=1
    fi
    if [ -z "$TENANCY_OCID" ]; then
        log_w "Variable TENANCY_OCID is empty."
        var_error=1
    fi
    if [ -z "$USER_OCID" ]; then
        log_w "Variable USER_OCID is empty."
        var_error=1
    fi
    if [ -z "$FINGERPRINT" ]; then
        log_w "Variable FINGERPRINT is empty."
        var_error=1
    fi
    if [ -z "$PRIVATE_KEY_PATH" ]; then
        log_w "Variable PRIVATE_KEY_PATH is empty."
        var_error=1
    fi
    if [ -z "$PUBLIC_KEY_PATH" ]; then
        log_w "Variable PUBLIC_KEY_PATH is empty."
        var_error=1
    fi
    if [ -z "$COMPARTMENT_ID" ]; then
        log_w "Variable COMPARTMENT_ID is empty."
        var_error=1
    fi
    if [ -z "$SUBNET_NAME" ]; then
        log_w "Variable SUBNET_NAME is empty."
        var_error=1
    fi
    if [ -z "$NETWORK_SECURITY_GROUP" ]; then
        log_w "Variable NETWORK_SECURITY_GROUP is empty."
        var_error=1
    fi
    if [ -z "$DB_HOST" ]; then
        log_w "Variable DB_HOST is empty."
        var_error=1
    fi
    if [ -z "$DB_PORT" ]; then
        log_w "Variable DB_PORT is empty."
        var_error=1
    fi
    if [ -z "$DB_USER" ]; then
        log_w "Variable DB_PORT is empty."
        var_error=1
    fi
    if [ -z "$DB_PASSWORD" ]; then
        log_w "Variable DB_PASSWORD is empty."
        var_error=1
    fi
    if [[ "$var_error" == "1" ]]; then
        log_e "One or more variables are empty. EXIT!"
        exit 1
    fi
}

install_pkg(){
    
    for i in {1..5};
    do
        
        local install_issuse=0;
        apt-get -y update --fix-missing &> /dev/null
        
        for index in ${!PACKAGES[*]}
        do
            log_i "Install utility ${PACKAGES[$index]}"
            apt-get install -y ${PACKAGES[$index]} &> /dev/null
        done
        
        for index in ${!PACKAGES[*]}
        do
            PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ${PACKAGES[$index]}|grep "install ok installed")
            if [ -z "$PKG_OK" ]; then
                log_i "${PACKAGES[$index]} utility didn't install, didn't find MIRROR !!! "
                install_issuse=$(($install_issuse+1));
            else
                log_i "${PACKAGES[$index]} utility installed"
            fi
        done
        
        if [ $install_issuse -eq 0 ]; then
            break
        fi
        if [ $i -ge 5 ]; then
            log_e "Something wrong with packages installation!!! Exit."
            exit 1
        fi
        sleep 20
    done
}

install_terraform_service(){
    log_i "Install TERRAFORM SERVICE"
    
    TERRA_RCHIVE=$(ls $CURRENT_DIRECTORY/terraform-service*.zip | xargs -n 1 basename);
    
    if [ ! -f "$TERRA_RCHIVE" ]; then
        log_e "Terraform service archive was not found: $TERRA_RCHIVE. EXIT..."
        exit 1
    fi
    
    unzip "$CURRENT_DIRECTORY/$TERRA_RCHIVE" -d /usr/local/
    
    rm $TERRA_FOLDER/*.tf
    cp -r $TERRA_FOLDER/cloud_controller_oracle/* $TERRA_FOLDER/

    cp $TERRA_FOLDER/red5proterraform.service /lib/systemd/system/
    chmod +x $TERRA_FOLDER/red5terra.sh $TERRA_FOLDER/terraform
    chmod 644 /lib/systemd/system/red5proterraform.service
    systemctl daemon-reload
    systemctl enable red5proterraform.service
}

config_terraform_service(){
    log_i "TERRAFORM SERVICE CONFIGURATION"

    local terra_api_token_pattern='api.accessToken=.*'
    local terra_api_token_new="api.accessToken=${TERRA_API_KEY}"
    
    local terra_parallelism_pattern='terra.parallelism=.*'
    local terra_parallelism_new="terra.parallelism=${TERRA_PARALLELISM}"

    local do_api_token_pattern='.*cloud.do_api_token=.*'
    local do_api_token_new="# cloud.do_api_token="
    
    local do_ssh_key_pattern='.*cloud.do_ssh_key_name=.*'
    local do_ssh_key_new="# cloud.do_ssh_key_name="
    
    local oracle_tenancy_ocid_pattern='.*cloud.oracle_tenancy_ocid=.*'
    local oracle_tenancy_ocid_new="cloud.oracle_tenancy_ocid=${TENANCY_OCID}"
    
    local oracle_user_ocid_pattern='.*cloud.oracle_user_ocid=.*'
    local oracle_user_ocid_new="cloud.oracle_user_ocid=${USER_OCID}"

    local oracle_fingerprint_pattern='.*cloud.oracle_fingerprint=.*'
    local oracle_fingerprint_new="cloud.oracle_fingerprint=${FINGERPRINT}"

    local oracle_private_key_path_pattern='.*cloud.oracle_private_key_path=.*'
    local oracle_private_key_path_new="cloud.oracle_private_key_path=${PRIVATE_KEY_PATH}"

    local oracle_compartment_id_pattern='.*cloud.oracle_compartment_id=.*'
    local oracle_compartment_id_new="cloud.oracle_compartment_id=${COMPARTMENT_ID}"

    local oracle_subnet_name_pattern='.*cloud.oracle_subnet_name=.*'
    local oracle_subnet_name_new="cloud.oracle_subnet_name=${SUBNET_NAME}"

    local oracle_pub_key_path_pattern='.*cloud.oracle_ssh_pub_path=.*'
    local oracle_pub_key_path_new="cloud.oracle_ssh_pub_path=${PUBLIC_KEY_PATH}"

    local oracle_network_security_group_pattern='.*cloud.oracle_network_security_group=.*'
    local oracle_network_security_group_new="cloud.oracle_network_security_group=${NETWORK_SECURITY_GROUP}"
    
    local db_host_pattern='config.dbHost=.*'
    local db_host_new="config.dbHost=${DB_HOST}"
    
    local db_port_pattern='config.dbPort=.*'
    local db_port_new="config.dbPort=${DB_PORT}"
    
    local db_user_pattern='config.dbUser=.*'
    local db_user_new="config.dbUser=${DB_USER}"
    
    local db_password_pattern='config.dbPass=.*'
    local db_password_new="config.dbPass=${DB_PASSWORD}"
    
    sed -i -e "s|$terra_api_token_pattern|$terra_api_token_new|" -e "s|$terra_parallelism_pattern|$terra_parallelism_new|" -e "s|$do_api_token_pattern|$do_api_token_new|" -e "s|$do_ssh_key_pattern|$do_ssh_key_new|" -e "s|$oracle_tenancy_ocid_pattern|$oracle_tenancy_ocid_new|" -e "s|$oracle_user_ocid_pattern|$oracle_user_ocid_new|" -e "s|$oracle_fingerprint_pattern|$oracle_fingerprint_new|" -e "s|$oracle_private_key_path_pattern|$oracle_private_key_path_new|" -e "s|$oracle_compartment_id_pattern|$oracle_compartment_id_new|" -e "s|$oracle_subnet_name_pattern|$oracle_subnet_name_new|" -e "s|$oracle_pub_key_path_pattern|$oracle_pub_key_path_new|" -e "s|$oracle_network_security_group_pattern|$oracle_network_security_group_new|" -e "s|$db_host_pattern|$db_host_new|" -e "s|$db_port_pattern|$db_port_new|" -e "s|$db_user_pattern|$db_user_new|" -e "s|$db_password_pattern|$db_password_new|" "$TERRA_FOLDER/application.properties"
}

start_terraform_service(){
    log_i "STARTING TERRAFORM SERVICE"
    systemctl restart red5proterraform.service
    
    if [ "0" -eq $? ]; then
        log_i "TERRAFORM SERVICE started!"
    else
        log_e "TERRAFORM SERVICE didn't start!!!"
        exit 1
    fi
    
}

if [[ "$TF_SVC_ENABLE" == true ]]; then
    log_i "TF_SVC_ENABLE is set to true, Installing Red5 Pro Terraform Service..."
    export LC_ALL="en_US.UTF-8"
    export LC_CTYPE="en_US.UTF-8"

    check_terraform_variables
    install_pkg
    install_terraform_service
    config_terraform_service
    start_terraform_service
else
    log_i "SKIP Red5 Pro Terraform Service installation."
fi

