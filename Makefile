.PHONY: clean deploy test k8s build debug cert-manager cluster

clean:
	helm delete -n kaleido racecourse || true
	helm delete -n kaleido quorum || true
	kubectl delete --ignore-not-found -n kaleido pvc,configmap,job,pod -l 'app.kubernetes.io/name=quorum'

build:
	./hack/build-images.sh

deploy:
	./hack/deploy.sh

test:
	helm test quorum -n kaleido --logs
	helm test racecourse -n kaleido --logs

debug:
	helm template --debug /charts/quorum
	helm template --debug /charts/racecourse

cluster:
	./hack/start-minikube.sh
	kubectl create ns kaleido || true


cert-manager:
	kubectl create ns cert-manager || true
	kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.2.0-alpha.2/cert-manager.crds.yaml
	helm repo add jetstack https://charts.jetstack.io || true
	helm upgrade --install --skip-crds cert-manager --namespace cert-manager jetstack/cert-manager


k8s: cluster cert-manager
