##############################################################################
# Example: Red5 Pro Cluster (Oracle Cloud VM Instance)
##############################################################################

provider "oci" {
  region           = "us-ashburn-1"
  tenancy_ocid     = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  user_ocid        = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  fingerprint      = "00:11:22:33:44:55:66:77:aa:bb:cc:dd:ee:ff:gg:hh"
  private_key_path = "./example_oracle_private_key.pem"
}

module "red5pro_cluster" {
  source                                = "../../"
  type                                  = "cluster"                                # Deployment type: single, cluster, autoscaling
  name                                  = "red5pro-cluster"                        # Name to be used on all the resources as identifier
  ubuntu_version                        = "22.04"                                  # Ubuntu version to be used for machine, it can either be 20.04 or 22.04
  path_to_red5pro_build                 = "./red5pro-server-0.0.0.b0-release.zip"  # Absolute path or relative path to Red5 Pro server ZIP file
  path_to_terraform_cloud_controller    = "./terraform-cloud-controller-0.0.0.jar" # Absolute path or relative path to Terraform Cloud Controller JAR file
  path_to_terraform_service_build       = "./terraform-service-0.0.0.zip"

  # Oracle Cloud Account Details
  oracle_compartment_id   = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Existing Compartment OCID of Oracle Cloud Account
  oracle_tenancy_ocid     = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"     # Existing Tenancy OCID of Oracle Cloud Account
  oracle_user_ocid        = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"        # Existing User OCID of Oracle Cloud Account
  oracle_fingerprint      = "00:11:22:33:44:55:66:77:aa:bb:cc:dd:ee:ff:gg:hh"                                     # Existing SSH based API key fingerprint of Oracle Cloud Account
  oracle_private_key_path = "./example_oracle_private_key.pem"                                                    # Path to existing SSH private key of Oracle Cloud Account
  oracle_region           = "us-ashburn-1"                                                                        # Current region code name of Oracle Cloud Account, https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm

  # SSH key configuration
  ssh_key_create       = true
  ssh_private_key_path = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_pri_key.pem" # Path to existing SSH private key
  ssh_public_key_path  = "/PATH/TO/EXISTING/SSH/PRIVATE/KEY/example_pub_key.pem" # Path to existing SSH Public key

  # MySQL DB configuration
  mysql_db_system_create = false                        # true - create new MySQL DB System instance, false - install local MySQL server on the Stream Manager OCI instance
  mysql_shape_name       = "MySQL.VM.Standard.E3.1.8GB" # Instance type for Oracle Cloud MySQL DB system instance
  mysql_user_name        = "exampleuser"                # MySQL username
  mysql_password         = "Examplepass1!"                # MySQL password (The password for the administrative user. The password must be between 8 and 32 characters long, and must contain at least 1 numeric character, 1 lowercase character, 1 uppercase character, and 1 special (nonalphanumeric) character.)
  mysql_port             = 3306                         # MySQL port

  # Terraform Service configuration
  terraform_service_instance_create = true
  terraform_service_instance_type   = "VM.Standard.E4.Flex"
  terraform_service_instance_ocpu   = 2
  terraform_service_instance_memory = 8
  terraform_service_api_key         = "examplekey"
  terraform_service_parallelism     = 10

  # Stream Manager HTTPS/SSL certificate configuration
  https_letsencrypt_enable                  = true                  # true - create new Let's Encrypt HTTPS/SSL certificate, false - use Red5 Pro server without HTTPS/SSL certificate
  https_letsencrypt_certificate_domain_name = "red5pro.example.com" # Domain name for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_email       = "email@example.com"   # Email for Let's Encrypt SSL certificate
  https_letsencrypt_certificate_password    = "examplepass"         # Password for Let's Encrypt SSL certificate

  # Stream Manager configuration
  stream_manager_instance_type   = "VM.Standard.E4.Flex" # OCI Instance type for Stream Manager
  stream_manager_instance_ocpu   = 2                     # OCI Instance OCPU Count for Stream Manager(1 OCPU = 2 vCPU)
  stream_manager_instance_memory = 8                     # OCI Instance Memory size in GB for Stream Manager
  stream_manager_api_key         = "examplekey"          # API key for Stream Manager

  # Red5 Pro general configuration
  red5pro_license_key = "1111-2222-3333-4444" # Red5 Pro license key (https://account.red5.net/login)
  red5pro_cluster_key = "examplekey"          # Red5 Pro cluster key
  red5pro_api_enable  = true                  # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_key     = "examplekey"          # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)

  # Red5 Pro autoscaling Origin node image configuration
  origin_image_create                                      = true                          # Default: true for Autoscaling and Cluster, true - create new Origin node image, false - not create new Origin node image
  origin_image_instance_type                               = "VM.Standard.E4.Flex"         # Instance type for Origin node image
  origin_image_instance_ocpu                               = 1                             # OCI Instance OCPU Count for Origin node image(1 OCPU = 2 vCPU)
  origin_image_instance_memory                             = 4                             # OCI Instance Memory size in GB for Origin node image
  origin_image_red5pro_inspector_enable                    = false                         # true - enable Red5 Pro server inspector, false - disable Red5 Pro server inspector (https://www.red5.net/docs/troubleshooting/inspector/overview/)
  origin_image_red5pro_restreamer_enable                   = false                         # true - enable Red5 Pro server restreamer, false - disable Red5 Pro server restreamer (https://www.red5.net/docs/special/restreamer/overview/)
  origin_image_red5pro_socialpusher_enable                 = false                         # true - enable Red5 Pro server socialpusher, false - disable Red5 Pro server socialpusher (https://www.red5.net/docs/special/social-media-plugin/overview/)
  origin_image_red5pro_suppressor_enable                   = false                         # true - enable Red5 Pro server suppressor, false - disable Red5 Pro server suppressor
  origin_image_red5pro_hls_enable                          = false                         # true - enable Red5 Pro server HLS, false - disable Red5 Pro server HLS (https://www.red5.net/docs/protocols/hls-plugin/hls-vod/)
  origin_image_red5pro_round_trip_auth_enable              = false                         # true - enable Red5 Pro server round trip authentication, false - disable Red5 Pro server round trip authentication (https://www.red5.net/docs/special/round-trip-auth/overview/)
  origin_image_red5pro_round_trip_auth_host                = "round-trip-auth.example.com" # Round trip authentication server host
  origin_image_red5pro_round_trip_auth_port                = 3000                          # Round trip authentication server port
  origin_image_red5pro_round_trip_auth_protocol            = "http"                        # Round trip authentication server protocol
  origin_image_red5pro_round_trip_auth_endpoint_validate   = "/validateCredentials"        # Round trip authentication server endpoint for validate
  origin_image_red5pro_round_trip_auth_endpoint_invalidate = "/invalidateCredentials"      # Round trip authentication server endpoint for invalidate

  # Red5 Pro autoscaling Node group - (Optional)
  node_group_create                    = true                      # Linux or Mac OS only. true - create new Node group, false - not create new Node group
  node_group_name                      = "terraform-node-group"    # Node group name
  # Origin node configuration
  node_group_origins                   = 1                         # Number of Origins
  node_group_origins_instance_type     = "VM.Standard.E4.Flex-1-4" # Origins OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_origins_capacity          = 30                        # Connections capacity for Origins
  # Edge node configuration
  node_group_edges                     = 1                         # Number of Edges
  node_group_edges_instance_type       = "VM.Standard.E4.Flex-1-4" # Edges OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_edges_capacity            = 300                       # Connections capacity for Edges
  # Transcoder node configuration
  node_group_transcoders               = 0                         # Number of Transcoders
  node_group_transcoders_instance_type = "VM.Standard.E4.Flex-1-4" # Transcoders OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_transcoders_capacity      = 30                        # Connections capacity for Transcoders
  # Relay node configuration
  node_group_relays                    = 0                         # Number of Relays
  node_group_relays_instance_type      = "VM.Standard.E4.Flex-1-4" # Relays OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_relays_capacity           = 30                        # Connections capacity for Relays
}

output "module_output" {
  value = module.red5pro_cluster
}