
# OCI Red5 Pro single server

This example illustrates how to create a simple Red5 Pro deployment in OCI with single Red5 Pro server.

* VCN create or use existing
* Security group create or use existing
* SSL certificate install Let's encrypt or use Red5Pro server without SSL certificate (HTTP only)


## Preparation

* Install **terraform** https://developer.hashicorp.com/terraform/downloads
* Install **OCI CLI** https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm
* Install **jq** Linux or Mac OS only - `apt install jq` or `brew install jq` (It is using in bash scripts to create/delete Stream Manager node group using API)
* Download Red5 Pro server build: (Example: red5pro-server-0.0.0.b0-release.zip) https://account.red5pro.com/downloads
* Get Red5 Pro License key: (Example: 1111-2222-3333-4444) https://account.red5pro.com
* Prepare Oracle Cloud access user for Terraform
    * Identity and Access Management Rights (management access rights)
        * Virtual Cloud Networks
        * Compute Instances
        * Instance Configurations
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
    * Authenticating OCI CLI
        * Token-based Authentication for the OCI CLI - https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/clitoken.htm
        * Custom OCI CLI Configuration(Override the Default Configuration) - https://www.ateam-oracle.com/post/oracle-cloud-infrastructure-cli-scripting-how-to-quickly-override-the-default-configuration
* Copy Red5 Pro server build to the root folder of your project

Example:  

```bash
cp ~/Downloads/red5pro-server-0.0.0.b0-release.zip ./
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
| <a name="module_red5pro_single"></a> [red5pro\_single](#module\_red5pro\_single) | ../../ | N/A |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_red5pro_server_http_url"></a> [red5pro\_server\_http\_url](#output\_red5pro\_server\_http\_url) | Red5 Pro Server HTTP URL |
| <a name="output_red5pro_server_https_url"></a> [red5pro\_server\_https\_url](#output\_red5pro\_server\_https\_url) | Red5 Pro Server HTTPS URL |
| <a name="output_red5pro_server_ip"></a> [red5pro\_server\_ip](#output\_red5pro\_server\_ip) | Red5 Pro Server IP |
| <a name="output_ssh_key_name"></a> [ssh\_key\_name](#output\_ssh\_key\_name) | SSH key name |
| <a name="output_ssh_private_key_path"></a> [ssh\_private\_key\_path](#output\_ssh\_private\_key\_path) | SSH private key path |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | Oracle Cloud VCN ID |
| <a name="output_vcn_name"></a> [vcn\_name](#output\_vcn\_name) | Oracle Cloud VCN Name |
