# Stream Manager 2.0 cluster with autoscaling nodes in Multi Region (Cluster in Multi Region)

In the following example, Terraform module will automates the infrastructure provisioning of the Stream Manager 2.0 cluster with Red5 Pro (SM2.0) Autoscaling node group (origins, edges, transcoders, relays) in Multi Region

## Terraform Deployed Resources (Cluster in Multi Region)

### Main region

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

### Second region

- VCN
- Public subnet
- Internet getaway
- Route table
- Security list
- Security group for Red5 Pro (SM2.0) Autoscaling nodes
- SSH key pair (use existing)
- Red5 Pro (SM2.0) node instance image (origins, edges, transcoders, relays)


## Example main.tf (Cluster in Multi Region)

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

📄 Example config file: [`node-group-config-example.json`](node-group-config-example.json)  
📚 Official documentation: [Red5 Pro – Create Node Group on OCI](https://www.red5.net/docs/red5-pro/users-guide/stream-manager-2-0/installation/oci/red5-pro-sm2-oci-create-node-group/)

---
