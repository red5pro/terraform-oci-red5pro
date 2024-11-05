# Stream Manager 2.0 (AS) without SSL certificate

It is simple docker-compose.yaml which include main Stream Manager 2.0 (AS) services without SSL certificate and HTTPS.
This example is usefull if SSL termination is working on the Load Balancer or on the CloudFlare

## Micro Services

* kafka
* as-admin
* as-terraform
* as-proxy
* as-autoscale-service
* as-auth
* as-streams
* reverse-proxy
* as-testbeds
* kafka-ui
* as-debug-ui

## Main Configuration Variables

To deploy the application, you need to configure the environment variables. The main example variables are provided in the file named `.example.env.`  

Follow these steps to set up the environment:

* Rename the file from `.example.env` to `.env`
* Place the renamed `.env` file in the same directory as your `docker-compose.yaml` file.

This will ensure that Docker Compose can read the environment variables correctly during deployment.

```conf
R5AS_AUTH_SECRET=<SECRET_KEY>
R5AS_AUTH_USER=<USER_NAME>
R5AS_AUTH_PASS=<PASSWORD>
KAFKA_HOST=<PRIVATE_IP>
```

## Cloud variables for as-terraform service

Each cloud provider has own cloud variables (OCI, AWS, LINODE)  
These variables can be configured directly in the `docker-compose.yaml` file.

### OCI specific variables

```yaml
TF_VAR_oci_tenancy_ocid: ocid1.tenancy.oc1..
TF_VAR_oci_compartment_id: ocid1.compartment.oc1..
TF_VAR_oci_user_ocid: ocid1.user.oc1..
TF_VAR_oci_fingerprint: 00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd:ee:ff
TF_VAR_oci_private_key_path: /home/ubuntu/.ssh/oracle_private_api_key.pem
TF_VAR_oci_node_ssh_public_key_path: /home/ubuntu/.ssh/red5pro_ssh_public_key.pub
```

* `TF_VAR_oci_tenancy_ocid` -  Oracle cloud tenancy OCID. Follow the [docs](https://docs.oracle.com/en-us/iaas/Content/Identity/tenancy/managingtenancy.htm) to get tenancy OCID
* `TF_VAR_oci_compartment_id` - Oracle cloud compartment OCID. Follow the [docs](https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/contactingsupport_topic-Locating_Oracle_Cloud_Infrastructure_IDs.htm#Finding_the_OCID_of_a_Compartment) to get compartment OCID
* `TF_VAR_oci_user_ocid` - Oracle cloud user OCID. You can get user OCID details in the Profile &rarr; User information
* `TF_VAR_oci_fingerprint` - Fingerprint of Oracle cloud API ssh key. Follow the [docs](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two) to get Fingerprint
* `TF_VAR_oci_private_key_path` - Provide path to the private Oracle cloud API SSH key. Follow the [docs](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#two) to generate new API SSH key. It should be uploaded to the Stream Manager 2.0 instance and mounted in the docker-compose.yaml file.
* `TF_VAR_oci_node_ssh_public_key_path` - Provide path to the public SSH key. It will be using for SSH connect to Red5 Pro nodes. You can generate SSH key par using `ssh-keygen` in Linux or MacOS command line. Or you can use the same `*.pub` key which you used to deploy Stream Manager 2.0 instance. It should be uploaded to the Stream Manager 2.0 instance and mounted in the docker-compose.yaml file.

---
Example `as-terraform` service configuration for OCI

```yaml
  as-terraform:
    deploy:
      replicas: 1
    image: red5pro/as-terraform:latest
    depends_on:
      kafka0:
        condition: service_healthy
    environment:
      R5AS_AUTOSCALE_PARTITIONS: 2
      R5AS_REPLICATION_FACTOR: 1
      R5AS_BOOTSTRAP_SERVERS: kafka0:29092
      R5AS_SECURITY_PROTOCOL_CONFIG: ""
      R5AS_SSL_KEYSTORE_TYPE_CONFIG: ""
      R5AS_SSL_TRUSTSTORE_TYPE_CONFIG: ""
      R5AS_SSL_CA_CERTIFICATE: ""
      R5AS_SASL_USERNAME: ""
      R5AS_SASL_PASSWORD: ""
      R5AS_SASL_ENABLED_MECHANISMS: ""
      R5AS_COMMAND_INACTIVITY_GAP_MS: 10000
      TF_VAR_oci_tenancy_ocid: ocid1.tenancy.oc1..
      TF_VAR_oci_user_ocid: ocid1.user.oc1..
      TF_VAR_oci_compartment_id: ocid1.compartment.oc1..
      TF_VAR_oci_fingerprint: 00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd:ee:ff
      TF_VAR_oci_private_key_path: /home/ubuntu/.ssh/oracle_private_api_key.pem
      TF_VAR_oci_node_ssh_public_key_path: /home/ubuntu/.ssh/red5pro_ssh_public_key.pub
      TF_VAR_r5p_license_key: 1111-2222-3333-4444
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./keys/oracle_private_api_key.pem:/home/ubuntu/.ssh/oracle_private_api_key.pem
      - ./keys/red5pro_ssh_public_key.pub:/home/ubuntu/.ssh/red5pro_ssh_public_key.pub
```

---

### AWS specific variables

```yaml
TF_VAR_aws_access_key: REPLACE_AWS_ACCESS_KEY
TF_VAR_aws_secret_key: REPLACE_AWS_SECRET_KEY
TF_VAR_aws_ssh_key_pair: REPLACE_AWS_SSH_KEY_NAME
TF_VAR_enable_root_volume_block_encryption: true
```

* `TF_VAR_aws_access_key` - AWS access key to authenticate with AWS account. Follow the [docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) to create
* `TF_VAR_aws_secret_key` - AWS secret key to authenticate with AWS account. Follow the [docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) to create
* `TF_VAR_aws_ssh_key_pair` - SSH key name. It will be using for SSH connect to Red5 Pro nodes. Follow the [docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html) to create SSH key pair in AWS.
* `TF_VAR_enable_root_volume_block_encryption` - Enable or disable root block volume encryption for node instance. Defaults to true.

---
Example `as-terraform` service configuration for AWS

```yaml
  as-terraform:
    deploy:
      replicas: 1
    image: red5pro/as-terraform:latest
    depends_on:
      kafka0:
        condition: service_healthy
    environment:
      R5AS_AUTOSCALE_PARTITIONS: 2
      R5AS_REPLICATION_FACTOR: 1
      R5AS_BOOTSTRAP_SERVERS: kafka0:29092
      R5AS_SECURITY_PROTOCOL_CONFIG: ""
      R5AS_SSL_KEYSTORE_TYPE_CONFIG: ""
      R5AS_SSL_TRUSTSTORE_TYPE_CONFIG: ""
      R5AS_SSL_CA_CERTIFICATE: ""
      R5AS_SASL_USERNAME: ""
      R5AS_SASL_PASSWORD: ""
      R5AS_SASL_ENABLED_MECHANISMS: ""
      R5AS_COMMAND_INACTIVITY_GAP_MS: 10000
      TF_VAR_aws_access_key: REPLACE_AWS_ACCESS_KEY
      TF_VAR_aws_secret_key: REPLACE_AWS_SECRET_KEY
      TF_VAR_aws_ssh_key_pair: REPLACE_AWS_SSH_KEY_NAME
      TF_VAR_enable_root_volume_block_encryption: true
      TF_VAR_r5p_license_key: 1111-2222-3333-4444
```

---

### Linode specific variables

```yaml
TF_VAR_linode_api_token: REPLACE_LINODE_API_TOKEN
TF_VAR_linode_root_user_password: REPLACE_LINODE_SECRET_KEY
TF_VAR_linode_ssh_key_name: REPLACE_LINODE_SSH_KEY_NAME
```

* `TF_VAR_linode_api_token` - Linode API token to authenticate with cloud. Follow the [docs](https://cloud.linode.com/profile/tokens) to create
* `TF_VAR_linode_root_user_password` - Provide the root user password for Red5 Pro nodes. Root user password must lies between 11-64 character.
* `TF_VAR_linode_ssh_key_name` - SSH key name. It will be using for SSH connect to Red5 Pro nodes. Follow the [docs](https://techdocs.akamai.com/cloud-computing/docs/manage-ssh-keys) to create SSH key pair in Linode.

---
Example `as-terraform` service configuration for Linode

```yaml
  as-terraform:
    deploy:
      replicas: 1
    image: red5pro/as-terraform:latest
    depends_on:
      kafka0:
        condition: service_healthy
    environment:
      R5AS_AUTOSCALE_PARTITIONS: 2
      R5AS_REPLICATION_FACTOR: 1
      R5AS_BOOTSTRAP_SERVERS: kafka0:29092
      R5AS_SECURITY_PROTOCOL_CONFIG: ""
      R5AS_SSL_KEYSTORE_TYPE_CONFIG: ""
      R5AS_SSL_TRUSTSTORE_TYPE_CONFIG: ""
      R5AS_SSL_CA_CERTIFICATE: ""
      R5AS_SASL_USERNAME: ""
      R5AS_SASL_PASSWORD: ""
      R5AS_SASL_ENABLED_MECHANISMS: ""
      R5AS_COMMAND_INACTIVITY_GAP_MS: 10000
      TF_VAR_linode_api_token: REPLACE_LINODE_API_TOKEN
      TF_VAR_linode_root_user_password: REPLACE_LINODE_SECRET_KEY
      TF_VAR_linode_ssh_key_name: REPLACE_LINODE_SSH_KEY_NAME
      TF_VAR_r5p_license_key: 1111-2222-3333-4444
```

---

## Red5 Pro variables for as-terraform service

```yaml
TF_VAR_r5p_license_key: 1111-2222-3333-4444
```

* `TF_VAR_r5p_license_key` - Red5 Pro license key which will be using on the Red5 Pro nodes. It should be active [Red5 Pro license key](https://account.red5.net/overview), Startup Pro level or higher.

> **Note:** clustering and autoscaling are not supported by `TRIAL` or `DEVELOPER` license type.
