.PHONY: clean setup deploy test

clean:
	helm delete -n kaleido quorum || true
	kubectl delete -n kaleido pvc,configmap,job -l 'app.kubernetes.io/name=quorum'

setup:
	kubectl create ns kaleido || true

deploy: setup
	./hack/deploy.sh

test:
	./hack/pvc-viewer.sh quorum-config kaleido
