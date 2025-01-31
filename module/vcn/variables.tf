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


variable "kafka_public_ip" {
  description = "Expose Kafka on public ip true/false"
  type        = bool
  default     = false
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

# Oracle Cloud Prvider basic configuration settings
variable "oracle_compartment_id" {
  description = "Oracle Cloud Compartment OCID to create the resources, https://cloud.oracle.com/identity/compartments"
  type        = string
}

variable "kafka_standalone_instance_create" {
  description = "Create a new Kafka standalone instance true/false"
  type        = bool
  default     = false
}
