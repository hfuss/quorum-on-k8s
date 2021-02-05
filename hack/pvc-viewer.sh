#!/bin/bash

# utility script for debugging the contents of pvcs

pvc="${1}"
namespace="${2}"

uuid=$(uuidgen | tr '[:upper:]' '[:lower:]')
podname="pvc-viewer-${uuid:1:4}"
cat << EOF | kubectl apply -f - -n ${namespace}
---
kind: Pod
apiVersion: v1
metadata:
  name: ${podname}
spec:
  volumes:
    - name: pvc-viewer
      persistentVolumeClaim:
        claimName: ${pvc}
        readOnly: true
  containers:
    - name: pvc-viewer
      image: brix4dayz/swiss-army-knife
      command:
        - cat
      tty: true
      volumeMounts:
        - name: pvc-viewer
          mountPath: /pvc-viewer
EOF
kubectl wait pod/${podname} -n ${namespace} \
  --for=condition=ready --timeout=300s
kubectl exec --stdin --tty -n ${namespace} ${podname} -- /bin/sh
kubectl delete pod ${podname} -n ${namespace}
