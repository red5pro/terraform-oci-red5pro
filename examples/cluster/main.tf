##############################################################################
# Example: Red5 Pro Stream Manager 2.0 Cluster Deployment
##############################################################################

terraform {
  required_version = ">= 1.7.5"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.16"
    }
  }
}

provider "oci" {
  region           = "us-ashburn-1"
  tenancy_ocid     = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  user_ocid        = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  fingerprint      = "00:11:22:33:44:55:66:77:aa:bb:cc:dd:ee:ff:gg:hh"
  private_key_path = "./example_oracle_private_key.pem"
}

module "red5pro" {
  source                = "../../"
  type                  = "cluster"                               # Deployment type: standalone, cluster, autoscale, vcn
  name                  = "red5pro-cluster"                       # Name to be used on all the resources as identifier
  path_to_red5pro_build = "./red5pro-server-0.0.0.b0-release.zip" # Absolute path or relative path to Red5 Pro server ZIP file

  # Oracle Cloud Account Details
  oracle_compartment_id   = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Existing Compartment OCID of Oracle Cloud Account
  oracle_tenancy_ocid     = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"     # Existing Tenancy OCID of Oracle Cloud Account
  oracle_user_ocid        = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"        # Existing User OCID of Oracle Cloud Account
  oracle_fingerprint      = "00:11:22:33:44:55:66:77:aa:bb:cc:dd:ee:ff:gg:hh"                                     # Existing SSH based API key fingerprint of Oracle Cloud Account
  oracle_private_key_path = "./example_oracle_private_key.pem"                                                    # Path to existing SSH private key of Oracle Cloud Account
  oracle_region           = "us-ashburn-1"                                                                        # Current region code name of Oracle Cloud Account, https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm

  # SSH key configuration
  ssh_key_use_existing              = false                                              # true - use existing SSH key, false - create new SSH key
  ssh_key_existing_private_key_path = "/PATH/TO/SSH/PRIVATE/KEY/example_private_key.pem" # Path to existing SSH private key
  ssh_key_existing_public_key_path  = "/PATH/TO/SSH/PUBLIC/KEY/example_pub_key.pem"      # Path to existing SSH Public key

  # Red5 Pro general configuration
  red5pro_license_key = "1111-2222-3333-4444" # Red5 Pro license key (https://account.red5.net/login)
  red5pro_api_enable  = true                  # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_key     = "example_key"         # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)

  # Stream Manager 2.0 instance configuration
  stream_manager_instance_type        = "VM.Standard.E4.Flex"      # OCI Instance type for Stream Manager
  stream_manager_instance_ocpu        = 4                          # OCI Instance OCPU Count for Stream Manager(1 OCPU = 2 vCPU)
  stream_manager_instance_memory      = 16                         # OCI Instance Memory size in GB for Stream Manager
  stream_manager_instance_volume_size = 50                         # Volume size in GB for Stream Manager (minimum 50GB)
  stream_manager_auth_user            = "example_user"             # Stream Manager 2.0 authentication user name
  stream_manager_auth_password        = "example_password"         # Stream Manager 2.0 authentication password
  stream_manager_proxy_user           = "example_proxy_user"       # Stream Manager 2.0 proxy user name
  stream_manager_proxy_password       = "example_proxy_password"   # Stream Manager 2.0 proxy password
  stream_manager_spatial_user         = "example_spatial_user"     # Stream Manager 2.0 spatial user name
  stream_manager_spatial_password     = "example_spatial_password" # Stream Manager 2.0 spatial password
  stream_manager_version              = "latest"                   # Stream Manager 2.0 docker images version (latest, 14.1.0, 14.1.1, etc.) - https://hub.docker.com/r/red5pro/as-admin/tags

  # Kafka standalone instance configuration - (Optional)
  kafka_standalone_instance_create      = false                 # true - create new Kafka standalone instance, false - not create new Kafka standalone instance and use Kafka on the Stream Manager 2.0 instance
  kafka_standalone_instance_type        = "VM.Standard.E4.Flex" # OCI Instance type for Kafka standalone instance
  kafka_standalone_instance_ocpu        = 1                     # OCI Instance OCPU Count for Kafka standalone instance(1 OCPU = 2 vCPU)
  kafka_standalone_instance_memory      = 16                    # OCI Instance Memory size in GB for Kafka standalone instance
  kafka_standalone_instance_volume_size = 50                    # Volume size in GB for Kafka standalone instance (minimum 50GB)

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

  # Red5 Pro autoscaling Node image configuration
  node_image_create          = true                  # Default: true for Autoscaling and Cluster, true - create new Red5 Pro Node image, false - do not create new Red5 Pro Node image
  node_image_instance_type   = "VM.Standard.E4.Flex" # Instance type for Red5 Pro Node image
  node_image_instance_ocpu   = 1                     # OCI Instance OCPU Count for Red5 Pro Node image (1 OCPU = 2 vCPU)
  node_image_instance_memory = 4                     # OCI Instance Memory size in GB for Red5 Pro Node image

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

  # Red5 Pro autoscaling Node group - (Optional) https://www.red5.net/docs/red5-pro/users-guide/stream-manager-2-0/stream-manager-2-node-group-config/
  node_group_create                       = true                     # Linux or Mac OS only. true - create new Node group, false - not create new Node group
  
  node_group_origins_min                  = 1                         # Number of minimum Origins
  node_group_origins_max                  = 20                        # Number of maximum Origins
  node_group_origins_instance_type        = "VM.Standard.E4.Flex-1-4" # Origins OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_origins_volume_size          = 50                        # Volume size in GB for Origins (minimum 50GB)
  node_group_origins_connection_limit     = 20                        # Maximum number of publishers to the origin server
  
  node_group_edges_min                    = 1                         # Number of minimum Edges
  node_group_edges_max                    = 40                        # Number of maximum Edges
  node_group_edges_instance_type          = "VM.Standard.E4.Flex-1-4" # Edges OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_edges_volume_size            = 50                        # Volume size in GB for Edges (minimum 50GB)
  node_group_edges_connection_limit       = 200                       # Maximum number of subscribers to the edge server
  
  node_group_transcoders_min              = 0                         # Number of minimum Transcoders
  node_group_transcoders_max              = 20                        # Number of maximum Transcoders
  node_group_transcoders_instance_type    = "VM.Standard.E4.Flex-1-4" # Transcoders OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_transcoders_volume_size      = 50                        # Volume size in GB for Transcoders (minimum 50GB)
  node_group_transcoders_connection_limit = 20                        # Maximum number of publishers to the transcoder server
  
  node_group_relays_min                   = 0                         # Number of minimum Relays
  node_group_relays_max                   = 20                        # Number of maximum Relays
  node_group_relays_instance_type         = "VM.Standard.E4.Flex-1-4" # Relays OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_relays_volume_size           = 50                        # Volume size in GB for Relays (minimum 50GB)
}

output "module_output" {
  value = module.red5pro
}
