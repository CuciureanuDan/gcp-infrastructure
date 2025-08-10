# Project Overview

This project establishes a complete DevOps ecosystem on Google Cloud Platform (GCP). It includes infrastructure provisioning, application containerization, and an automated CI/CD pipeline. To ensure stability and performance, the architecture includes secure service networking and a comprehensive monitoring stack for full system observability. 

### Prerequisites

Before you can run this project, you need to setup your environment with the necessary credentials. Terraform was used for infrastructure provisioning, which requires access to your GCP and Cloudns accounts.

The file `infrastructure/terraform.tfvars` contains sensitive information, like the Cloudns credentials and GCP project ID. The file looks like bellow:

```
project = "<project_id>"
cloudns_auth_id = "<id>"
cloudns_password = "<pass>"
```

- To connect to GCP follow the official GCP documentation [here](https://cloud.google.com/docs/authentication/gcloud).

- Your Cloudns username and password are required for DNS record management. Follow the [official documentation](https://www.cloudns.net/wiki/article/42/).
