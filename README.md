# home-server

[![main](https://github.com/guyzsarun/home-server/actions/workflows/main.yml/badge.svg)](https://github.com/guyzsarun/home-server/actions/workflows/main.yml)


Project Structure
```
.
├── kubernetes                          # kubernetes manifests
├── packer                              # packer vm templates
└── terraform                           # terraform iac
    └── _talos                          # talos kubernetes cluster config
    └── modules                         
        └── kubernetes                  # kubernetes cluster essentials
        └── talos-k8s                   # talos kubernetes vm
        └── talos-patch                 # talos kubernetes vm patch
        └── vm                          # jumphost / router vm
        └── vm-templates                # vm templates
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

terraform -chdir=./terraform apply -target module.talos-k8s
```
2. Update talos kubernetes master/worker ip in `terraform.tfvars` 
```
talos_master_ip = ""
talos_worker_ip = [ "" ]
```
3. Initialize/patch Talos Kubernetes cluster

```
terraform -chdir=./terraform apply -target module.talos-patch
```
4. Apply metrics-server / loadbalancer
```
terraform -chdir=./terraform apply -target module.kubernetes
```

5. (Optional) Apply base kubernetes cluster config
```
# install istio
istioctl install -f ./kubernetes/istio/istio-config.yaml 

kubectl apply -f ./kubernetes/monitoring
```
