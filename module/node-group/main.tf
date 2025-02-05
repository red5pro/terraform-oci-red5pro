
################################################################################
# Create/Delete node group (Stream Manager API)
################################################################################
resource "time_sleep" "wait_for_delete_nodegroup" {
  depends_on = [
  ]
  destroy_duration = "90s"
}

resource "null_resource" "node_group" {
  triggers = {
    trigger_name   = "node-group-trigger"
    SM_IP          = "${var.stream_manager_ip}"
    R5AS_AUTH_USER = "${var.stream_manager_auth_user}"
    R5AS_AUTH_PASS = "${var.stream_manager_auth_password}"
  }
  provisioner "local-exec" {
    when    = create
    command = "bash ${abspath(path.module)}/../../red5pro-installer/r5p_create_node_group.sh"
    environment = {
      SM_IP                                    = "${var.stream_manager_ip}"
      R5AS_AUTH_USER                           = "${var.stream_manager_auth_user}"
      R5AS_AUTH_PASS                           = "${var.stream_manager_auth_password}"
      NODE_GROUP_REGION                        = "${var.oracle_region}"
      NODE_ENVIRONMENT                         = "${var.name}"
      NODE_SUBNET_NAME                         = "${var.subnet_name}"
      NODE_SECURITY_GROUP_NAME                 = "${var.red5pro_node_network_security_group}"
      NODE_IMAGE_NAME                          = "${var.red5pro_node_image_name}"
      ORIGINS_MIN                              = "${var.node_group_origins_min}"
      ORIGINS_MAX                              = "${var.node_group_origins_max}"
      ORIGIN_INSTANCE_TYPE                     = "${var.node_group_origins_instance_type}"
      ORIGIN_VOLUME_SIZE                       = "${var.node_group_origins_volume_size}"
      EDGES_MIN                                = "${var.node_group_edges_min}"
      EDGES_MAX                                = "${var.node_group_edges_max}"
      EDGE_INSTANCE_TYPE                       = "${var.node_group_edges_instance_type}"
      EDGE_VOLUME_SIZE                         = "${var.node_group_edges_volume_size}"
      TRANSCODERS_MIN                          = "${var.node_group_transcoders_min}"
      TRANSCODERS_MAX                          = "${var.node_group_transcoders_max}"
      TRANSCODER_INSTANCE_TYPE                 = "${var.node_group_transcoders_instance_type}"
      TRANSCODER_VOLUME_SIZE                   = "${var.node_group_transcoders_volume_size}"
      RELAYS_MIN                               = "${var.node_group_relays_min}"
      RELAYS_MAX                               = "${var.node_group_relays_max}"
      RELAY_INSTANCE_TYPE                      = "${var.node_group_relays_instance_type}"
      RELAY_VOLUME_SIZE                        = "${var.node_group_relays_volume_size}"
      PATH_TO_JSON_TEMPLATES                   = "${abspath(path.module)}/../../red5pro-installer/nodegroup-json-templates"
      NODE_ROUND_TRIP_AUTH_ENABLE              = "${var.node_config_round_trip_auth.enable}"
      NODE_ROUNT_TRIP_AUTH_TARGET_NODES        = "${join(",", var.node_config_round_trip_auth.target_nodes)}"
      NODE_ROUND_TRIP_AUTH_HOST                = "${var.node_config_round_trip_auth.auth_host}"
      NODE_ROUND_TRIP_AUTH_PORT                = "${var.node_config_round_trip_auth.auth_port}"
      NODE_ROUND_TRIP_AUTH_PROTOCOL            = "${var.node_config_round_trip_auth.auth_protocol}"
      NODE_ROUND_TRIP_AUTH_ENDPOINT_VALIDATE   = "${var.node_config_round_trip_auth.auth_endpoint_validate}"
      NODE_ROUND_TRIP_AUTH_ENDPOINT_INVALIDATE = "${var.node_config_round_trip_auth.auth_endpoint_invalidate}"
      NODE_WEBHOOK_ENABLE                      = "${var.node_config_webhooks.enable}"
      NODE_WEBHOOK_TARGET_NODES                = "${join(",", var.node_config_webhooks.target_nodes)}"
      NODE_WEBHOOK_ENDPOINT                    = "${var.node_config_webhooks.webhook_endpoint}"
      NODE_SOCIAL_PUSHER_ENABLE                = "${var.node_config_social_pusher.enable}"
      NODE_SOCIAL_PUSHER_TARGET_NODES          = "${join(",", var.node_config_social_pusher.target_nodes)}"
      NODE_RESTREAMER_ENABLE                   = "${var.node_config_restreamer.enable}"
      NODE_RESTREAMER_TARGET_NODES             = "${join(",", var.node_config_restreamer.target_nodes)}"
      NODE_RESTREAMER_TSINGEST                 = "${var.node_config_restreamer.restreamer_tsingest}"
      NODE_RESTREAMER_IPCAM                    = "${var.node_config_restreamer.restreamer_ipcam}"
      NODE_RESTREAMER_WHIP                     = "${var.node_config_restreamer.restreamer_whip}"
      NODE_RESTREAMER_SRTINGEST                = "${var.node_config_restreamer.restreamer_srtingest}"
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "bash ${abspath(path.module)}/../../red5pro-installer/r5p_delete_node_group.sh '${self.triggers.SM_IP}' '${self.triggers.R5AS_AUTH_USER}' '${self.triggers.R5AS_AUTH_PASS}'"
  }

  depends_on = [time_sleep.wait_for_delete_nodegroup]

  #   lifecycle {
  #     precondition {
  #       condition     = var.node_image_create == true
  #       error_message = "ERROR! Node group creation requires the creation of a Node image for the node group. Please set the 'node_image_create' variable to 'true' and re-run the Terraform apply."
  #     }
  #   }
}
