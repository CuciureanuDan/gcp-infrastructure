
# Project Overview

This project establishes a complete DevOps ecosystem on Google Cloud Platform (GCP). It includes infrastructure provisioning, application containerization, and an automated CI/CD pipeline. To ensure stability and performance, the architecture includes secure service networking and a comprehensive monitoring stack for full system observability. 

## Prerequisites

Before you can run this project, you need to setup your environment with the necessary credentials. Terraform was used for infrastructure provisioning, which requires access to your GCP and Cloudns accounts.

The file `infrastructure/terraform.tfvars` contains sensitive information, like the Cloudns credentials and GCP project ID. The file looks like bellow:

```
project = "<project_id>"
cloudns_auth_id = "<id>"
cloudns_password = "<pass>"
```

- To connect to GCP follow the official GCP documentation [here](https://cloud.google.com/docs/authentication/gcloud).

- Your CloudNS username and password are required for DNS record management. Follow the [official documentation](https://www.cloudns.net/wiki/article/42/).

## Infrastructure configuration

The `infrastructure/` directory contain Terraform code that provisions the entire environment on GCP, along with the automated DNS management via CloudNS.


| Component         | Details |
|-------------------|---------|
| **Cloud Provider** | Google Cloud Platform (GCP) |
| **Compute**       | 3 Debian-based VM instances with external IPs |
| **Networking**    | Custom VPC with a `/24` subnet (`10.0.0.0/24`) |
| **DNS**           | Automated A record creation via CloudNS provider |
| **Storage**       | 10GB persistent disks attached to each VM |

### Firewall Configuration

| Port(s)         | Purpose | Scope |
|-----------------|---------|-------|
| **22**          | SSH access to all nodes | Global access |
| **51820**       | WireGuard VPN server (node-1) | Server node only |
| **2377, 7946, 4789** | Docker Swarm cluster communication | Internal cluster only |
| **4444**        | Jenkins agent connectivity | CI/CD access |
| **8080**        | HTTP web service exposure | Public |


## Configuration Management

The `configuration/` directory contains **Ansible playbooks** and **roles** used to configure and secure all VMs in the GCP cluster. It covers base system setup, networking, VPN configuration, and Jenkins agent deployment. 

Before running any of the playbooks, setup the inventory with your personal IP addresses or DNS records, the correct ssh usernames and desired hostnames.  

- `playbooks/main-configuration.yml`:

This playbooks update and upgrade system packages, configure a unique hostname for each VM, and install Docker on all instances.

- `playbooks/networking-config.yml`

This playbook configures `iptables` to allow all traffic between the cluster VMs, permit SSH access from the control machine to each node, and enable HTTP and HTTPS access from any location for public services.

**Note 1:** Before running this playbook, configure the associated `roles/firewall-rules/defaults/main.yml` file with the internal IP addresses of the VMs and the IP address of the control machine.  
**Note 2:** Currently, the `iptables` configuration is not persistent. If a VM is restarted, the rules will be lost and the playbook must be run again (work in progress).
- `playbooks/wg-install.yml`:

This playbook installs and configures WireGuard to create a VPN in a star topology, with one VM acting as the server and the other two as clients. It generates and distributes the necessary keys, applies configuration files, and enables IP forwarding on the server. A firewall rule restricts traffic on the VPN interface to ICMP only, ensuring that each VM can ping the other two.

- `playbooks/jenkins-agent-install`:

This playbook deploys a Jenkins SSH agent container with Docker capabilities, designed to serve as a build agent for Jenkins CI/CD pipelines.

**Note 3:** Before running this playbook, create a new **SSH credentials** entry in Jenkins for the private key. The corresponding **public key** must be inserted in `roles/jenkins-agent/defaults/main.yml`.  
**Note 4:** If the Jenkins controller is not running on the current machine, the connection may fail due to firewall restrictions. In this case, create a new `iptables` rule to allow inbound connections from the Jenkins controller.

## Docker Swarm

Docker Swarm must be installed and initialized on all cluster nodes, with **node01** acting as the manager. Follow the [official Docker documentation](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/) to create and join the swarm.


## CI/CD 

The CI/CD process is implemented with **Jenkins**, with the Jenkins controller running on the current machine (local PC) and executing builds on the Swarm manager node.

**Pipeline Overview:**
1. **Checkout** – Pulls the `application` branch from the project repository *(just for the moment)*.
2. **Docker Login** – Authenticates with Docker Hub using stored credentials. The image is stored in a private repository.
3. **Build & Push** – Executes `build.sh` to build the Docker image and push it to Docker Hub.
4. **Deploy** – Executes `deploy.sh` to deploy the application stack to the Swarm with 3 replicas, one on each node.

## Monitoring

For now the monitoring stack (Prometheus + Grafana) is only on the `monitoring` branch. A new VM was added to GCP within the same VPC and given the `monitoring` network tag. This VM was provisioned specifically for monitoring purposes.

To get access to Prometheus and Grafana UI a new variable: `admin_ip` must be added to `infrastructure/terraform.tfvars` with the current machine IP.

**Node Exporter** (port 9100) must be installed in all the VMs from the cluster. It can be added with: 
```
docker run -d   --net="host"   --pid="host"   -v "/:/host:ro,rslave"   quay.io/prometheus/node-exporter:latest   --path.rootfs=/host
```

**cAdvisor** (port 18080) must be installed to collect metrics from containers. It can be added with: 
```
docker run -d \
  --name=cadvisor \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=18080:18080 \
  gcr.io/cadvisor/cadvisor:v0.49.1 \
  --port=18080
```

**Note 5**: New iptables rules need to allow TCP traffic on port 9100 and 18080 from any host in the `10.0.0.0/24` subnet.

**Blackbox Exporter** (port 9155) was added to monitor network reachability and performance. In this setup, it is used to measure VPN latency across all possible connections: *server -> clients* , *clients -> server* , *between clients*. The collected metrics are visualized in Grafana. Like the other exporters, Blackbox Exporter requires a dedicated port to be opened in `iptables`.  
To install and integrate it with Prometheus run this to download and extract the binary:
```
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.27.0/blackbox_exporter-0.27.0.linux-amd64.tar.gz

tar -xzf blackbox_exporter-0.27.0.linux-amd64.tar.gz

sudo mv blackbox_exporter-0.27.0.linux-amd64/blackbox_exporter /usr/local/bin/
```
Than place the `config.yml` file into `/etc/blackbox_exporter/config.yml` and create a systemd service file at: `/etc/systemd/system/blackbox_exporter.service`. After this the service must be enabled and started:
```
sudo systemctl daemon-reload
sudo systemctl enable blackbox_exporter
sudo systemctl start blackbox_exporter
```
