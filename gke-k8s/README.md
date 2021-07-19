# Google Kubernetes Engine

The purpose of this is to deploy a simple microservice to GKE cluster using terraform.

The docker image **nginxdemos/hello** will be used for the microservice.

## Pre-requisites

- Install [terrform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Install [gcloud](https://cloud.google.com/sdk/docs/install)
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/) ( optional )

## Steps

### Authorize access to GCP with the service account

Before deploying resources to GCP, you need to authorize access to CGP for the service account using a key file.

Run the following command to authorize the access:

```
gcloud auth activate-service-account --project=my-project --key-file=my-key.json
```

Expected output:

```
Activated service account credentials for [**********.iam.gserviceaccount.com]
```

Test the following command to confirm the access:

```
gcloud container images list
```

Sample output:

```
$ gcloud container images list
NAME
gcr.io/***
gcr.io/***
gcr.io/***
```

### Authenticate Terraform to use the GCP API

To be able to deploy GCP resources using Terraform, you need to authenticate Terraform.

Run the following command to perform the authentication:

```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key/file/my-key.json
```

To read more about this, please visit this [link](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials).

### Initialize the Terraform working directory

```
terraform init
```

### Deploy the resources to GCP

```
terraform apply
```

- To generate the execution plan and only show the actions:

```
terraform plan
```

### Verify that the microservice is working

To validate that the microservice is running, you need to test the connection to the external IP where it is deployed.

You can achieve this in two ways:

#### Using gcloud

List the forwarding rules:

```
gcloud compute forwarding-rules list --filter description~my-project
```

Example:

```
$ gcloud compute forwarding-rules list --filter description~my-project
NAME                                             REGION  IP_ADDRESS     IP_PROTOCOL  TARGET
************          34.120.217.34  TCP          ************
```

Grab the IP from *IP_ADDRESS* column and type it in your browser, you should see **nginx** page with the following information:
- Server address
- Server name
- Date
- URI

#### Using kubectl

1. Fetch kubernetes credentials for the GKE cluster:

```
gcloud container clusters get-credentials my-cluster --zone=europe-west1-d
```

Expected output:

```
$ gcloud container clusters get-credentials my-cluster --zone=europe-west1-d
Fetching cluster endpoint and auth data.
kubeconfig entry generated for my-cluster.
```

2. List kubernetes Ingress resources

```
kubectl get ingress
```

Expected output:

```
$ kubectl get ingress
NAME            CLASS    HOSTS   ADDRESS         PORTS   AGE
my-ingress   <none>   *       34.120.217.34   80      40m
```

Grab the external IP and type it in your browser, you should see **nginx** page with the following information:
- Server address
- Server name
- Date
- URI

### Destroy the resources provisioned

```
terraform destroy
```