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
    condition     = var.type == "cluster" || var.type == "autoscale"
    error_message = "The type value must be a valid! Example: autoscale, cluster or autoscale"
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


# Red5 Pro Cluster Configuration
variable "red5pro_stream_manager_network_security_group_id" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "red5pro_kafka_network_security_group_id" {
  type = string
}

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
variable "kafka_standalone_instance_archive_url" {
  description = "Kafka standalone instance - archive URL"
  type        = string
  default     = "https://downloads.apache.org/kafka/3.8.0/kafka_2.13-3.8.0.tgz"
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

variable "ubuntu_version" {
  description = "Ubuntu version"
  type        = string
  default     = "22.04"
  validation {
    condition     = var.ubuntu_version == "22.04"
    error_message = "Please specify the correct ubuntu version, currently only 22.04 is supported"
  }
}

variable "kafka_public_ip" {
  description = "Expose Kafka on public ip true/false"
  type        = bool
  default     = false
}

variable "node_image_display_name" {
  description = "Override created node image's name"
  type        = string
  default     = ""
}
