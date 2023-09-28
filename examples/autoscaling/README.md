# OCI Red5 Pro Stream Manager cluster with Oracle Cloud autoscaling Stream Managers

This example illustrates how to create Red5 Pro Stream Manager cluster with oracle autoscalling stream manager in OCI.

* VCN create or use existing
* Network Security groups will be created automatically or user existing (Stream Manager, Terraform Service, Nodes, MySQL DB System and others)
* MySQL DB will be created automaticaly in Oracle Cloud MySQL DB System 
* Create a dedicated OCI instance for Terraform Server
* Create SSL certificate using CA certificate authority files
* Load Balancer for Stream Managers will be created automatically
* Autoscaling configuration for Stream Managers will be created automatically
* Stream Manager image will be created automatically
* Instance configuration for Stream Managers will be created automatically
* Origin node image create or not (it is optional)
* Edge node image create or not (it is optional)
* Transcoder node image create or not (it is optional)
* Relay node image create or not (it is optional)
* Autoscaling node group using API to Stream Manager (optional) - (https://www.red5pro.com/docs/special/concepts/nodegroup/)

## Preparation

* Install **terraform** https://developer.hashicorp.com/terraform/downloads
* Install **OCI CLI** https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm
* Install **jq** Linux or Mac OS only - `apt install jq` or `brew install jq` (It is used in bash scripts to create/delete Stream Manager node group using API) https://jqlang.github.io/jq/
* Download Red5 Pro server build: (Example: red5pro-server-0.0.0.b0-release.zip) https://account.red5pro.com/downloads
* Download Red5 Pro Autoscale controller for Terraform: (Example: terraform-cloud-controller-0.0.0.jar) https://account.red5pro.com/downloads
* Download Red5 Pro Terraform Service : (Example: terraform-service-0.0.0.zip) https://account.red5pro.com/downloads
* Get Red5 Pro License key: (Example: 1111-2222-3333-4444) https://account.red5pro.com
* Prepare Oracle Cloud access user for Terraform
    * Identity and Access Management Rights (management access rights)
        * Virtual Cloud Networks
        * Compute Instances
        * Instance Configurations
        * Autoscaling Configurations
        * Load balancers
        * MySQL DB Systems 
        * OCI Certificates
    * Generate API keys for Oracle Cloud user(Required for Oracle Cloud CLI support)
        * Follow the documentation for generating keys on OCI Documentation - https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two
    * Upload your API keys to Oracle Cloud 
        * Follow the documentation for uploading your keys on OCI Documentation - https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two
        * After uploading the keys to Oracle Cloud, get API key's fingerprint displayed (for example, `12:34:56:78:90:11:cd:ef:12:34:56:78:90:ba:cd:ef`)
    * Create an OCI compartment for creating resources in Oracle Cloud Account 
        * Follow the documentation for creating a compartment - https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm#two
    * Get the necessary OCIDs from Oracle Cloud Account
        * Compartment OCID 
        * Tenancy OCID
        * User OCID
    * Authenticating OCI CLI
        * Token-based Authentication for the OCI CLI - https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/clitoken.htm
        * Custom OCI CLI Configuration(Override the Default Configuration) - https://www.ateam-oracle.com/post/oracle-cloud-infrastructure-cli-scripting-how-to-quickly-override-the-default-configuration
* Copy Red5 Pro server build, Autoscale controller for Terraform and Terraform Service to the root folder of your project

Example:  

```bash
cp ~/Downloads/red5pro-server-0.0.0.b0-release.zip ./
cp ~/Downloads/terraform-cloud-controller-0.0.0.jar ./
cp ~/Downloads/terraform-service-0.0.0.zip ./
```

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## Notes

* To activate HTTPS/SSL you need to add DNS A record for Elastic IP of Red5 Pro server
* Note that this example may create resources which can cost money. Run `terraform destroy` when you don't need these resources.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_red5pro_stream_manager_autoscaling"></a> [red5pro\_stream\_manager\_autoscaling](#module\_red5pro\_stream\_manager\_autoscaling) | ../../ | N/A |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_dns_name"></a> [load\_balancer\_dns\_name](#output\_load\_balancer\_dns\_name) | Load Balancer DNS Name |
| <a name="output_load_balancer_http_url"></a> [load\_balancer\_http\_url](#output\_load\_balancer\_http\_url) | Load Balancer HTTP URL |
| <a name="output_load_balancer_https_url"></a> [load\_balancer\_https\_url](#output\_load\_balancer\_https\_url) | Load Balancer HTTPS URL |
| <a name="output_mysql_host"></a> [mysql\_host](#output\_mysql\_host) | MySQL host |
| <a name="output_node_origin_image"></a> [node\_origin\_image](#output\_node\_origin\_image) | Oracle Cloud custom image name of the Red5 Pro Node Origin image |
| <a name="output_ssh_key_name"></a> [ssh\_key\_name](#output\_ssh\_key\_name) | SSH key name |
| <a name="output_ssh_private_key_path"></a> [ssh\_private\_key\_path](#output\_ssh\_private\_key\_path) | SSH private key path |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | Oracle Cloud VCN ID |
| <a name="output_vcn_name"></a> [vcn\_name](#output\_vcn\_name) | Oracle Cloud VCN Name |
