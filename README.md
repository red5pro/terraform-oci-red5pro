# Terraform Module for Deploying Red5 Pro Oracle Cloud Infrastructure (OCI) - Stream Manager 2.0

[Red5 Pro](https://www.red5.net/) is a real-time video streaming server plaform known for its low-latency streaming capabilities, making it ideal for interactive applications like online gaming, streaming events and video conferencing etc.

This is a reusable Terraform module that provisions infrastructure on [Oracle Cloud Infrastructure (OCI)](https://www.oracle.com/cloud/).

## Preparation

### Install Terraform

- Visit the [Terraform download page](https://developer.hashicorp.com/terraform/downloads) and ensure you get version 1.7.5 or higher.
- Download the suitable version for your operating system.
- Extract the compressed file and copy the Terraform binary to a location within your system's PATH.
- Configure PATH for **Linux/macOS**:
  - Open a terminal and type the following command:

    ```sh
    sudo mv /path/to/terraform /usr/local/bin
    ```

- Configure PATH for **Windows**:
  - Click 'Start', search for 'Control Panel', and open it.
  - Navigate to `System > Advanced System Settings > Environment Variables`.
  - Under System variables, find 'PATH' and click 'Edit'.
  - Click 'New' and paste the directory location where you extracted the terraform.exe file.
  - Confirm changes by clicking 'OK' and close all open windows.
  - Open a new terminal and verify that Terraform has been successfully installed.

  ```sh
  terraform --version
  ```

### Install jq

- Install **jq** (Linux or Mac OS only) [Download](https://jqlang.github.io/jq/download/)
  - Linux: `apt install jq`
  - MacOS: `brew install jq`
  > It is used in bash scripts to create/delete Stream Manager node group using API

### Red5 Pro artifacts

- Download Red5 Pro server build in your [Red5 Pro Account](https://account.red5.net/downloads). Example: `red5pro-server-0.0.0.b0-release.zip`
- Get Red5 Pro License key in your [Red5 Pro Account](https://account.red5.net/downloads). Example: `1111-2222-3333-4444`

### Install Oracle Cloud Infrastructure (OCI) CLI

- [Installing the CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)

### Prepare OCI account

- Create a User for Terraform module. User must have permission to create and manage the following services:
  - Identity and Access Management Rights
    - Virtual Cloud Networks
    - Compute Instances
    - Instance Configurations
    - Autoscaling Configurations
    - Load balancers
    - OCI Certificates
  - Generate API key for OCI user. [OCI Documentation](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two)
  - Create an OCI compartment for Red5 Pro resources or use existing. [OCI Documentation](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm#two)
  - Obtain the necessary credentials and information:
    - Tenancy OCID
    - Compartment OCID
    - User OCID
    - API key Fingerprint
    - API private key file

## This module supports three variants of Red5 Pro deployments

- **standalone** - Standalone Red5 Pro server
- **cluster** - Stream Manager 2.0 cluster with autoscaling nodes
- **autoscale** - Autoscaling Stream Managers 2.0 with autoscaling nodes

### Standalone Red5 Pro server (standalone) - [Example](https://github.com/red5pro/terraform-oci-red5pro/tree/master/examples/standalone)

In the following example, Terraform module will automates the infrastructure provisioning of the [Red5 Pro standalone server](https://www.red5.net/docs/installation/).

#### Terraform Deployed Resources (standalone)

- VCN
- Public subnet
- Internet getaway
- Route table
- Security list
- Security group for Standalone Red5 Pro server
- SSH key pair (use existing or create a new one)
- Standalone Red5 Pro server instance
- SSL certificate for Standalone Red5 Pro server instance. Options:
  - `none` - Red5 Pro server without HTTPS and SSL certificate. Only HTTP on port `5080`
  - `letsencrypt` - Red5 Pro server with HTTPS and SSL certificate obtained by Let's Encrypt. HTTP on port `5080`, HTTPS on port `443`
  - `imported` - Red5 Pro server with HTTPS and imported SSL certificate. HTTP on port `5080`, HTTPS on port `443`

#### Example main.tf (standalone)

```hcl
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
  source                = "red5pro/red5pro/oci"
  type                  = "standalone"                            # Deployment type: standalone, cluster, autoscale, vcn
  name                  = "red5pro-standalone"                    # Name to be used on all the resources as identifier
  path_to_red5pro_build = "./red5pro-server-0.0.0.b0-release.zip" # Absolute path or relative path to Red5 Pro server ZIP file

  # Oracle Cloud Account Details
  oracle_compartment_id = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Existing Compartment OCID of Oracle Cloud Account

  # SSH key configuration
  ssh_key_use_existing              = false                                              # true - use existing SSH key, false - create new SSH key
  ssh_key_existing_private_key_path = "/PATH/TO/SSH/PRIVATE/KEY/example_private_key.pem" # Path to existing SSH private key
  ssh_key_existing_public_key_path  = "/PATH/TO/SSH/PUBLIC/KEY/example_pub_key.pem"      # Path to existing SSH Public key

  # Red5 Pro general configuration
  red5pro_license_key = "1111-2222-3333-4444" # Red5 Pro license key (https://account.red5.net/login)
  red5pro_api_enable  = true                  # true - enable Red5 Pro server API, false - disable Red5 Pro server API (https://www.red5.net/docs/development/api/overview/)
  red5pro_api_key     = "example_key"         # Red5 Pro server API key (https://www.red5.net/docs/development/api/overview/)

  # Standalone Red5 Pro server OCI instance configuration
  standalone_red5pro_instance_type   = "VM.Standard.E4.Flex" # Instance type for Red5 Pro server
  standalone_red5pro_instance_ocpu   = 2                     # Instance CPU for Red5 Pro server
  standalone_red5pro_instance_memory = 4                     # Instance Memory for Red5 Pro server

  # Standalone Red5 Pro server configuration
  standalone_red5pro_inspector_enable                    = false                         # true - enable Red5 Pro server inspector, false - disable Red5 Pro server inspector (https://www.red5.net/docs/troubleshooting/inspector/overview/)
  standalone_red5pro_restreamer_enable                   = false                         # true - enable Red5 Pro server restreamer, false - disable Red5 Pro server restreamer (https://www.red5.net/docs/special/restreamer/overview/)
  standalone_red5pro_socialpusher_enable                 = false                         # true - enable Red5 Pro server socialpusher, false - disable Red5 Pro server socialpusher (https://www.red5.net/docs/special/social-media-plugin/overview/)
  standalone_red5pro_suppressor_enable                   = false                         # true - enable Red5 Pro server suppressor, false - disable Red5 Pro server suppressor
  standalone_red5pro_hls_enable                          = false                         # true - enable Red5 Pro server HLS, false - disable Red5 Pro server HLS (https://www.red5.net/docs/protocols/hls-plugin/hls-vod/)
  standalone_red5pro_round_trip_auth_enable              = false                         # true - enable Red5 Pro server round trip authentication, false - disable Red5 Pro server round trip authentication (https://www.red5.net/docs/special/round-trip-auth/overview/)
  standalone_red5pro_round_trip_auth_host                = "round-trip-auth.example.com" # Round trip authentication server host
  standalone_red5pro_round_trip_auth_port                = 3000                          # Round trip authentication server port
  standalone_red5pro_round_trip_auth_protocol            = "http"                        # Round trip authentication server protocol
  standalone_red5pro_round_trip_auth_endpoint_validate   = "/validateCredentials"        # Round trip authentication server endpoint for validate
  standalone_red5pro_round_trip_auth_endpoint_invalidate = "/invalidateCredentials"      # Round trip authentication server endpoint for invalidate

  # Standalone Red5 Pro server HTTPS (SSL) certificate configuration
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

output "module_output" {
  value = module.red5pro
}
```

### Stream Manager 2.0 cluster with autoscaling nodes (cluster) - [Example](https://github.com/red5pro/terraform-oci-red5pro/tree/master/examples/cluster)

In the following example, Terraform module will automates the infrastructure provisioning of the Stream Manager 2.0 cluster with Red5 Pro (SM2.0) Autoscaling node group (origins, edges, transcoders, relays)

#### Terraform Deployed Resources (cluster)

- VCN
- Public subnet
- Internet getaway
- Route table
- Security list
- Security group for Stream Manager 2.0
- Security group for Kafka
- Security group for Red5 Pro (SM2.0) Autoscaling nodes
- SSH key pair (use existing or create a new one)
- Standalone Kafka instance (optional).
- Stream Manager 2.0 instance. Optionally include a Kafka server on the same instance.
- SSL certificate for Stream Manager 2.0 instance. Options:
  - `none` - Stream Manager 2.0 without HTTPS and SSL certificate. Only HTTP on port `80`
  - `letsencrypt` - Stream Manager 2.0 with HTTPS and SSL certificate obtained by Let's Encrypt. HTTP on port `80`, HTTPS on port `443`
  - `imported` - Stream Manager 2.0 with HTTPS and imported SSL certificate. HTTP on port `80`, HTTPS on port `443`
- Red5 Pro (SM2.0) node instance image (origins, edges, transcoders, relays)
- Red5 Pro (SM2.0) Autoscaling node group (origins, edges, transcoders, relays)

#### Example main.tf (cluster)

```hcl
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
  source                = "red5pro/red5pro/oci"
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
```

### Autoscaling Stream Managers 2.0 with autoscaling nodes (autoscale) - [Example](https://github.com/red5pro/terraform-oci-red5pro/tree/master/examples/autoscale)

In the following example, Terraform module will automates the infrastructure provisioning of the Autoscale Stream Managers 2.0 with Red5 Pro (SM2.0) Autoscaling node group (origins, edges, transcoders, relays)

#### Terraform Deployed Resources (autoscale)

- VCN
- Public subnet
- Internet getaway
- Route table
- Security list
- Security group for Stream Manager 2.0
- Security group for Kafka
- Security group for Red5 Pro (SM2.0) Autoscaling nodes
- SSH key pair (use existing or create a new one)
- Standalone Kafka instance
- Stream Manager 2.0 instance image
- Instance poll for Stream Manager 2.0 instances
- Autoscaling configuration for Stream Manager 2.0 instances
- Application Load Balancer for Stream Manager 2.0 instances.
- SSL certificate for Application Load Balancer. Options:
  - `none` - Load Balancer without HTTPS and SSL certificate. Only HTTP on port `80`
  - `imported` - Load Balancer with HTTPS and imported SSL certificate. HTTP on port `80`, HTTPS on port `443`
- Red5 Pro (SM2.0) node instance image (origins, edges, transcoders, relays)
- Red5 Pro (SM2.0) Autoscaling node group (origins, edges, transcoders, relays)

#### Example main.tf (autoscale)

```hcl
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
  source                = "red5pro/red5pro/oci"
  type                  = "autoscale"                             # Deployment type: standalone, cluster, autoscale, vcn
  name                  = "red5pro-auto"                          # Name to be used on all the resources as identifier
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
  stream_manager_instance_type                = "VM.Standard.E4.Flex"      # OCI Instance type for Stream Manager
  stream_manager_instance_ocpu                = 4                          # OCI Instance OCPU Count for Stream Manager(1 OCPU = 2 vCPU)
  stream_manager_instance_memory              = 16                         # OCI Instance Memory size in GB for Stream Manager
  stream_manager_instance_volume_size         = 50                         # Volume size in GB for Stream Manager (minimum 50GB)
  stream_manager_auth_user                    = "example_user"             # Stream Manager 2.0 authentication user name
  stream_manager_auth_password                = "example_password"         # Stream Manager 2.0 authentication password
  stream_manager_proxy_user                   = "example_proxy_user"       # Stream Manager 2.0 proxy user name
  stream_manager_proxy_password               = "example_proxy_password"   # Stream Manager 2.0 proxy password
  stream_manager_spatial_user                 = "example_spatial_user"     # Stream Manager 2.0 spatial user name
  stream_manager_spatial_password             = "example_spatial_password" # Stream Manager 2.0 spatial password
  stream_manager_version                      = "latest"                   # Stream Manager 2.0 docker images version (latest, 14.1.0, 14.1.1, etc.) - https://hub.docker.com/r/red5pro/as-admin/tags
  stream_manager_autoscaling_desired_capacity = 1                          # Desired capacity for Stream Manager autoscaling group
  stream_manager_autoscaling_minimum_capacity = 1                          # Min capacity for Stream Manager autoscaling group
  stream_manager_autoscaling_maximum_capacity = 2                          # Max capacity for Stream Manager autoscaling group

  # Kafka standalone instance configuration
  kafka_standalone_instance_type        = "VM.Standard.E4.Flex" # OCI Instance type for Kafka standalone instance
  kafka_standalone_instance_ocpu        = 1                     # OCI Instance OCPU Count for Kafka standalone instance(1 OCPU = 2 vCPU)
  kafka_standalone_instance_memory      = 16                    # OCI Instance Memory size in GB for Kafka standalone instance
  kafka_standalone_instance_volume_size = 50                    # Volume size in GB for Kafka standalone instance (minimum 50GB)

  load_balancer_reserved_ip_use_existing = false     # true - use existing reserved IP for Load Balancer, false - create new reserved IP for Load Balancer, 
  load_balancer_reserved_ip_existing     = "1.2.3.4" # Reserved IP for Load Balancer

  # Stream Manager 2.0 Load Balancer HTTPS (SSL) certificate configuration
  https_ssl_certificate = "none" # none - do not use HTTPS/SSL certificate, imported - import existing HTTPS/SSL certificate

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
```

> - WebRTC broadcast does not work in WEB browsers without an HTTPS (SSL) certificate.
> - To activate HTTPS/SSL, you need to add a DNS A record for the public IP address of your Red5 Pro server or Stream Manager 2.0.

---

## Stream Manager 2.0 cluster with autoscaling nodes (Cluster in Multi Region)

In the following example, Terraform module will automates the infrastructure provisioning of the Stream Manager 2.0 cluster with Red5 Pro (SM2.0) Autoscaling node group (origins, edges, transcoders, relays) in Multi Region

### Terraform Deployed Resources (Cluster in Multi Region)

#### Main region

- VCN
- Public subnet
- Internet getaway
- Route table
- Security list
- Security group for Stream Manager 2.0
- Security group for Kafka
- Security group for Red5 Pro (SM2.0) Autoscaling nodes
- SSH key pair (use existing)
- Standalone Kafka instance (optional).
- Stream Manager 2.0 instance. Optionally include a Kafka server on the same instance.
- SSL certificate for Stream Manager 2.0 instance. Options:
  - `none` - Stream Manager 2.0 without HTTPS and SSL certificate. Only HTTP on port `80`
  - `letsencrypt` - Stream Manager 2.0 with HTTPS and SSL certificate obtained by Let's Encrypt. HTTP on port `80`, HTTPS on port `443`
  - `imported` - Stream Manager 2.0 with HTTPS and imported SSL certificate. HTTP on port `80`, HTTPS on port `443`
- Red5 Pro (SM2.0) node instance image (origins, edges, transcoders, relays)

#### Second region

- VCN
- Public subnet
- Internet getaway
- Route table
- Security list
- Security group for Red5 Pro (SM2.0) Autoscaling nodes
- SSH key pair (use existing)
- Red5 Pro (SM2.0) node instance image (origins, edges, transcoders, relays)

### Example main.tf (Cluster in Multi Region)

```hcl
terraform {
  required_version = ">= 1.7.5"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.16"
    }
  }
}

locals {
  name                  = "red5pro-cluster"
  region_main           = "us-ashburn-1"
  compartment_id        = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  tenancy_ocid          = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  user_ocid             = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  fingerprint           = "00:11:22:33:44:55:66:77:aa:bb:cc:dd:ee:ff:gg:hh"
  private_key_path      = "./example_oracle_private_key.pem"
  ssh_private_key_path  = "/PATH/TO/SSH/PRIVATE/KEY/example_private_key.pem"
  ssh_public_key_path   = "/PATH/TO/SSH/PUBLIC/KEY/example_pub_key.pem"
  red5pro_license_key   = "1111-2222-3333-4444"
  red5pro_api_enable    = true
  red5pro_api_key       = "example_key"
  path_to_red5pro_build = "./red5pro-server-0.0.0.b0-release.zip"
}

# Main OCI region where the Red5 Pro Stream Manager 2.0 cluster will be deployed
provider "oci" {
  region           = local.region_main
  tenancy_ocid     = local.tenancy_ocid
  user_ocid        = local.user_ocid
  fingerprint      = local.fingerprint
  private_key_path = local.private_key_path
}

# Secondary OCI region where the VCN and Node images will be created
provider "oci" {
  region           = "eu-frankfurt-1"
  alias            = "eu-frankfurt-1"
  tenancy_ocid     = local.tenancy_ocid
  user_ocid        = local.user_ocid
  fingerprint      = local.fingerprint
  private_key_path = local.private_key_path
}

module "red5pro" {
  source                = "../../"
  type                  = "cluster"                   # Deployment type: standalone, cluster, autoscale, vcn, vcn
  name                  = local.name                  # Name to be used on all the resources as identifier
  path_to_red5pro_build = local.path_to_red5pro_build # Absolute path or relative path to Red5 Pro server ZIP file

  # Oracle Cloud Account Details
  oracle_compartment_id   = local.compartment_id   # Compartment OCID of Oracle Cloud Account
  oracle_tenancy_ocid     = local.tenancy_ocid     # Tenancy OCID of Oracle Cloud Account
  oracle_user_ocid        = local.user_ocid        # User OCID of Oracle Cloud Account
  oracle_fingerprint      = local.fingerprint      # SSH based API key fingerprint of Oracle Cloud Account
  oracle_private_key_path = local.private_key_path # Path to SSH private key of Oracle Cloud Account
  oracle_region           = local.region_main      # Current region code name of Oracle Cloud Account, https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm

  # SSH key configuration
  ssh_key_use_existing              = true                       # true - use existing SSH key, false - create new SSH key
  ssh_key_existing_private_key_path = local.ssh_private_key_path # Path to existing SSH Private key
  ssh_key_existing_public_key_path  = local.ssh_public_key_path  # Path to existing SSH Public key

  # Red5 Pro general configuration
  red5pro_license_key = local.red5pro_license_key # Red5 Pro license key (https://www.red5.net/docs/development/installation/installation-guide/)
  red5pro_api_enable  = local.red5pro_api_enable  # true - enable Red5 Pro API, false - disable Red5 Pro API
  red5pro_api_key     = local.red5pro_api_key     # Red5 Pro API key (https://www.red5.net/docs/development/installation/installation-guide/)

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
  kafka_standalone_instance_create      = true                  # true - create new Kafka standalone instance, false - not create new Kafka standalone instance and use Kafka on the Stream Manager 2.0 instance
  kafka_standalone_instance_type        = "VM.Standard.E4.Flex" # OCI Instance type for Kafka standalone instance
  kafka_standalone_instance_ocpu        = 1                     # OCI Instance OCPU Count for Kafka standalone instance(1 OCPU = 2 vCPU)
  kafka_standalone_instance_memory      = 16                    # OCI Instance Memory size in GB for Kafka standalone instance
  kafka_standalone_instance_volume_size = 50                    # Volume size in GB for Kafka standalone instance (minimum 50GB)
  kafka_public_ip                       = true                  # true - Kafka open on public IP, false - Kafka open on private IP

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
}

output "module_output" {
  value = module.red5pro
}

######################################################################
# Secondary OCI region where the VCN and Node images will be created
######################################################################

module "red5pro_eu-frankfurt-1" {
  source                = "./terraform-oci-red5pro"
  type                  = "vcn"                       # Deployment type: standalone, cluster, autoscale, vcn, vcn
  name                  = local.name                  # Name to be used on all the resources as identifier
  path_to_red5pro_build = local.path_to_red5pro_build # Absolute path or relative path to Red5 Pro server ZIP file

  # Oracle Cloud Account Details
  oracle_compartment_id = local.compartment_id
  oracle_region         = "eu-frankfurt-1"

  # SSH key configuration
  ssh_key_use_existing              = true                       # true - use existing SSH key, false - create new SSH key
  ssh_key_existing_private_key_path = local.ssh_private_key_path # Path to existing SSH Private key
  ssh_key_existing_public_key_path  = local.ssh_public_key_path  # Path to existing SSH Public key

  # Red5 Pro general configuration
  red5pro_license_key = local.red5pro_license_key # Red5 Pro license key (https://www.red5.net/docs/development/installation/installation-guide/)
  red5pro_api_enable  = local.red5pro_api_enable  # true - enable Red5 Pro API, false - disable Red5 Pro API
  red5pro_api_key     = local.red5pro_api_key     # Red5 Pro API key (https://www.red5.net/docs/development/installation/installation-guide/)

  # Red5 Pro autoscaling Node image configuration
  node_image_create          = true                  # Default: true for Autoscaling and Cluster, true - create new Red5 Pro Node image, false - do not create new Red5 Pro Node image
  node_image_instance_type   = "VM.Standard.E4.Flex" # Instance type for Red5 Pro Node image
  node_image_instance_ocpu   = 1                     # OCI Instance OCPU Count for Red5 Pro Node image (1 OCPU = 2 vCPU)
  node_image_instance_memory = 4                     # OCI Instance Memory size in GB for Red5 Pro Node image
  node_image_stop_instance   = false

  providers = {
    oci = oci.eu-frankfurt-1
  }
}

output "module_output_eu-frankfurt-1" {
  value = module.red5pro_eu-frankfurt-1
}
```

---
> **Note:** In this deployment, you will need to create the Node Group configuration manually using `cURL`, `Swagger` or `Postman`.

📄 Example config file: [`node-group-config-example.json`](examples/cluster-multiregion/node-group-config-example.json)  
📚 Official documentation: [Red5 Pro – Create Node Group on OCI](https://www.red5.net/docs/red5-pro/users-guide/stream-manager-2-0/installation/oci/red5-pro-sm2-oci-create-node-group/)

---
