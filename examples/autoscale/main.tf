######################################################################################################################
# Example: Red5 Pro Stream Manager 2.0 Autoscale Deployment (Load Balancer with multiple Stream Manager 2.0 instances)
######################################################################################################################

locals {
  name                  = "red5pro-autoscale" # Name to be used on all the resources as identifier
  tenancy_ocid          = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  user_ocid             = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  fingerprint           = "00:11:22:33:44:55:66:77:aa:bb:cc:dd:ee:ff:gg:hh"
  private_key_path      = "./example_oracle_private_key.pem"
  oracle_compartment_id = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Existing Compartment OCID of Oracle Cloud Account
  oracle_region         = "us-ashburn-1"

  ssh_key_existing_private_key_path = "/PATH/TO/SSH/PRIVATE/KEY/example_private_key.pem" # Path to existing SSH private key
  ssh_key_existing_public_key_path  = "/PATH/TO/SSH/PUBLIC/KEY/example_pub_key.pem"      # Path to existing SSH Public key

  ssh_private_key = file(local.ssh_key_existing_private_key_path)
  ssh_public_key  = file(local.ssh_key_existing_public_key_path)

  path_to_red5pro_build = "./red5pro-server-0.0.0.b0-release.zip" # Absolute path or relative path to Red5 Pro server ZIP file

  red5pro_license_key        = "1111-2222-3333-4444" # Red5 Pro license key (https://account.red5.net/login)
  red5pro_api_key            = "example_key"         # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_enable         = false                 # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  node_image_instance_type   = "VM.Standard.E4.Flex" # Instance type for Red5 Pro Node image
  node_image_instance_ocpu   = 1                     # OCI Instance OCPU Count for Red5 Pro Node image (1 OCPU = 2 vCPU)
  node_image_instance_memory = 4                     # OCI Instance Memory size in GB for Red5 Pro Node image

  stream_manager_auth_user     = "example_user"     # Stream Manager 2.0 authentication user name
  stream_manager_auth_password = "example_password" # Stream Manager 2.0 authentication password
}


provider "oci" {
  region = local.oracle_region

  tenancy_ocid     = local.tenancy_ocid
  user_ocid        = local.user_ocid
  private_key_path = local.ssh_key_existing_private_key_path
  fingerprint      = local.fingerprint
}


# Create VCN
module "vcn" {
  source                = "../../module/vcn"
  type                  = "autoscale"
  name                  = local.name
  oracle_compartment_id = local.oracle_compartment_id
}

module "red5pro" {
  source                                           = "../../"
  type                                             = "autoscale" # Deployment type: cluster, autoscale
  name                                             = local.name  # Name to be used on all the resources as identifier
  subnet_id                                        = module.vcn.subnet_id
  red5pro_stream_manager_network_security_group_id = module.vcn.red5pro_stream_manager_network_security_group_id


  # Oracle Cloud Account Details
  oracle_region           = local.oracle_region         # Current region code name of Oracle Cloud Account, https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm
  oracle_compartment_id   = local.oracle_compartment_id # Existing Compartment OCID of Oracle Cloud Account
  oracle_tenancy_ocid     = local.tenancy_ocid
  oracle_user_ocid        = local.user_ocid
  oracle_private_key_path = local.ssh_key_existing_private_key_path
  oracle_fingerprint      = local.fingerprint

  kafka_standalone_instance_create = true


  # SSH key configuration
  ssh_key_use_existing              = true # true - use existing SSH key, false - create new SSH key
  ssh_key_existing_private_key_path = local.ssh_key_existing_private_key_path
  ssh_key_existing_public_key_path  = local.ssh_key_existing_public_key_path

  # Red5 Pro general configuration
  red5pro_license_key = local.red5pro_license_key

  red5pro_kafka_network_security_group_id = module.vcn.red5pro_kafka_network_security_group_id

  # Stream Manager 2.0 instance configuration
  stream_manager_instance_type        = "VM.Standard.E4.Flex"              # OCI Instance type for Stream Manager
  stream_manager_instance_ocpu        = 4                                  # OCI Instance OCPU Count for Stream Manager(1 OCPU = 2 vCPU)
  stream_manager_instance_memory      = 16                                 # OCI Instance Memory size in GB for Stream Manager
  stream_manager_instance_volume_size = 50                                 # Volume size in GB for Stream Manager
  stream_manager_auth_user            = local.stream_manager_auth_user     # Stream Manager 2.0 authentication user name
  stream_manager_auth_password        = local.stream_manager_auth_password # Stream Manager 2.0 authentication password

  # Stream Manager 2.0 server HTTPS (SSL) certificate configuration
  https_ssl_certificate = "none" # none - do not use HTTPS/SSL certificate, letsencrypt - create new Let's Encrypt HTTPS/SSL certificate, imported - use existing HTTPS/SSL certificate

  # Example of Let's Encrypt HTTPS/SSL certificate configuration - please uncomment and provide your domain name and email
  # https_ssl_certificate = "letsencrypt"
  # https_ssl_certificate_domain_name = "red5pro.example.com"
  # https_ssl_certificate_email = "email@example.com"

  # Example of imported HTTPS/SSL certificate configuration - please uncomment and provide your domain name, certificate and key paths
  # https_ssl_certificate             = "imported"
  # https_ssl_certificate_domain_name = "red5pro.example.com"
  # https_ssl_certificate_cert_path   = "/PATH/TO/SSL/CERT/fullchain.pem"
  # https_ssl_certificate_key_path    = "/PATH/TO/SSL/KEY/privkey.pem"
}

module "node-image" {
  source                                 = "../../module/node-image"
  name                                   = local.name
  ssh_public_key                         = local.ssh_public_key
  ssh_private_key                        = local.ssh_private_key
  subnet_id                              = module.vcn.subnet_id
  red5pro_node_network_security_group_id = module.vcn.red5pro_node_network_security_group_id
  path_to_red5pro_build                  = local.path_to_red5pro_build
  red5pro_license_key                    = local.red5pro_license_key
  red5pro_api_enable                     = local.red5pro_api_enable
  red5pro_api_key                        = local.red5pro_api_key
  node_image_instance_type               = local.node_image_instance_type
  node_image_instance_ocpu               = local.node_image_instance_ocpu
  node_image_instance_memory             = local.node_image_instance_memory
  oracle_compartment_id                  = local.oracle_compartment_id
  oracle_tenancy_ocid                    = local.tenancy_ocid
  oracle_user_ocid                       = local.user_ocid
  oracle_private_key_path                = local.private_key_path
  oracle_fingerprint                     = local.fingerprint
  oracle_region                          = local.oracle_region
}

module "node-group" {
  depends_on = [module.node-image, module.vcn, module.red5pro]
  source     = "../../module/node-group"
  name       = local.name

  red5pro_node_network_security_group = module.vcn.red5pro_node_network_security_group
  subnet_name                         = module.vcn.subnet_name
  red5pro_node_image_name             = module.node-image.red5pro_node_image
  stream_manager_ip                   = module.red5pro.stream_manager_ip
  stream_manager_auth_user            = local.stream_manager_auth_user     # Stream Manager 2.0 authentication user name
  stream_manager_auth_password        = local.stream_manager_auth_password # Stream Manager 2.0 authentication password
  oracle_region                       = local.oracle_region

  # Extra configuration for Red5 Pro autoscaling nodes
  # Webhooks configuration - (Optional) https://www.red5.net/docs/special/webhooks/overview/
  node_config_webhooks = {
    enable           = false,
    target_nodes     = ["origin", "edge", "transcoder"],
    webhook_endpoint = "https://test.webhook.app/api/v1/broadcast/webhook"
  }
  # Round trip authentication configuration - (Optional) https://www.red5.net/docs/special/authplugin/simple-auth/
  node_config_round_trip_auth = {
    enable                   = false,
    target_nodes             = ["origin", "edge", "transcoder"],
    auth_host                = "round-trip-auth.example.com",
    auth_port                = 443,
    auth_protocol            = "https://",
    auth_endpoint_validate   = "/validateCredentials",
    auth_endpoint_invalidate = "/invalidateCredentials"
  }
  # Restreamer configuration - (Optional) https://www.red5.net/docs/special/restreamer/overview/
  node_config_restreamer = {
    enable               = false,
    target_nodes         = ["origin", "transcoder"],
    restreamer_tsingest  = true,
    restreamer_ipcam     = true,
    restreamer_whip      = true,
    restreamer_srtingest = true
  }
  # Social Pusher configuration - (Optional) https://www.red5.net/docs/development/social-media-plugin/rest-api/
  node_config_social_pusher = {
    enable       = false,
    target_nodes = ["origin", "edge", "transcoder"],
  }

  node_group_origins_min               = 1                         # Number of minimum Origins
  node_group_origins_max               = 20                        # Number of maximum Origins
  node_group_origins_instance_type     = "VM.Standard.E4.Flex-1-4" # Origins OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_origins_volume_size       = 50                        # Volume size in GB for Origins
  node_group_edges_min                 = 1                         # Number of minimum Edges
  node_group_edges_max                 = 40                        # Number of maximum Edges
  node_group_edges_instance_type       = "VM.Standard.E4.Flex-1-4" # Edges OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_edges_volume_size         = 50                        # Volume size in GB for Edges
  node_group_transcoders_min           = 0                         # Number of minimum Transcoders
  node_group_transcoders_max           = 20                        # Number of maximum Transcoders
  node_group_transcoders_instance_type = "VM.Standard.E4.Flex-1-4" # Transcoders OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_transcoders_volume_size   = 50                        # Volume size in GB for Transcoders
  node_group_relays_min                = 0                         # Number of minimum Relays
  node_group_relays_max                = 20                        # Number of maximum Relays
  node_group_relays_instance_type      = "VM.Standard.E4.Flex-1-4" # Relays OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_relays_volume_size        = 50                        # Volume size in GB for Relays

}

output "module_output" {
  value = module.red5pro
}
output "vcn_output" {
  value = module.vcn
}
output "node_group_output" {
  value = module.node-group
}
