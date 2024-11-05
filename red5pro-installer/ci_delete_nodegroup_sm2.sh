#!/bin/bash

# R5AS_AUTH_USER="xyz"
# R5AS_AUTH_PASS="xyz"
# OLD_INAMES="test"
# COMPARTMENT_ID="ocid1.compartment.oc1..************************"

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

generate_node_name() {
    node_group_name=$(echo $1 | jq -r '.nodeGroupName')
    sub_group_name=$(echo $1 | jq -r '.subGroupName')
    node_role_name=$(echo $1 | jq -r '.nodeRoleName')
    node_id=$(echo $1 | jq -r '.nodeId')

    node_instance_name="${node_group_name}-${sub_group_name}-${node_role_name}-${node_id}"
    echo $node_instance_name
}

delete_multi_region_nodes(){
    oci_regions=$(curl -s -H "Content-Type: application/json" -H "Authorization: Bearer ${JWT}" "https://$SM_ADDRESS.red5pro.net:443/as/v1/admin/terraform/node" | jq -r '.OCI | keys[]')
    
    for region in $oci_regions; do
        log_i "Getiing information on number of nodes in region $region"
        region_nodes=($(curl -s -H "Content-Type: application/json" -H "Authorization: Bearer ${JWT}" "https://$SM_ADDRESS.red5pro.net:443/as/v1/admin/terraform/node" | jq -r --arg region "$region" '.OCI[$region][]'))
        
        for node in "${region_nodes[@]}"; do
            OCI_CLI_PROFILE=$region
            instance_name=$node
            delete_node_group_nodes
        done
    done
}

get_node_groups_info(){
    log_i "Getting all node groups ..."
    SM_ADDRESS=$1
    error=0
	JWT=$(create_jwT_token)
    log_i "Getiing information on number of node_groups"
    NODE_GROUPS=$(curl -s -H "Content-Type: application/json" -H "Authorization: Bearer ${JWT}" "https://$SM_ADDRESS.red5pro.net:443/as/v1/admin/nodegroup" | jq -r '.[]')
    for group in $NODE_GROUPS
    do
        log_i "Getting information of region where node group: $group is created"
        node_group_region=$(curl -s -H "Content-Type: application/json" -H "Authorization: Bearer ${JWT}" "https://$SM_ADDRESS.red5pro.net:443/as/v1/admin/nodegroup/${group}" | jq -r '.groups | map_values(.cloudProperties)|.[]' | sed 's/region=//')
        
        OCI_CLI_PROFILE=$node_group_region
        log_i "Region for nodegroup: $group is $node_group_region"

        IFS=$'\n'
        regions=($node_group_region)
        if [[ ${#regions[@]} -gt 1 ]]; then
            log_i "This node group is multi-region node group"
            delete_multi_region_nodes
            continue
        fi

        log_i "Getting information of total no. nodes in node group: $group"
        node_info=$(curl -s -H "Content-Type: application/json" -H "Authorization: Bearer ${JWT}" "https://$SM_ADDRESS.red5pro.net:443/as/v1/admin/nodegroup/status/${group}")
        node_count=$(echo $node_info | jq -r '. | length')

        if [ $node_count -eq 0 ]; then
            break
        else
            log_i "Found $node_count nodes"
            for ((i = 0; i < $node_count; i++)); do
                log_i "Getting information for "$i" node"
                node=$(curl -s -H "Content-Type: application/json" -H "Authorization: Bearer ${JWT}" "https://$SM_ADDRESS.red5pro.net:443/as/v1/admin/nodegroup/status/${group}" | jq -r --argjson id "$i" '.[$id].scalingEvent')

                log_i "Creating node instance name"
                instance_name=$(generate_node_name "$node")
                delete_node_group_nodes
            done
        fi
    done
}

create_jwT_token(){
    SM_STATUS_URL="https://$R5AS_AUTH_USER:$R5AS_AUTH_PASS@$iname.red5pro.net:443/as/v1/auth/login"
    echo $(curl -s --location --request PUT "$SM_STATUS_URL" --header 'Content-Type: application/json' | jq -r '.token')
}

delete_node_group_nodes(){
    INSTANCE_ID=$(oci compute instance list --profile "$OCI_CLI_PROFILE" --compartment-id "$COMPARTMENT_ID" --display-name "$instance_name" --lifecycle-state RUNNING | jq -r '.data[0].id')
    log_i "Terminating node: $instance_name"
    oci compute instance terminate --profile $OCI_CLI_PROFILE --instance-id $INSTANCE_ID --force --wait-for-state TERMINATING >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        log_i "Node terminated successfully!"
    else
        log_w "Unable to terminate node: $instance_name"
        error=1
    fi
    
    if [[ $error -eq 1 ]]; then
        log_w "One or more nodes in node group: $group was not deleted. Please check and delete Node manualy!!!"
    fi
}

delete_node_group(){
    log_i "Checking active node groups ..."
    SM_ADDRESS=$1
    error=0
    JWT=$(create_jwT_token)
    NODE_GROUPS=$(curl -s -H "Content-Type: application/json" -H "Authorization: Bearer ${JWT}" "https://$SM_ADDRESS.red5pro.net:443/as/v1/admin/nodegroup" | jq -r '.[]')
    
    for group in $NODE_GROUPS
    do
        log_i "Deleting node group: $group"
        DELETE_NODE_GROUP=$(curl -s -o /dev/null -w "%{http_code}" --location --request DELETE "https://$SM_ADDRESS.red5pro.net:443/as/v1/admin/nodegroup/${group}" --header "Authorization: Bearer ${JWT}" --header 'Content-Type: application/json')
        if [[ "$DELETE_NODE_GROUP" == "200" ]]; then
            log_i "Node group deleted successfully."
        else
            log_e "Node group was not deleted!"
            error=1
        fi
        
    done
    
    if [[ $error -eq 1 ]]; then
        log_e "One or more node groups was not deleted. Please check and delete Node group manualy!!!"
        exit 1
    fi
}

IFS=', ' read -r -a OLD_INAMES <<< "$OLD_INAMES"
$PATH_TO_TERRAFORM output -json sm_info |jq -r '.[]' > temp.txt

while read -r line
do
    iname=$(echo "$line" | awk '{print $1}')
    
    for old in "${!OLD_INAMES[@]}"; do
        if [[ "${iname}" == "${OLD_INAMES[$old]}-sm2" ]]; then
            SM_IP=$(echo "$line"| awk '{print $2}')
            log_i "Delete node group in ENV: ${iname}, SM IP: ${SM_IP}"
            get_node_groups_info "${iname}"
            delete_node_group "${iname}"
            break
        fi
    done
done < temp.txt