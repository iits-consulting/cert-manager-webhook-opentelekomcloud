#!/bin/bash

# 1. Create registry container unless it already exists
# reg_name='kind-registry'
# reg_port='5001'
# if [ "$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)" != 'true' ]; then
#   docker run \
#     -d --restart=always -p "127.0.0.1:${reg_port}:5000" --network bridge --name "${reg_name}" \
#     registry:2
# fi

# 2. Create a KinD cluster
if kind get clusters | grep -q "cmw"; then
echo "A Kubernetes cluster with the name 'cmw' already exists."
mkdir ~/.kube && kind --name cmw export kubeconfig >> ~/.kube/config
chmod 600 ~/.kube/config
kubectl config use-context kind-cmw
else
kind create cluster --name=cmw --config .devcontainer/cluster.yaml

# 3. Add the registry config to the nodes
#
# This is necessary because localhost resolves to loopback addresses that are
# network-namespace local.
# In other words: localhost in the container is not localhost on the host.
#
# We want a consistent name that works from both ends, so we tell containerd to
# alias localhost:${reg_port} to the registry container when pulling images
# REGISTRY_DIR="/etc/containerd/certs.d/localhost:${reg_port}"
# for node in $(kind get nodes --name=cmw); do
#   docker exec "${node}" mkdir -p "${REGISTRY_DIR}"
#   cat <<EOF | docker exec -i "${node}" cp /dev/stdin "${REGISTRY_DIR}/hosts.toml"
# [host."http://${reg_name}:5000"]
# EOF
# done

# 4. Connect the registry to the cluster network if not already connected
# This allows kind to bootstrap the network but ensures they're on the same network
# if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${reg_name}")" = 'null' ]; then
#   docker network connect "kind" "${reg_name}"
# fi

# 5. Document the local registry
# https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: local-registry-hosting
#   namespace: kube-public
# data:
#   localRegistryHosting.v1: |
#     host: "localhost:${reg_port}"
#     help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
# EOF

mkdir ~/.kube && kind --name cmw export kubeconfig >> ~/.kube/config
chmod 600 ~/.kube/config
kubectl config use-context kind-cmw

fi

# 6. Provision a cert-manager on Kubernetes
if helm list -A | grep -q "cert-manager"; then
    echo "A chart with the name 'cert-manager' already exists."
else
    helm repo add jetstack https://charts.jetstack.io --force-update
    helm repo update

    helm upgrade --install \
    cert-manager jetstack/cert-manager \
      --namespace cert-manager \
      --create-namespace \
      --version v1.14.4 \
      --set installCRDs=true \
      --create-namespace
fi

