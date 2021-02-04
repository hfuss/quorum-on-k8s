# quorum-on-k8s
Learning more about blockchain by deploying Kaleido's Quorum and sample Racecourse app on Kubernetes.

## Getting Started

### Requirements

* minikube >= 1.16.0
* docker >= 20.0.0
* helm >= 3.0.0

### Setup

```bash
# assumes bash on linux or macos
vm=$([[ "${OSTYPE}" == "darwin"* ]] && echo 'true')
minikube start --vm=${vm}  
minikube addons enable ingress

# make sure everything is sound... 
kubectl get pods -n kube-system -w
```
