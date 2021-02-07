#!/bin/bash

vm=$([[ "${OSTYPE}" == "darwin"* ]] && echo 'true')
minikube start --vm=${vm}
minikube addons enable ingress
