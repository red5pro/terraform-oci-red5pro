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
  description = "Type of deployment: standalone, cluster, autoscale"
  type        = string
  default     = ""
  validation {
    condition     = var.type == "standalone" || var.type == "cluster" || var.type == "autoscale" || var.type == "none"
    error_message = "The type value must be a valid! Example: autoscale, cluster or autoscale"
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
variable "ssh_key_use_existing" {
  description = "SSH key pair configuration, true = use existing, false = create new"
  type        = bool
  default     = false
}
variable "ssh_key_existing_private_key_path" {
  description = "SSH private key path existing"
  type        = string
  default     = ""
}
variable "ssh_key_existing_public_key_path" {
  description = "SSH public key path existing"
  type        = string
  default     = ""
}
variable "vcn_cidr_block" {
  description = "Oracle Cloud VCN IP range"
  type        = string
  default     = "10.5.0.0/16"
}
variable "subnet_cidr_block" {
  description = "Oracle Cloud Subnet IP range"
  type        = string
  default     = "10.5.0.0/22"
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

variable "network_security_group_standalone_ingress" {
  description = "List of ports for security group ingress rules for Red5 Pro Standalone server"
  type = list(object({
    description = string
    protocol    = string
    source      = string
    port_min    = number
    port_max    = number
  }))
  default = [
    {
      description = "Red5 Pro Standalone server - SSH (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 22
      port_max    = 22
    },
    {
      description = "Red5 Pro Standalone server - HTTPS (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 443
      port_max    = 443
    },
    {
      description = "Red5 Pro Standalone server - HTTP (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 5080
      port_max    = 5080
    },
    {
      description = "Red5 Pro Standalone server - HTTP (Let'S Encrypt) (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 80
      port_max    = 80
    },
    {
      description = "Red5 Pro Standalone server - RTMP (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 1935
      port_max    = 1935
    },
    {
      description = "Red5 Pro Standalone server - RTMPS (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 1936
      port_max    = 1936
    },
    {
      description = "Red5 Pro Standalone server - RTSP (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 8554
      port_max    = 8554
    },
    {
      description = "Red5 Pro Standalone server - Restreamer, SRT (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 8000
      port_max    = 8100
    },
    {
      description = "Red5 Pro Standalone server - WebRTC (UDP)"
      protocol    = "17"
      source      = "0.0.0.0/0"
      port_min    = 40000
      port_max    = 65535
    },
    {
      description = "Red5 Pro Standalone server - Restreamer, SRT (UDP)"
      protocol    = "17"
      source      = "0.0.0.0/0"
      port_min    = 8000
      port_max    = 8100
    }
  ]
}

variable "network_security_group_stream_manager_ingress" {
  description = "List of ports for security group ingress rules for Stream Manager 2.0"
  type = list(object({
    description = string
    protocol    = string
    source      = string
    port_min    = number
    port_max    = number
  }))
  # if here is empty then default will be set in vcn's locals section
  default = []
}

variable "network_security_group_node_ingress" {
  description = "List of ports for security group ingress rules for Red5 Pro SM2.0 Nodes"
  type = list(object({
    description = string
    protocol    = string
    source      = string
    port_min    = number
    port_max    = number
  }))
  default = [
    {
      description = "Red5 Pro SM2.0 Nodes - SSH (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 22
      port_max    = 22
    },
    {
      description = "Red5 Pro SM2.0 Nodes - HTTP (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 5080
      port_max    = 5080
    },
    {
      description = "Red5 Pro SM2.0 Nodes - RTMP (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 1935
      port_max    = 1935
    },
    {
      description = "Red5 Pro SM2.0 Nodes - RTMPS (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 1936
      port_max    = 1936
    },
    {
      description = "Red5 Pro SM2.0 Nodes - RTSP (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 8554
      port_max    = 8554
    },
    {
      description = "Red5 Pro SM2.0 Nodes - Restreamer, SRT (TCP)"
      protocol    = "6"
      source      = "0.0.0.0/0"
      port_min    = 8000
      port_max    = 8100
    },
    {
      description = "Red5 Pro SM2.0 Nodes - WebRTC (UDP)"
      protocol    = "17"
      source      = "0.0.0.0/0"
      port_min    = 40000
      port_max    = 65535
    },
    {
      description = "Red5 Pro SM2.0 Nodes - Restreamer, SRT (UDP)"
      protocol    = "17"
      source      = "0.0.0.0/0"
      port_min    = 8000
      port_max    = 8100
    }
  ]
}

variable "network_security_group_kafka_ingress" {
  description = "List of ports for security group ingress rules for Kafka standalone instance"
  type = list(object({
    description = string
    protocol    = string
    source      = string
    port_min    = number
    port_max    = number
  }))
  # if here is empty then default will be set in vcn's locals section
  default = []
}

# Red5 Pro Standalone server configuration
variable "standalone_red5pro_instance_type" {
  description = "Red5 Pro Standalone server instance type"
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "standalone_red5pro_instance_ocpu" {
  description = "Red5 Pro Standalone server instance cpu count(1 OCPU = 2vCPU)"
  type        = number
  default     = 1
}
variable "standalone_red5pro_instance_memory" {
  description = "Red5 Pro Standalone server instance memory"
  type        = number
  default     = 4
}
variable "standalone_red5pro_instance_volume_size" {
  description = "Red5 Pro Standalone server instance volume size in GB"
  type        = number
  default     = 50
  validation {
    condition     = var.standalone_red5pro_instance_volume_size >= 50
    error_message = "The standalone_red5pro_instance_volume_size value must be a valid! Minimum 50"
  }
}
variable "standalone_red5pro_inspector_enable" {
  description = "Red5 Pro Standalone server Inspector enable/disable (https://www.red5.net/docs/troubleshooting/inspector/overview/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_restreamer_enable" {
  description = "Red5 Pro Standalone server Restreamer enable/disable (https://www.red5.net/docs/special/restreamer/overview/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_socialpusher_enable" {
  description = "Red5 Pro Standalone server SocialPusher enable/disable (https://www.red5.net/docs/special/social-media-plugin/rest-api/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_suppressor_enable" {
  description = "Red5 Pro Standalone server Suppressor enable"
  type        = bool
  default     = false
}
variable "standalone_red5pro_hls_enable" {
  description = "Red5 Pro Standalone server HLS enable/disable (https://www.red5.net/docs/protocols/hls-plugin/overview/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_round_trip_auth_enable" {
  description = "Round trip authentication on the red5pro server enable/disable - Auth server should be deployed separately (https://www.red5.net/docs/special/round-trip-auth/overview/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_round_trip_auth_host" {
  description = "Round trip authentication server host"
  type        = string
  default     = ""
}
variable "standalone_red5pro_round_trip_auth_port" {
  description = "Round trip authentication server port"
  type        = number
  default     = 3000
}
variable "standalone_red5pro_round_trip_auth_protocol" {
  description = "Round trip authentication server protocol"
  type        = string
  default     = "http"
}
variable "standalone_red5pro_round_trip_auth_endpoint_validate" {
  description = "Round trip authentication server endpoint for validate"
  type        = string
  default     = "/validateCredentials"
}
variable "standalone_red5pro_round_trip_auth_endpoint_invalidate" {
  description = "Round trip authentication server endpoint for invalidate"
  type        = string
  default     = "/invalidateCredentials"
}

# Red5 Pro Cluster Configuration
variable "stream_manager_instance_type" {
  description = "Red5 Pro Stream Manager 2.0 instance type"
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "stream_manager_instance_ocpu" {
  description = "Red5 Pro Stream Manager 2.0 instance cpu count(1 OCPU = 2vCPU)"
  type        = number
  default     = 1
}
variable "stream_manager_instance_memory" {
  description = "Red5 Pro Stream Manager 2.0 instance memory"
  type        = number
  default     = 4
}
variable "stream_manager_instance_volume_size" {
  description = "Volume size in GB for Stream Manager"
  type        = number
  default     = 50
  validation {
    condition     = var.stream_manager_instance_volume_size >= 50
    error_message = "The stream_manager_instance_volume_size value must be a valid! Minimum 50"
  }
}
variable "stream_manager_auth_user" {
  description = "value to set the user name for Stream Manager 2.0 authentication"
  type        = string
  default     = ""
}
variable "stream_manager_auth_password" {
  description = "value to set the user password for Stream Manager 2.0 authentication"
  type        = string
  default     = ""
}
variable "stream_manager_autoscaling_desired_capacity" {
  description = "value to set the desired capacity for Stream Manager 2.0 autoscaling"
  type        = number
  default     = 1
}
variable "stream_manager_autoscaling_minimum_capacity" {
  description = "value to set the minimum capacity for Stream Manager 2.0 autoscaling"
  type        = number
  default     = 1
}
variable "stream_manager_autoscaling_maximum_capacity" {
  description = "value to set the maximum capacity for Stream Manager 2.0 autoscaling"
  type        = number
  default     = 2
}

variable "kafka_standalone_instance_create" {
  description = "Create a new Kafka standalone instance true/false"
  type        = bool
  default     = false
}
variable "kafka_standalone_instance_type" {
  description = "Kafka standalone instance type"
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "kafka_standalone_instance_ocpu" {
  description = "Kafka standalone instance cpu count(1 OCPU = 2vCPU)"
  type        = number
  default     = 1
}
variable "kafka_standalone_instance_memory" {
  description = "Kafka standalone instance memory in GB"
  type        = number
  default     = 16
  validation {
    condition     = var.kafka_standalone_instance_memory >= 16
    error_message = "The kafka_standalone_instance_memory value must be a valid! Minimum 16"
  }
}
variable "kafka_standalone_instance_volume_size" {
  description = "Volume size in GB for Kafka standalone instance"
  type        = number
  default     = 50
  validation {
    condition     = var.kafka_standalone_instance_volume_size >= 50
    error_message = "The kafka_standalone_instance_volume_size value must be a valid! Minimum 50"
  }
}
variable "kafka_standalone_instance_arhive_url" {
  description = "Kafka standalone instance - archive URL"
  type        = string
  default     = "https://downloads.apache.org/kafka/3.8.0/kafka_2.13-3.8.0.tgz"
}

variable "kafka_public_ip" {
  description = "Expose Kafka on public ip true/false"
  type        = bool
  default     = false
}

variable "load_balancer_reserved_ip_use_existing" {
  description = "Use existing Reserved IP for Load Balancer. true = use existing, false = create new"
  type        = bool
  default     = false
}
variable "load_balancer_reserved_ip_existing" {
  description = "Existing Reserved IP for Load Balancer"
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
  description = "Red5 Pro Standalone server API key"
  type        = string
  default     = ""
}

# HTTPS/SSL variables for standalone/cluster/autoscale
variable "https_ssl_certificate" {
  description = "Enable SSL (HTTPS) on the Standalone Red5 Pro server,  Stream Manager 2.0 server or Stream Manager 2.0 Load Balancer"
  type        = string
  default     = "none"
  validation {
    condition     = var.https_ssl_certificate == "none" || var.https_ssl_certificate == "letsencrypt" || var.https_ssl_certificate == "imported"
    error_message = "The https_ssl_certificate value must be a valid! Example: none, letsencrypt, imported"
  }
}
variable "https_ssl_certificate_domain_name" {
  description = "Domain name for SSL certificate (letsencrypt/imported)"
  type        = string
  default     = ""
}
variable "https_ssl_certificate_email" {
  description = "Email for SSL certificate (letsencrypt)"
  type        = string
  default     = ""
}
variable "https_ssl_certificate_cert_path" {
  description = "Path to SSL certificate (imported)"
  type        = string
  default     = ""
}
variable "https_ssl_certificate_key_path" {
  description = "Path to SSL key (imported)"
  type        = string
  default     = ""
}

variable "lb_https_certificate_cipher_suite_name" {
  description = "The name of the cipher suite to use for HTTPS or SSL connections. RSA use oci-default-ssl-cipher-suite-v1, ECDSA use oci-modern-ssl-cipher-suite-v1 https://docs.oracle.com/en-us/iaas/Content/Balance/Tasks/managingciphersuites_topic-Predefined_Cipher_Suites.htm"
  type        = string
  default     = "oci-modern-ssl-cipher-suite-v1"
}

# Red5 Pro Node image configuration
variable "node_image_create" {
  description = "Create new Node image true/false."
  type        = bool
  default     = false
}
variable "node_image_instance_type" {
  description = "Node image - instance type"
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "node_image_instance_ocpu" {
  description = "Node image - instance cpu"
  type        = number
  default     = 2
}
variable "node_image_instance_memory" {
  description = "Node image - instance memory"
  type        = number
  default     = 4
}
variable "node_image_instance_volume_size" {
  description = "Volume size in GB for Node image"
  type        = number
  default     = 50
  validation {
    condition     = var.node_image_instance_volume_size >= 50
    error_message = "The node_image_instance_volume_size value must be a valid! Minimum 50"
  }
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
variable "node_group_origins_volume_size" {
  description = "Volume size in GB for Origins. Minimum 50GB"
  type        = number
  default     = 50
  validation {
    condition     = var.node_group_origins_volume_size >= 50
    error_message = "The node_group_origins_volume_size value must be a valid! Minimum 50"
  }
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
variable "node_group_edges_volume_size" {
  description = "Volume size in GB for Edges. Minimum 50GB"
  type        = number
  default     = 50
  validation {
    condition     = var.node_group_edges_volume_size >= 50
    error_message = "The node_group_edges_volume_size value must be a valid! Minimum 50"
  }
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
variable "node_group_transcoders_volume_size" {
  description = "Volume size in GB for Transcoders. Minimum 50GB"
  type        = number
  default     = 50
  validation {
    condition     = var.node_group_transcoders_volume_size >= 50
    error_message = "The node_group_transcoders_volume_size value must be a valid! Minimum 50"
  }
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
variable "node_group_relays_volume_size" {
  description = "Volume size in GB for Relays. Minimum 50GB"
  type        = number
  default     = 50
  validation {
    condition     = var.node_group_relays_volume_size >= 50
    error_message = "The node_group_relays_volume_size value must be a valid! Minimum 50"
  }
}
variable "ubuntu_version" {
  description = "Ubuntu version"
  type        = string
  default     = "22.04"
  validation {
    condition     = var.ubuntu_version == "22.04"
    error_message = "Please specify the correct ubuntu version, currently only 22.04 is supported"
  }
}

# Extra configuration for Red5 Pro autoscaling nodes
variable "node_config_webhooks" {
  description = "Webhooks configuration - (Optional) https://www.red5.net/docs/special/webhooks/overview/"
  type = object({
    enable           = bool
    target_nodes     = list(string)
    webhook_endpoint = string
  })
  default = {
    enable           = false
    target_nodes     = []
    webhook_endpoint = ""
  }
}
variable "node_config_round_trip_auth" {
  description = "Round trip authentication configuration - (Optional) https://www.red5.net/docs/special/authplugin/simple-auth/"
  type = object({
    enable                   = bool
    target_nodes             = list(string)
    auth_host                = string
    auth_port                = number
    auth_protocol            = string
    auth_endpoint_validate   = string
    auth_endpoint_invalidate = string
  })
  default = {
    enable                   = false
    target_nodes             = []
    auth_host                = ""
    auth_port                = 443
    auth_protocol            = "https://"
    auth_endpoint_validate   = "/validateCredentials"
    auth_endpoint_invalidate = "/invalidateCredentials"
  }
}
variable "node_config_social_pusher" {
  description = "Social Pusher configuration - (Optional) https://www.red5.net/docs/development/social-media-plugin/rest-api/"
  type = object({
    enable       = bool
    target_nodes = list(string)
  })
  default = {
    enable       = false
    target_nodes = []
  }
}
variable "node_config_restreamer" {
  description = "Restreamer configuration - (Optional) https://www.red5.net/docs/special/restreamer/overview/"
  type = object({
    enable               = bool
    target_nodes         = list(string)
    restreamer_tsingest  = bool
    restreamer_ipcam     = bool
    restreamer_whip      = bool
    restreamer_srtingest = bool
  })
  default = {
    enable               = false
    target_nodes         = []
    restreamer_tsingest  = false
    restreamer_ipcam     = false
    restreamer_whip      = false
    restreamer_srtingest = false
  }
}
