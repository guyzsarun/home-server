# home-server

[![main](https://github.com/guyzsarun/home-server/actions/workflows/main.yml/badge.svg)](https://github.com/guyzsarun/home-server/actions/workflows/main.yml)


Project Structure
```
.
├── kubernetes                          # kubernetes manifests
├── packer                              # packer vm templates
└── terraform                           # terraform iac
    └── _talos                          # talos kubernetes cluster config
```


## Pfsense Router
Pfsense router with zerotier plugin for VPC

Start and Join zerotier network
```
zerotier-one -d
zerotier-cli join XXXXX

# Check network status
zerotier-cli status
```

Network Interface
1. WAN - Linux Bridge ( vtnet0 )
2. LAN - VM Network   ( vtnet1)
3. OPT - Zerotier Network ( zte... )


## Kubernetes Cluster
1. Provision [Talos](https://www.talos.dev/) kubernetes vm

```
terraform -chdir=./terraform plan

terraform -chdir=./terraform apply -target proxmox_vm_qemu.kubernetes-worker_vm
```
2. Update talos kubernetes master/worker ip in `terraform.tfvars` 
```
talos_master_ip = ""
talos_worker_ip = [ "" ]
```
3. Initialize Talos Kubernetes clusters

```
terraform -chdir=./terraform apply -target null_resource.talos_kubernetes_setup
```
4. Get kubeconfig for the cluster
```
terraform -chdir=./terraform apply -target null_resource.talos_kubeconfig
```

5. (Optional) Apply base kubernetes cluster config
```
kubectl apply -f ./kubernetes

# install istio
istioctl install -f istio-config.yaml
```
