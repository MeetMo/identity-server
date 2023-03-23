#!/bin/bash

#######################################################################################
# Deploy the Curity Identity Server cluster to Kubernetes, with backed up configuration
#######################################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"




# kubectl delete configmap patch_idsvr 2>/dev/null
# kubectl create configmap patchidsvr --from-file='main-config=./idsvr/patch_idsvr'

# if [ $? -ne 0 ]; then
#   echo "Problem encountered creating the patch_idsvr  for the Identity Server"
#   exit 1
# fi


#
# This is used by Curity developers
#

# Build a custom docker image with some extra resources
#
docker build -f idsvr/Dockerfile . -t nexhe/custom_curity:latest
if [ $? -ne 0 ]; then
  echo "Problem encountered building the Identity Server custom docker image"
  exit 1
fi

#
# Create a Kubernetes secret, referenced in the helm-values.yaml file, for our test SSL certificates
#
kubectl delete secret identity-cluster-ssl 2>/dev/null
kubectl create secret tls identity-cluster-ssl --cert=./certs/certificate.crt --key=./certs/private.key



if [ $? -ne 0 ]; then
  echo "Problem encountered creating the Kubernetes TLS secret for the Curity Identity Server"
  exit 1
fi

#
# Create the config map referenced in the helm-values.yaml file
# This deploys XML configuration to containers at /opt/idsvr/etc/init/configmap-config.xml
# - kubectl get configmap idsvr-configmap -o yaml
#
kubectl delete configmap idsvr-configmap 2>/dev/null
kubectl create configmap idsvr-configmap --from-file='main-config=./idsvr/idsvr-config-backup.xml'

if [ $? -ne 0 ]; then
  echo "Problem encountered creating the config map for the Identity Server"
  exit 1
fi

#
# Run the Curity Identity Server Helm Chart to deploy an admin node and two runtime nodes
#

kubectl apply -f 'idsvr/configmap.yml'
helm repo add curity https://curityio.github.io/idsvr-helm 1>/dev/null
helm repo update 1>/dev/null
helm uninstall curity 2>/dev/null
helm install curity curity/idsvr --values=idsvr/helm-values.yaml

if [ $? -ne 0 ]; then
  echo 'Problem encountered running the Helm Chart for the Curity Identity Server'
  exit 1
fi

# helm upgrade curity curity/idsvr --values=idsvr/helm-values.yaml

#
# Once the pods come up we can call them over these HTTPS URLs externally:
#
# - curl -u 'admin:Password1' 'https://admin.curity.local/admin/api/restconf/data?depth=unbounded&content=config'
# - curl 'https://login.curity.local/oauth/v2/oauth-anonymous/.well-known/openid-configuration'
#
# Inside the cluster we can use these HTTP URLs:
# #
curl -u 'admin:noentry9' 'http://curity-idsvr-admin-svc:6749/admin/api/restconf/data?depth=unbounded&content=config'
# curl -k 'http://curity-idsvr-runtime-svc:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration'
# #
