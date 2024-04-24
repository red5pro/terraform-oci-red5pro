# Red5 Pro common configurations
variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
  validation {
    condition     = length(var.name) > 0
    error_message = "The name value must be a valid! Example: example-name"
  }
}
variable "type" {
  description = "Type of deployment: single, cluster, autoscaling"
  type        = string
  default     = ""
  validation {
    condition     = var.type == "single" || var.type == "cluster" || var.type == "autoscaling"
    error_message = "The type value must be a valid! Example: single, cluster, autoscaling"
  }
}
variable "path_to_red5pro_build" {
  description = "Path to the Red5 Pro build zip file, absolute path or relative path. https://account.red5.net/downloads. Example: /home/ubuntu/terraform-oci-red5pro/red5pro-server-0.0.0.b0-release.zip"
  type        = string
  default     = ""
  validation {
    condition     = fileexists(var.path_to_red5pro_build) == true
    error_message = "The path_to_red5pro_build value must be a valid! Example: /home/ubuntu/terraform-oci-red5pro/red5pro-server-0.0.0.b0-release.zip"
  }
}
variable "path_to_terraform_service_build" {
  description = "Path to the Terraform Service build zip file, absolute path or relative path. https://account.red5.net/downloads. Example: /home/ubuntu/terraform-oci-red5pro/terraform-service-0.0.0.zip"
  type        = string
  default     = ""
}
variable "path_to_terraform_cloud_controller" {
  description = "Path to the Terraform Cloud Controller jar file, absolute path or relative path. https://account.red5.net/downloads. Example: /home/ubuntu/terraform-oci-red5pro/terraform-cloud-controller-0.0.0.jar"
  type        = string
  default     = ""
}
# Oracle Cloud Prvider basic configuration settings
variable "oracle_compartment_id" {
  description = "Oracle Cloud Compartment OCID to create the resources, https://cloud.oracle.com/identity/compartments"
  type        = string
  default     = ""
}
variable "oracle_tenancy_ocid" {
  description = "Oracle Cloud Tenancy OCID to create the resources, https://cloud.oracle.com/tenancy"
  type        = string
  default     = ""
}
variable "oracle_user_ocid" {
  description = "Oracle Cloud User OCID to create the resources, https://cloud.oracle.com/identity/domains/my-profile"
  type        = string
  default     = ""
}
variable "oracle_fingerprint" {
  description = "API key fingerprint for Oracle Cloud User to create the resources, https://cloud.oracle.com/identity/domains/my-profile/api-keys"
  type        = string
  default     = ""
}
variable "oracle_private_key_path" {
  description = "SSH private key path for for Oracle Cloud User to create the resources, https://cloud.oracle.com/identity/domains/my-profile/api-keys"
  type        = string
  default     = ""
}
variable "oracle_region" {
  description = "Oracle Cloud Region to create the resources"
  type        = string
  default     = ""
}
# SSH key configuration
variable "ssh_key_create" {
  description = "Create a new SSH key pair or use an existing one. true = create new, false = use existing"
  type        = bool
  default     = true
}
variable "ssh_private_key_path" {
  description = "SSH private key path existing"
  type        = string
  default     = ""
}
variable "ssh_public_key_path" {
  description = "SSH public key path existing"
  type        = string
  default     = ""
}

# Red5 Pro Terraform Service properties
variable "terraform_service_instance_create" {
  description = "Create a dedicated OCI Instance for Red5 pro Terraform Service "
  type        = bool
  default     = false
}
variable "terraform_service_instance_type" {
  description = "Terraform Service instance type"
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "terraform_service_instance_ocpu" {
  description = "Terraform Service instance cpu count(1 OCPU = 2vCPU)"
  type        = number
  default     = 1
}
variable "terraform_service_instance_memory" {
  description = "Terraform Service instance memory in GB"
  type        = number
  default     = 4
}
variable "terraform_service_api_key" {
  description = "API Key for Terraform Service to authorize the APIs"
  type        = string
  default     = ""
}
variable "terraform_service_parallelism" {
  description = "Number of Terraform concurrent operations and used for non-standard rate limiting"
  type        = number
  default     = 10
}

# VCN configuration
variable "vcn_create" {
  description = "Create a new Oracle Cloud VCN or use an existing one. true = create new, false = use existing"
  type        = bool
  default     = true
}
variable "vcn_id_existing" {
  description = "Oracle Cloud VCN OCID of an existing VCN Network"
  type        = string
  default     = ""
}
variable "vcn_cidr_block" {
  description = "Oracle Cloud VCN IP range"
  type        = string
  default     = "10.5.0.0/16"
}
variable "subnet_id_existing" {
  description = "Oracle Cloud Subnet OCID of an existing VCN Subnet"
  type        = string
  default     = ""
}
variable "subnet_cidr_block" {
  description = "Oracle Cloud Subnet IP range"
  type        = string
  default     = "10.5.1.0/24"
}

# Security group configuration
variable "network_security_group_create" {
  description = "Create a new Oracle Cloud Network Security Group or use an existing one. true = create new, false = use existing"
  type        = bool
  default     = true
}
variable "network_security_group_id_existing" {
  description = "Oracle Cloud Network Security Group OCID, this Security group should have open default Red5Pro ports: TCP:443,5080,80,1935,8554, UDP:40000-65535"
  type        = string
  default     = ""
}
variable "network_security_group_single_ingress_tcp" {
  type        = list(number)
  description = "Oracle Cloud Network Security Group for Red5 Pro Single server  - ingress tcp ports"
  default     = [22, 80, 443, 5080, 1935, 8554]
}
variable "network_security_group_single_ingress_udp" {
  type        = list(map(number))
  description = "Oracle Cloud Network Security Group for Red5 Pro Single server  - ingress udp ports"
  default = [
    {
      from_port = 8000
      to_port   = 8001
    },
    {
      from_port = 40000
      to_port   = 65535
    }
  ]
}
variable "network_security_group_stream_manager_ingress_tcp" {
  type        = list(number)
  description = "Security group for Red5 Pro Stream Managers - ingress tcp ports"
  default     = [22, 80, 443, 5080]
}
variable "network_security_group_terraform_service_ingress_tcp" {
  type        = list(number)
  description = "Security group for Red5 Pro Terraform Service - ingress tcp ports"
  default     = [22, 8083]
}
variable "network_security_group_node_ingress_tcp" {
  type        = list(number)
  description = "Oracle Cloud Network Security Group for Red5 Pro SM Nodes - ingress tcp ports"
  default     = [22, 80, 443, 5080, 1935, 8554]
}
variable "network_security_group_node_ingress_udp" {
  type        = list(map(number))
  description = "Oracle Cloud Network Security Group for Red5 Pro SM Nodes - ingress udp ports"
  default = [
    {
      from_port = 8000
      to_port   = 8001
    },
    {
      from_port = 40000
      to_port   = 65535
    }
  ]
}

# MySQL configuration
variable "mysql_db_system_create" {
  description = "Create a new OCI managed MySQL DB instance"
  type        = bool
  default     = false
}
variable "mysql_shape_name" {
  description = "OCI managed MySQL DB System shape that determines the resources allocated including CPU cores and memory"
  default     = "MySQL.VM.Standard.E3.1.8GB"
}
variable "mysql_db_system_backup_policy_is_enabled" {
  description = "Boolean that defines if either backup is enabled or not"
  default     = false
}
variable "mysql_db_system_data_storage_size_in_gb" {
  description = "Initial size of the data volume in GiBs that will be created and attached."
  type        = number
  default     = 50
}
variable "mysql_user_name" {
  description = "MySQL Database username"
  type        = string
  default     = ""
}
variable "mysql_password" {
  type    = string
  default = "Abc12345@"

  validation {
    condition = length(var.mysql_password) >= 8
    error_message = "Password must have at least 8 characters."
  }
  validation {
    condition = can(regex("[A-Z]", var.mysql_password))
    error_message = "Password must contain at least one uppercase letter."
  }
  validation {
    condition = can(regex("[a-z]", var.mysql_password))
    error_message = "Password must contain at least one lowercase letter."
  }
  validation {
    condition = can(regex("[^a-zA-Z0-9]", var.mysql_password))
    error_message = "Password must contain at least one character that isn't a letter or a digit."
  }
  validation {
    condition = can(regex("[0-9]", var.mysql_password))
    error_message = "Password must contain at least one digit."
  }
}
variable "mysql_port" {
  description = "MySQL Database port"
  type        = number
  default     = 3306
}

# Red5 Pro single server configuration
variable "single_instance_type" {
  description = "Red5 Pro Single server instance type"
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "single_instance_ocpu" {
  description = "Red5 Pro Single server instance cpu count(1 OCPU = 2vCPU)"
  type        = number
  default     = 1
}
variable "single_instance_memory" {
  description = "Red5 Pro Single server instance memory"
  type        = number
  default     = 4
}
variable "red5pro_inspector_enable" {
  description = "Red5 Pro Single server Inspector enable/disable (https://www.red5.net/docs/troubleshooting/inspector/overview/)"
  type        = bool
  default     = false
}
variable "red5pro_restreamer_enable" {
  description = "Red5 Pro Single server Restreamer enable/disable (https://www.red5.net/docs/special/restreamer/overview/)"
  type        = bool
  default     = false
}
variable "red5pro_socialpusher_enable" {
  description = "Red5 Pro Single server SocialPusher enable/disable (https://www.red5.net/docs/special/social-media-plugin/rest-api/)"
  type        = bool
  default     = false
}
variable "red5pro_suppressor_enable" {
  description = "Red5 Pro Single server Suppressor enable"
  type        = bool
  default     = false
}
variable "red5pro_hls_enable" {
  description = "Red5 Pro Single server HLS enable/disable (https://www.red5.net/docs/protocols/hls-plugin/overview/)"
  type        = bool
  default     = false
}
variable "red5pro_round_trip_auth_enable" {
  description = "Round trip authentication on the red5pro server enable/disable - Auth server should be deployed separately (https://www.red5.net/docs/special/round-trip-auth/overview/)"
  type        = bool
  default     = false
}
variable "red5pro_round_trip_auth_host" {
  description = "Round trip authentication server host"
  type        = string
  default     = ""
}
variable "red5pro_round_trip_auth_port" {
  description = "Round trip authentication server port"
  type        = number
  default     = 3000
}
variable "red5pro_round_trip_auth_protocol" {
  description = "Round trip authentication server protocol"
  type        = string
  default     = "http"
}
variable "red5pro_round_trip_auth_endpoint_validate" {
  description = "Round trip authentication server endpoint for validate"
  type        = string
  default     = "/validateCredentials"
}
variable "red5pro_round_trip_auth_endpoint_invalidate" {
  description = "Round trip authentication server endpoint for invalidate"
  type        = string
  default     = "/invalidateCredentials"
}

# Red5 Pro Cluster Configuration
variable "stream_manager_instance_type" {
  description = "Red5 Pro Stream Manager instance type"
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "stream_manager_instance_ocpu" {
  description = "Red5 Pro Stream Manager instance cpu count(1 OCPU = 2vCPU)"
  type        = number
  default     = 1
}
variable "stream_manager_instance_memory" {
  description = "Red5 Pro Stream Manager instance memory"
  type        = number
  default     = 4
}
variable "stream_manager_api_key" {
  description = "value to set the api key for stream manager"
  type        = string
  default     = ""
}
variable "stream_manager_autoscaling_desired_capacity" {
  description = "value to set the desired capacity for stream manager autoscaling"
  type        = number
  default     = 1
}
variable "stream_manager_autoscaling_minimum_capacity" {
  description = "value to set the minimum capacity for stream manager autoscaling"
  type        = number
  default     = 1
}
variable "stream_manager_autoscaling_maximum_capacity" {
  description = "value to set the maximum capacity for stream manager autoscaling"
  type        = number
  default     = 2
}
variable "load_balancer_reserved_ip_create" {
  description = "Create a new reserved IP for Load Balancer true/false - if false, use existing reserved IP for Load Balancer"
  type        = bool
  default     = true
}
variable "load_balancer_reserved_ip" {
  description = "Reserved IP for Load Balancer"
  type        = string
  default     = ""
}
variable "red5pro_cluster_key" {
  description = "Red5 Pro node cluster key"
  type        = string
  default     = ""
}
variable "red5pro_license_key" {
  description = "Red5 Pro license key (https://www.red5.net/docs/installation/installation/license-key/)"
  type        = string
  default     = ""
}
variable "red5pro_api_enable" {
  description = "Red5 Pro Server API enable/disable (https://www.red5.net/docs/development/api/overview/)"
  type        = bool
  default     = true
}
variable "red5pro_api_key" {
  description = "Red5 Pro Single server API key"
  type        = string
  default     = ""
}

# HTTPS/SSL variables for single/cluster
variable "https_letsencrypt_enable" {
  description = "Enable HTTPS and get SSL certificate using Let's Encrypt automaticaly (single/cluster) (https://www.red5.net/docs/installation/ssl/overview/)"
  type        = bool
  default     = false
}
variable "https_letsencrypt_certificate_domain_name" {
  description = "Domain name for Let's Encrypt ssl certificate (single/cluster)"
  type        = string
  default     = ""
}
variable "https_letsencrypt_certificate_email" {
  description = "Email for Let's Encrypt ssl certificate (single/cluster)"
  type        = string
  default     = "email@example.com"
}
variable "https_letsencrypt_certificate_password" {
  description = "Password for Let's Encrypt ssl certificate (single/cluster)"
  type        = string
  default     = ""
}
variable "lb_https_certificate_create" {
  description = "Use existing Oracle Cloud Managed certificate (autoscaling)"
  type        = bool
  default     = false
}
variable "lb_https_certificate_cipher_suite_name" {
  description = "The name of the cipher suite to use for HTTPS or SSL connections. RSA use oci-default-ssl-cipher-suite-v1, ECDSA use oci-modern-ssl-cipher-suite-v1 https://docs.oracle.com/en-us/iaas/Content/Balance/Tasks/managingciphersuites_topic-Predefined_Cipher_Suites.htm"
  type        = string
  default     = "oci-modern-ssl-cipher-suite-v1"
}
variable "lb_https_certificate_name" {
  description = "Oracle Cloud Managed certificate name (autoscaling)"
  type        = string
  default     = ""
}
variable "lb_https_certificate_private_key" {
  description = "File path for SSL/TLS Certificate Private Key (autoscaling)"
  type        = string
  default     = ""
}
variable "lb_https_certificate_public_cert" {
  description = "File path for SSL/TLS Certificate Public Cert (autoscaling)"
  type        = string
  default     = ""
}
variable "lb_https_certificate_fullchain" {
  description = "File path for SSL/TLS Certificate Fullchain (autoscaling)"
  type        = string
  default     = ""
}

# Red5 Pro Origin node image configuration
variable "origin_image_create" {
  description = "Create new Origin node image true/false. (Default:true) (https://www.red5.net/docs/special/relays/overview/#origin-and-edge-nodes)"
  type        = bool
  default     = false
}
variable "origin_image_instance_type" {
  description = "Origin node image - instance type"
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "origin_image_instance_ocpu" {
  description = "Origin node image - instance cpu"
  type        = number
  default     = 2
}
variable "origin_image_instance_memory" {
  description = "Origin node image - instance memory"
  type        = number
  default     = 4
}
variable "origin_image_red5pro_inspector_enable" {
  description = "Origin node image - Inspector enable/disable (https://www.red5.net/docs/troubleshooting/inspector/overview/)"
  type        = bool
  default     = false
}
variable "origin_image_red5pro_restreamer_enable" {
  description = "Origin node image - Restreamer enable/disable (https://www.red5.net/docs/special/restreamer/overview/)"
  type        = bool
  default     = false
}
variable "origin_image_red5pro_socialpusher_enable" {
  description = "Origin node image - SocialPusher enable/disable (https://www.red5.net/docs/special/social-media-plugin/rest-api/)"
  type        = bool
  default     = false
}
variable "origin_image_red5pro_suppressor_enable" {
  description = "Origin node image - Suppressor enable/disable"
  type        = bool
  default     = false
}
variable "origin_image_red5pro_hls_enable" {
  description = "Origin node image - HLS enable/disable (https://www.red5.net/docs/protocols/hls-plugin/overview/)"
  type        = bool
  default     = false
}
variable "origin_image_red5pro_round_trip_auth_enable" {
  description = "Origin node image - Round trip authentication on the enable/disable - Auth server should be deployed separately (https://www.red5.net/docs/special/round-trip-auth/overview/)"
  type        = bool
  default     = false
}
variable "origin_image_red5pro_round_trip_auth_host" {
  description = "Origin node image - Round trip authentication server host"
  type        = string
  default     = ""
}
variable "origin_image_red5pro_round_trip_auth_port" {
  description = "Origin node image - Round trip authentication server port"
  type        = number
  default     = 3000
}
variable "origin_image_red5pro_round_trip_auth_protocol" {
  description = "Origin node image - Round trip authentication server protocol"
  type        = string
  default     = "http"
}
variable "origin_image_red5pro_round_trip_auth_endpoint_validate" {
  description = "Origin node image - Round trip authentication server endpoint for validate"
  type        = string
  default     = "/validateCredentials"
}
variable "origin_image_red5pro_round_trip_auth_endpoint_invalidate" {
  description = "Origin node image - Round trip authentication server endpoint for invalidate"
  type        = string
  default     = "/invalidateCredentials"
}

# Red5 Pro Edge node image configuration
variable "edge_image_create" {
  description = "Create new Edge node image true/false. (Default:true) (https://www.red5.net/docs/special/relays/overview/#origin-and-edge-nodes)"
  type        = bool
  default     = false
}
variable "edge_image_instance_type" {
  description = "Edge node image - instance type"
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "edge_image_instance_ocpu" {
  description = "Edge node image - instance cpu"
  type        = number
  default     = 2
}
variable "edge_image_instance_memory" {
  description = "Edge node image - instance memory"
  type        = number
  default     = 4
}
variable "edge_image_red5pro_inspector_enable" {
  description = "Edge node image - Inspector enable/disable (https://www.red5.net/docs/troubleshooting/inspector/overview/)"
  type        = bool
  default     = false
}
variable "edge_image_red5pro_restreamer_enable" {
  description = "Edge node image - Restreamer enable/disable (https://www.red5.net/docs/special/restreamer/overview/)"
  type        = bool
  default     = false
}
variable "edge_image_red5pro_socialpusher_enable" {
  description = "Edge node image - SocialPusher enable/disable (https://www.red5.net/docs/special/social-media-plugin/rest-api/)"
  type        = bool
  default     = false
}
variable "edge_image_red5pro_suppressor_enable" {
  description = "Edge node image - Suppressor enable/disable"
  type        = bool
  default     = false
}
variable "edge_image_red5pro_hls_enable" {
  description = "Edge node image - HLS enable/disable (https://www.red5.net/docs/protocols/hls-plugin/overview/)"
  type        = bool
  default     = false
}
variable "edge_image_red5pro_round_trip_auth_enable" {
  description = "Edge node image - Round trip authentication on the enable/disable - Auth server should be deployed separately (https://www.red5.net/docs/special/round-trip-auth/overview/)"
  type        = bool
  default     = false
}
variable "edge_image_red5pro_round_trip_auth_host" {
  description = "Edge node image - Round trip authentication server host"
  type        = string
  default     = ""
}
variable "edge_image_red5pro_round_trip_auth_port" {
  description = "Edge node image - Round trip authentication server port"
  type        = number
  default     = 3000
}
variable "edge_image_red5pro_round_trip_auth_protocol" {
  description = "Edge node image - Round trip authentication server protocol"
  type        = string
  default     = "http"
}
variable "edge_image_red5pro_round_trip_auth_endpoint_validate" {
  description = "Edge node image - Round trip authentication server endpoint for validate"
  type        = string
  default     = "/validateCredentials"
}
variable "edge_image_red5pro_round_trip_auth_endpoint_invalidate" {
  description = "Edge node image - Round trip authentication server endpoint for invalidate"
  type        = string
  default     = "/invalidateCredentials"
}

# Red5 Pro Transcoder node image configuration
variable "transcoder_image_create" {
  description = "Create new Transcoder node image true/false. (Default:true) (https://www.red5.net/docs/special/relays/overview/#origin-and-edge-nodes)"
  type        = bool
  default     = false
}
variable "transcoder_image_instance_type" {
  description = "Transcoder node image - instance type"
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "transcoder_image_instance_ocpu" {
  description = "Transcoder node image - instance cpu"
  type        = number
  default     = 2
}
variable "transcoder_image_instance_memory" {
  description = "Transcoder node image - instance memory"
  type        = number
  default     = 4
}
variable "transcoder_image_red5pro_inspector_enable" {
  description = "Transcoder node image - Inspector enable/disable (https://www.red5.net/docs/troubleshooting/inspector/overview/)"
  type        = bool
  default     = false
}
variable "transcoder_image_red5pro_restreamer_enable" {
  description = "Transcoder node image - Restreamer enable/disable (https://www.red5.net/docs/special/restreamer/overview/)"
  type        = bool
  default     = false
}
variable "transcoder_image_red5pro_socialpusher_enable" {
  description = "Transcoder node image - SocialPusher enable/disable (https://www.red5.net/docs/special/social-media-plugin/rest-api/)"
  type        = bool
  default     = false
}
variable "transcoder_image_red5pro_suppressor_enable" {
  description = "Transcoder node image - Suppressor enable/disable"
  type        = bool
  default     = false
}
variable "transcoder_image_red5pro_hls_enable" {
  description = "Transcoder node image - HLS enable/disable (https://www.red5.net/docs/protocols/hls-plugin/overview/)"
  type        = bool
  default     = false
}
variable "transcoder_image_red5pro_round_trip_auth_enable" {
  description = "Transcoder node image - Round trip authentication on the enable/disable - Auth server should be deployed separately (https://www.red5.net/docs/special/round-trip-auth/overview/)"
  type        = bool
  default     = false
}
variable "transcoder_image_red5pro_round_trip_auth_host" {
  description = "Transcoder node image - Round trip authentication server host"
  type        = string
  default     = ""
}
variable "transcoder_image_red5pro_round_trip_auth_port" {
  description = "Transcoder node image - Round trip authentication server port"
  type        = number
  default     = 3000
}
variable "transcoder_image_red5pro_round_trip_auth_protocol" {
  description = "Transcoder node image - Round trip authentication server protocol"
  type        = string
  default     = "http"
}
variable "transcoder_image_red5pro_round_trip_auth_endpoint_validate" {
  description = "Transcoder node image - Round trip authentication server endpoint for validate"
  type        = string
  default     = "/validateCredentials"
}
variable "transcoder_image_red5pro_round_trip_auth_endpoint_invalidate" {
  description = "Transcoder node image - Round trip authentication server endpoint for invalidate"
  type        = string
  default     = "/invalidateCredentials"
}

# Red5 Pro Relay node image configuration
variable "relay_image_create" {
  description = "Create new Relay node image true/false. (Default:true) (https://www.red5.net/docs/special/relays/overview/#origin-and-edge-nodes)"
  type        = bool
  default     = false
}
variable "relay_image_instance_type" {
  description = "Relay node image - instance type"
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "relay_image_instance_ocpu" {
  description = "Relay node image - instance cpu"
  type        = number
  default     = 2
}
variable "relay_image_instance_memory" {
  description = "Relay node image - instance memory"
  type        = number
  default     = 4
}
variable "relay_image_red5pro_inspector_enable" {
  description = "Relay node image - Inspector enable/disable (https://www.red5.net/docs/troubleshooting/inspector/overview/)"
  type        = bool
  default     = false
}
variable "relay_image_red5pro_restreamer_enable" {
  description = "Relay node image - Restreamer enable/disable (https://www.red5.net/docs/special/restreamer/overview/)"
  type        = bool
  default     = false
}
variable "relay_image_red5pro_socialpusher_enable" {
  description = "Relay node image - SocialPusher enable/disable (https://www.red5.net/docs/special/social-media-plugin/rest-api/)"
  type        = bool
  default     = false
}
variable "relay_image_red5pro_suppressor_enable" {
  description = "Relay node image - Suppressor enable/disable"
  type        = bool
  default     = false
}
variable "relay_image_red5pro_hls_enable" {
  description = "Relay node image - HLS enable/disable (https://www.red5.net/docs/protocols/hls-plugin/overview/)"
  type        = bool
  default     = false
}
variable "relay_image_red5pro_round_trip_auth_enable" {
  description = "Relay node image - Round trip authentication on the enable/disable - Auth server should be deployed separately (https://www.red5.net/docs/special/round-trip-auth/overview/)"
  type        = bool
  default     = false
}
variable "relay_image_red5pro_round_trip_auth_host" {
  description = "Relay node image - Round trip authentication server host"
  type        = string
  default     = ""
}
variable "relay_image_red5pro_round_trip_auth_port" {
  description = "Relay node image - Round trip authentication server port"
  type        = number
  default     = 3000
}
variable "relay_image_red5pro_round_trip_auth_protocol" {
  description = "Relay node image - Round trip authentication server protocol"
  type        = string
  default     = "http"
}
variable "relay_image_red5pro_round_trip_auth_endpoint_validate" {
  description = "Relay node image - Round trip authentication server endpoint for validate"
  type        = string
  default     = "/validateCredentials"
}
variable "relay_image_red5pro_round_trip_auth_endpoint_invalidate" {
  description = "Relay node image - Round trip authentication server endpoint for invalidate"
  type        = string
  default     = "/invalidateCredentials"
}

# Red5 Pro autoscaling Node group - (Optional) 
variable "node_group_create" {
  description = "Create new node group. Linux or Mac OS only."
  type        = bool
  default     = false
}
variable "node_group_name" {
  description = "Node group name"
  type        = string
  default     = "terraform-node-group"
}
variable "node_group_origins_min" {
  description = "Number of minimum Origins"
  type        = number
  default     = 1
}
variable "node_group_origins_max" {
  description = "Number of maximum Origins"
  type        = number
  default     = 20
}
variable "node_group_origins_instance_type" {
  description = "Instance type for Origins"
  type        = string
  default     = "VM.Standard.E4.Flex-1-4"
}
variable "node_group_origins_capacity" {
  description = "Connections capacity for Origins"
  type        = number
  default     = 30
}
variable "node_group_edges_min" {
  description = "Number of minimum Edges"
  type        = number
  default     = 1
}
variable "node_group_edges_max" {
  description = "Number of maximum Edges"
  type        = number
  default     = 40
}
variable "node_group_edges_instance_type" {
  description = "Instance type for Edges"
  type        = string
  default     = "VM.Standard.E4.Flex-1-4"
}
variable "node_group_edges_capacity" {
  description = "Connections capacity for Edges"
  type        = number
  default     = 300
}
variable "node_group_transcoders_min" {
  description = "Number of minimum Transcoders"
  type        = number
  default     = 1
}
variable "node_group_transcoders_max" {
  description = "Number of maximum Transcoders"
  type        = number
  default     = 20
}
variable "node_group_transcoders_instance_type" {
  description = "Instance type for Transcoders"
  type        = string
  default     = "VM.Standard.E4.Flex-1-4"
}
variable "node_group_transcoders_capacity" {
  description = "Connections capacity for Transcoders"
  type        = number
  default     = 30
}
variable "node_group_relays_min" {
  description = "Number of minimum Relays"
  type        = number
  default     = 1
}
variable "node_group_relays_max" {
  description = "Number of maximum Relays"
  type        = number
  default     = 20
}
variable "node_group_relays_instance_type" {
  description = "Instance type for Relays"
  type        = string
  default     = "VM.Standard.E4.Flex-1-4"
}
variable "node_group_relays_capacity" {
  description = "Connections capacity for Relays"
  type        = number
  default     = 30
}

# OCI specific tags
variable "defined_tags" {
  description = "Predefined defined tags."
  type        = map(string)
  default     = null
}

variable "ubuntu_version" {
  description = "Ubuntu version"
  type        = string
  default     = "20.04"
  validation {
    condition = var.ubuntu_version == "20.04" || var.ubuntu_version == "22.04"
    error_message = "Please specify the correct ubuntu version, it can either be 20.04 or 22.04"
  }
}