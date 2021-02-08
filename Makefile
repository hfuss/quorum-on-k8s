.PHONY: clean setup deploy test k8s build debug

clean:
	helm delete -n kaleido quorum || true
	kubectl delete --ignore-not-found -n kaleido pvc,configmap,job,pod -l 'app.kubernetes.io/name=quorum'

build:
	./hack/build-images.sh

deploy:
	./hack/deploy.sh

test:
	helm test quorum -n kaleido --logs

debug:
	helm template --debug /charts/quorum

k8s:
	./hack/start-minikube.sh
	kubectl create ns kaleido || true
