#!/bin/bash

current_directory=$(pwd)

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
log_f() {
    log
    printf "\033[0;34m [INFO]  --- %s \033[0m\n" "${@}"
}

multi_region_nodegroup_json_template(){
    NODEGROUP_JSON='"NODE_SUBGROUP_NAME":{"subGroupName":"NODE_SUBGROUP_NAME","groupType":"region","cloudProperties":"region=NODE_GROUP_REGION","rulesByRole":{"allinone":{"nodeRoleName":"allinone","min":1,"max":1,"increment":1,"outExpression":"(min(connections.client) / 200) > 1.0","inExpression":"avg(connections.client) < 10","capacityRankingExpression":"(connections.client / 200) * 10","capacityLimitExpression":"200"}}}'
    
    json_blocks=()

    for region in "${regions[@]}"; do
        NODE_SUBGROUP_NAME=$(echo "$region" | awk -F'-' '{print $2}')
        json_block=$(echo "$NODEGROUP_JSON" | sed "s|NODE_SUBGROUP_NAME|$NODE_SUBGROUP_NAME|g" | sed "s|NODE_GROUP_REGION|$region|g")
        json_blocks+=("$json_block")
    done

    for ((i = 0; i < ${#json_blocks[@]}; i++)); do
        if [ $i -eq $((${#json_blocks[@]} - 1)) ]; then
            final_block+="$(echo "${json_blocks[$i]}")"
        else
            final_block+="$(echo "${json_blocks[$i]}"), "
        fi
    done
    echo "$final_block"
}

get_variables(){
    
    $PATH_TO_TERRAFORM output -json sm_info |jq -r '.[]' > temp.txt
    
    while read -r line
    do
        iname=$(echo "$line" | awk '{print $1}')
        vars_found=0
        if [[ "${iname}" == "${NEW_INAME}-sm2" ]]; then
            SM_IP=$(echo "$line"| awk '{print $2}')
            SM_REGION=$(echo "$line"| awk '{print $5}')
            log_i "Found ENV: ${iname}, SM IP: ${SM_IP}, SM Region: ${SM_REGION}"
            vars_found=1
            break
        fi
    done < temp.txt
    
    if [[ $vars_found == 0 ]]; then
        log_e "Vars was not found, please check variable INAME: $NEW_INAME!!! Exit."
        exit 1
    fi
}

prepare_json_templates(){

    case $NODE_GROUP_TYPE in
        o)  NODEGROUP_NAME="$NEW_INAME-o"
            JSON_TEMPLATE="$current_directory/ci-nodegroup-json-templates/ci_nodegroup_o.json"

            local node_group_name_pattern='NODEGROUP_NAME'
            local node_group_name_new="${NODEGROUP_NAME}"

            local node_env_pattern='NODE_ENVIRONMENT'
            local node_env_new="${NODE_ENVIRONMENT}"

            local node_subnet_pattern='NODE_SUBNET_NAME'
            local node_subnet_new="${NODE_SUBNET_NAME}"

            local node_security_group_pattern='NODE_SECURITY_GROUP'
            local node_security_group_new="${NODE_SECURITY_GROUP}"

            local node_volume_size_pattern='NODE_VOLUME_SIZE'
            local node_volume_size_new="${NODE_VOLUME_SIZE}"

            local node_image_name_pattern='NODE_IMAGE_NAME'
            local node_image_name_new="${NODE_IMAGE_NAME}"

            local node_instance_type_pattern='NODE_INSTANCE_TYPE'
            local node_instance_type_new="${NODE_INSTANCE_TYPE}"

            local node_subgroup_name_pattern='NODE_SUBGROUP_NAME'
            local node_subgroup_name_new="${NODE_SUBGROUP_NAME}"

            local node_group_region_pattern='NODE_GROUP_REGION'
            local node_group_region_new="${NODE_GROUP_REGION}"

            local node_group_origin_pattern='"NODE_GROUP_ORIGIN"'
            local node_group_origin_new="${NODE_GROUP_ORIGIN}"

            sed -i -e "s|$node_group_origin_pattern|$node_group_origin_new|" -e "s|$node_group_name_pattern|$node_group_name_new|" -e "s|$node_env_pattern|$node_env_new|" -e "s|$node_subnet_pattern|$node_subnet_new|" -e "s|$node_security_group_pattern|$node_security_group_new|" -e "s|$node_volume_size_pattern|$node_volume_size_new|" -e "s|$node_image_name_pattern|$node_image_name_new|" -e "s|$node_instance_type_pattern|$node_instance_type_new|" -e "s|$node_subgroup_name_pattern|$node_subgroup_name_new|" -e "s|$node_group_region_pattern|$node_group_region_new|" "$JSON_TEMPLATE"
            cat $JSON_TEMPLATE
            JWT=$(create_jwT_token)
            create_new_node_group
        ;;
        oe) NODEGROUP_NAME="$NEW_INAME-oe"
            JSON_TEMPLATE="$current_directory/ci-nodegroup-json-templates/ci_nodegroup_oe.json"

            local node_group_name_pattern='NODEGROUP_NAME'
            local node_group_name_new="${NODEGROUP_NAME}"

            local node_env_pattern='NODE_ENVIRONMENT'
            local node_env_new="${NODE_ENVIRONMENT}"

            local node_subnet_pattern='NODE_SUBNET_NAME'
            local node_subnet_new="${NODE_SUBNET_NAME}"

            local node_security_group_pattern='NODE_SECURITY_GROUP'
            local node_security_group_new="${NODE_SECURITY_GROUP}"

            local node_volume_size_pattern='NODE_VOLUME_SIZE'
            local node_volume_size_new="${NODE_VOLUME_SIZE}"

            local node_image_name_pattern='NODE_IMAGE_NAME'
            local node_image_name_new="${NODE_IMAGE_NAME}"

            local node_instance_type_pattern='NODE_INSTANCE_TYPE'
            local node_instance_type_new="${NODE_INSTANCE_TYPE}"

            local node_subgroup_name_pattern='NODE_SUBGROUP_NAME'
            local node_subgroup_name_new="${NODE_SUBGROUP_NAME}"

            local node_group_region_pattern='NODE_GROUP_REGION'
            local node_group_region_new="${NODE_GROUP_REGION}"      

            local node_group_origin_pattern='"NODE_GROUP_ORIGIN"'
            local node_group_origin_new="${NODE_GROUP_ORIGIN}"

            local node_group_edge_pattern='"NODE_GROUP_EDGE"'
            local node_group_edge_new="${NODE_GROUP_EDGE}"      

            sed -i -e "s|$node_group_origin_pattern|$node_group_origin_new|" -e "s|$node_group_edge_pattern|$node_group_edge_new|" -e "s|$node_group_name_pattern|$node_group_name_new|" -e "s|$node_env_pattern|$node_env_new|" -e "s|$node_subnet_pattern|$node_subnet_new|" -e "s|$node_security_group_pattern|$node_security_group_new|" -e "s|$node_volume_size_pattern|$node_volume_size_new|" -e "s|$node_image_name_pattern|$node_image_name_new|" -e "s|$node_instance_type_pattern|$node_instance_type_new|" -e "s|$node_subgroup_name_pattern|$node_subgroup_name_new|" -e "s|$node_group_region_pattern|$node_group_region_new|" "$JSON_TEMPLATE"
            cat $JSON_TEMPLATE
            JWT=$(create_jwT_token)
            create_new_node_group
        ;;
        oet) NODEGROUP_NAME="$NEW_INAME-oet"
             JSON_TEMPLATE="$current_directory/ci-nodegroup-json-templates/ci_nodegroup_oet.json"

            local node_group_name_pattern='NODEGROUP_NAME'
            local node_group_name_new="${NODEGROUP_NAME}"

            local node_env_pattern='NODE_ENVIRONMENT'
            local node_env_new="${NODE_ENVIRONMENT}"

            local node_subnet_pattern='NODE_SUBNET_NAME'
            local node_subnet_new="${NODE_SUBNET_NAME}"

            local node_security_group_pattern='NODE_SECURITY_GROUP'
            local node_security_group_new="${NODE_SECURITY_GROUP}"

            local node_volume_size_pattern='NODE_VOLUME_SIZE'
            local node_volume_size_new="${NODE_VOLUME_SIZE}"

            local node_image_name_pattern='NODE_IMAGE_NAME'
            local node_image_name_new="${NODE_IMAGE_NAME}"

            local node_instance_type_pattern='NODE_INSTANCE_TYPE'
            local node_instance_type_new="${NODE_INSTANCE_TYPE}"

            local node_subgroup_name_pattern='NODE_SUBGROUP_NAME'
            local node_subgroup_name_new="${NODE_SUBGROUP_NAME}"

            local node_group_region_pattern='NODE_GROUP_REGION'
            local node_group_region_new="${NODE_GROUP_REGION}"

            local node_group_origin_pattern='"NODE_GROUP_ORIGIN"'
            local node_group_origin_new="${NODE_GROUP_ORIGIN}"

            local node_group_edge_pattern='"NODE_GROUP_EDGE"'
            local node_group_edge_new="${NODE_GROUP_EDGE}"

            local node_group_transcoder_pattern='"NODE_GROUP_TRANSCODER"'
            local node_group_transcoder_new="${NODE_GROUP_TRANSCODER}"

            sed -i -e "s|$node_group_origin_pattern|$node_group_origin_new|" -e "s|$node_group_edge_pattern|$node_group_edge_new|" -e "s|$node_group_transcoder_pattern|$node_group_transcoder_new|" -e "s|$node_group_name_pattern|$node_group_name_new|" -e "s|$node_env_pattern|$node_env_new|" -e "s|$node_subnet_pattern|$node_subnet_new|" -e "s|$node_security_group_pattern|$node_security_group_new|" -e "s|$node_volume_size_pattern|$node_volume_size_new|" -e "s|$node_image_name_pattern|$node_image_name_new|" -e "s|$node_instance_type_pattern|$node_instance_type_new|" -e "s|$node_subgroup_name_pattern|$node_subgroup_name_new|" -e "s|$node_group_region_pattern|$node_group_region_new|" "$JSON_TEMPLATE"
            cat $JSON_TEMPLATE
            JWT=$(create_jwT_token)
            create_new_node_group
        ;;
        multi) NODEGROUP_NAME="$NEW_INAME-multi"
             JSON_TEMPLATE="$current_directory/ci-nodegroup-json-templates/ci_nodegroup_multi_region.json"

            local node_group_name_pattern='NODEGROUP_NAME'
            local node_group_name_new="${NODEGROUP_NAME}"

            local node_env_pattern='NODE_ENVIRONMENT'
            local node_env_new="${NODE_ENVIRONMENT}"

            local node_subnet_pattern='NODE_SUBNET_NAME'
            local node_subnet_new="${NODE_SUBNET_NAME}"

            local node_security_group_pattern='NODE_SECURITY_GROUP'
            local node_security_group_new="${NODE_SECURITY_GROUP}"

            local node_volume_size_pattern='NODE_VOLUME_SIZE'
            local node_volume_size_new="${NODE_VOLUME_SIZE}"

            local node_image_name_pattern='NODE_IMAGE_NAME'
            local node_image_name_new="${NODE_IMAGE_NAME}"

            local node_instance_type_pattern='NODE_INSTANCE_TYPE'
            local node_instance_type_new="${NODE_INSTANCE_TYPE}"

            # Creating Nodegroup configuration for multiple region
            local multi_region_json_patteren='MULTI_NODEGROUP'
            local multi_region_json_new=$(multi_region_nodegroup_json_template)

            sed -i -e "s|$node_group_name_pattern|$node_group_name_new|" -e "s|$node_env_pattern|$node_env_new|" -e "s|$node_subnet_pattern|$node_subnet_new|" -e "s|$node_security_group_pattern|$node_security_group_new|" -e "s|$node_volume_size_pattern|$node_volume_size_new|" -e "s|$node_image_name_pattern|$node_image_name_new|" -e "s|$node_instance_type_pattern|$node_instance_type_new|" -e "s|$multi_region_json_patteren|$multi_region_json_new|" "$JSON_TEMPLATE"
            cat $JSON_TEMPLATE
            JWT=$(create_jwT_token)
            create_new_node_group
        ;;
        *) log_e "Node group type was not found: $NODE_GROUP_TYPE, EXIT..."; exit 1
    esac
}

check_stream_manager(){
    log_i "Checking Stream Manager status..."

    SM_STATUS_URL="https://$iname.red5pro.net:443/red5"
    for i in {1..5}; do
        curl -s -m 5 -o /dev/null -w "%{http_code}" "$SM_STATUS_URL" > /dev/null
        if [ $? -eq 0 ]; then
            log_i "Stream Manager is running."
            break
        else
            log_w "Cycle $i - Stream Manager is not running!"
            if [ "$i" -eq 5 ]; then
                log_e "EXIT..."
                exit 1
            fi
        fi
        sleep 30
    done
}

create_jwT_token(){
    SM_STATUS_URL="https://$R5AS_AUTH_USER:$R5AS_AUTH_PASS@$iname.red5pro.net:443/as/v1/auth/login"
    echo $(curl -s --location --request PUT "$SM_STATUS_URL" --header 'Content-Type: application/json' | jq -r '.token')
}

create_new_node_group(){
    log_i "Creating a new Node Group with name: $NODEGROUP_NAME"

    CREATE_NODE_GROUP_URL="https://$iname.red5pro.net:443/as/v1/admin/nodegroup"
    
    for i in {1..5}; do
        resp=$(curl -s -o /dev/null -w "%{http_code}" --location --request POST "$CREATE_NODE_GROUP_URL" --header "Authorization: Bearer ${JWT}" --header 'Content-Type: application/json' --data "@$JSON_TEMPLATE")
        if [[ "$resp" == "200" ]]; then
            log_i "Node group created successfully."
            break
        else
            log_w "Cycle $i - Node group not created!"
            if [ "$i" -eq 5 ]; then
                log_e "Node group was not created!!! EXIT..."
                exit 1
            fi
        fi
        sleep 30
    done
}

IFS=',' read -r -a regions <<< "$NODE_GROUP_REGION"
if [[ ${#regions[@]} -gt 1 ]]; then
    NODE_GROUP_TYPE="multi"
fi

get_variables
check_stream_manager
prepare_json_templates