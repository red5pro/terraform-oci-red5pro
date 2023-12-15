####################################################################################
# Example: Red5 Pro Stream Manager Autoscaling (OCI Load Balancer + Autoscaling)
####################################################################################

variable "tenancy_ocid" {
  default = "ocid1.tenancy.oc1..aaaaaaaar4gtkgwog6wmrevqqr5jgyo52mcnaw4gql3k5es6hswg3tejy7rq"
}

variable "user_ocid" {
  default = "ocid1.user.oc1..aaaaaaaa5jicp6tnpmfwj4v2qlvvsdyqshl55q2yfyjp4kmusl2kybwp7w6q"
}
variable "fingerprint" {
  default = "99:b7:88:cd:8e:d2:cf:62:0b:84:4f:9f:c3:d6:e9:d9"
}
variable "private_key_path" {
  default = "/Users/oles/jira_tasks/DEV-555-REDPILL/oracle-redpill-api-key.pem"
}
variable "region" {
  default = "us-sanjose-1"
}
variable "compartment_id" {
  default = "ocid1.compartment.oc1..aaaaaaaap7orrrmtzonnxkrfqhw7uyrxhlbutl7tlhkpyxrlvtydsyjgjrgq"
}

variable "ssh_public_key" {
  default = "/Users/oles/jira_tasks/DEV-555-REDPILL/red5pro-redpill-oracle.pub"
}
variable "ssh_private_key" {
  default = "/Users/oles/jira_tasks/DEV-555-REDPILL/red5pro-redpill-oracle.pem"
}

variable "private_key" {
  default = "/Users/oles/jira_tasks/DEV-555-REDPILL/broadcast.redpill.app-NEW/broadcast.redpill.app.key"
}
variable "public_certificate" {
  default = "/Users/oles/jira_tasks/DEV-555-REDPILL/broadcast.redpill.app-NEW/broadcast.reldpill.app.cert"
}
variable "certificate_name" {
  default = "broadcast.redpill.app"
}




terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0"
    }
  }
}


provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

module "red5pro_autoscaling" {
  source                                = "../../"
  type                                  = "autoscaling"                            # Deployment type: single, cluster, autoscaling
  name                                  = "red5pro-redpill-15dec23"                    # Name to be used on all the resources as identifier
  ubuntu_version                        = "22.04"                                  # Ubuntu version to be used for machine, it can either be 20.04 or 22.04
  path_to_red5pro_build                 = "/Users/oles/jira_tasks/DEV-555-REDPILL/red5pro-server-NOR-12.2.0.2.b953-release.zip"  # Absolute path or relative path to Red5 Pro server ZIP file
  path_to_terraform_cloud_controller    = "/Users/oles/jira_tasks/DEV-555-REDPILL/terraform-cloud-controller-12.1.0.jar" # Absolute path or relative path to Terraform Cloud Controller JAR file
  path_to_terraform_service_build       = "/Users/oles/jira_tasks/DEV-555-REDPILL/terraform-service-12.1.0.zip"

  # Oracle Cloud Account Details
  oracle_compartment_id   = var.compartment_id
  oracle_tenancy_ocid     = var.tenancy_ocid
  oracle_user_ocid        = var.user_ocid
  oracle_fingerprint      = var.fingerprint
  oracle_private_key_path = var.private_key_path
  oracle_region           = var.region

  # SSH key configuration
  ssh_key_create       = false
  ssh_private_key_path = var.ssh_private_key
  ssh_public_key_path  = var.ssh_public_key

  # MySQL DB configuration
  mysql_shape_name       = "MySQL.VM.Standard.E3.1.8GB" # Instance type for Oracle Cloud MySQL DB system instance
  mysql_user_name        = "smuser"                # MySQL username
  mysql_password         = "7RLWak8VH5AeimqS!"                # MySQL password (The password for the administrative user. The password must be between 8 and 32 characters long, and must contain at least 1 numeric character, 1 lowercase character, 1 uppercase character, and 1 special (nonalphanumeric) character.)
  mysql_port             = 3306                         # MySQL port

  # Terraform Service configuration
  terraform_service_instance_type   = "VM.Standard.E4.Flex"
  terraform_service_instance_ocpu   = 2
  terraform_service_instance_memory = 8
  terraform_service_api_key         = "u7OKBwCKVc5ILVhj"
  terraform_service_parallelism     = 10

  # Load Balancer HTTPS/SSL certificate configuration
  https_oci_certificates_use_existing     = true                 # If you want to use SSL certificate set it to true
  https_oci_certificates_certificate_name = "broadcast.redpill.app" # Domain name for your SSL certificate
  #cert_fullchain                          = "/PATH/TO/EXISTING/SSL/CERTS/fullchain.pem"
  cert_private_key                        = var.private_key
  cert_public_cert                        = var.public_certificate

  # Stream Manager configuration
  stream_manager_instance_type   = "VM.Standard.E4.Flex" # OCI Instance type for Stream Manager
  stream_manager_instance_ocpu   = 2                     # OCI Instance OCPU Count for Stream Manager(1 OCPU = 2 vCPU)
  stream_manager_instance_memory = 8                     # OCI Instance Memory size in GB for Stream Manager
  stream_manager_api_key         = "u7OKBwCKVc5ILVhj"          # API key for Stream Manager

  stream_manager_autoscaling_desired_capacity    = 1            # Desired capacity for Stream Manager autoscaling group
  stream_manager_autoscaling_minimum_capacity    = 1            # Min capacity for Stream Manager autoscaling group
  stream_manager_autoscaling_maximum_capacity    = 1            # Max capacity for Stream Manager autoscaling group

  load_balancer_reserved_ip_create = false                  # true - create new reserved IP for Load Balancer, false - use existing reserved IP for Load Balancer
  load_balancer_reserved_ip        = "152.70.117.151"      # Reserved IP for Load Balancer

  # Red5 Pro general configuration
  red5pro_license_key = "KA4G-QCE0-A4BT-41C7" # Red5 Pro license key (https://account.red5pro.com/login)
  red5pro_cluster_key = "u7OKBwCKVc5ILVhj"          # Red5 Pro cluster key
  red5pro_api_enable  = true                  # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5pro.com/docs/development/api/overview/)
  red5pro_api_key     = "u7OKBwCKVc5ILVhj"          # Red5 Pro server API key (https://www.red5pro.com/docs/development/api/overview/)

  # Red5 Pro autoscaling Origin node image configuration
  origin_image_create                                      = true                          # Default: true for Autoscaling and Cluster, true - create new Origin node image, false - not create new Origin node image
  origin_image_instance_type                               = "VM.Standard.E4.Flex"         # Instance type for Origin node image
  origin_image_instance_ocpu                               = 1                             # OCI Instance OCPU Count for Origin node image(1 OCPU = 2 vCPU)
  origin_image_instance_memory                             = 4                             # OCI Instance Memory size in GB for Origin node image
  origin_image_red5pro_inspector_enable                    = false                         # true - enable Red5 Pro server inspector, false - disable Red5 Pro server inspector (https://www.red5pro.com/docs/troubleshooting/inspector/overview/)
  origin_image_red5pro_restreamer_enable                   = true                         # true - enable Red5 Pro server restreamer, false - disable Red5 Pro server restreamer (https://www.red5pro.com/docs/special/restreamer/overview/)
  origin_image_red5pro_socialpusher_enable                 = false                         # true - enable Red5 Pro server socialpusher, false - disable Red5 Pro server socialpusher (https://www.red5pro.com/docs/special/social-media-plugin/overview/)
  origin_image_red5pro_suppressor_enable                   = false                         # true - enable Red5 Pro server suppressor, false - disable Red5 Pro server suppressor
  origin_image_red5pro_hls_enable                          = false                         # true - enable Red5 Pro server HLS, false - disable Red5 Pro server HLS (https://www.red5pro.com/docs/protocols/hls-plugin/hls-vod/)
  origin_image_red5pro_round_trip_auth_enable              = false                         # true - enable Red5 Pro server round trip authentication, false - disable Red5 Pro server round trip authentication (https://www.red5pro.com/docs/special/round-trip-auth/overview/)
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
  node_group_origins_capacity          = 20                        # Connections capacity for Origins
  # Edge node configuration
  node_group_edges                     = 6                         # Number of Edges
  node_group_edges_instance_type       = "VM.Standard.E4.Flex-1-4" # Edges OCI Instance Type(1 OCPU = 2 VCPUs) <shape>-<cpu>-<memory> eg. VM.Standard.E4.Flex-1-4
  node_group_edges_capacity            = 180                       # Connections capacity for Edges
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
  value = module.red5pro_autoscaling
}
