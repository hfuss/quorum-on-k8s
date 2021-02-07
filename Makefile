.PHONY: clean setup deploy test k8s build

clean:
	helm delete -n kaleido quorum || true
	kubectl delete --ignore-not-found -n kaleido pvc,configmap,job -l 'app.kubernetes.io/name=quorum'

build:
	./hack/build-images.sh

deploy:
	./hack/deploy.sh

test:
	./hack/pvc-viewer.sh quorum-config kaleido

k8s:
	./hack/start-minikube.sh
	kubectl create ns kaleido || true
