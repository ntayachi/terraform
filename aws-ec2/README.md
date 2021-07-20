# Amazon Web Services: EC2, EBS, Route 53

This is an example of how to deploy an EC2 machine in Amazon cloud.

It also involves EBS volumes and Route 53 service.

## Pre-requisites

- Install [terrform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

## Steps

### Configure the AWS provider

Follow this [link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) to set up and authenticate terraform with AWS.

### Initialize the Terraform working directory

```
terraform init
```

### Deploy the resources to AWS

```
terraform apply
```

- To specify variables on the command line:

```
terraform apply -var="aws_region=us-east-1" -var="aws_az=us-east-1a" -var="route35_zone=dev.com"
```

- To generate the execution plan and only show the actions:

```
terraform plan
```

### Destroy the resources provisioned

```
terraform destroy
```