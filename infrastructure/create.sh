#!/bin/bash
CURRENT_DIR=$PWD
echo "----- Checking requirements"
urls_jq="https://stedolan.github.io/jq/"
urls_kpm="https://github.com/coreos/kpm"
urls_gcloud="https://cloud.google.com/sdk/downloads"
urls_docker="https://www.docker.com"
for tool in gcloud jq kpm docker; do
  if hash $tool 2>/dev/null; then
      echo "$tool: OK"
  else
      url="urls_$tool"
      echo "$tool: Failed: Please install $tool (${!url})"
      exit 1
  fi
done

if gcloud deployment-manager deployments describe wescale-cluster &>/dev/null; then
  echo "----- wescale Cluster already deployed"
else
  echo "----- Deploying wescale Cluster"
  gcloud deployment-manager deployments create wescale-cluster --config wescale-cluster.yaml
fi

echo "----- Upgrading wescale Cluster"
#yes | gcloud container clusters upgrade wescale-cluster --zone=europe-west1-c --cluster-version=1.5.2 --master
#yes | gcloud container clusters upgrade wescale-cluster --zone=europe-west1-c --cluster-version=1.5.2 --image-type=CONTAINER_VM --node-pool=pool-high-mem
#yes | gcloud container clusters upgrade wescale-cluster --zone=europe-west1-c --cluster-version=1.5.2 --image-type=CONTAINER_VM --node-pool=pool-default

gcloud container clusters get-credentials wescale-cluster --zone europe-west1-c

echo "----- Launching Local KPM Registry"
docker rm -f kpm-registry
docker run -ti -d -p 5000:5000 --name=kpm-registry -e STORAGE=filesystem quay.io/kubespray/kpm:v0.24.2 gunicorn kpm.api.wsgi:app -b :5000 --threads 1 -w 4 --timeout 240
sleep 30
cd $CURRENT_DIR/../kpm-registry; kpm push -H http://localhost:5000
cd $CURRENT_DIR/../etcdv3; kpm push -H http://localhost:5000
cd $CURRENT_DIR
echo "----- Deploying KPM Registry"
kpm deploy coreos/kpm-registry --namespace kpm -H http://localhost:5000
docker rm -f kpm-registry
echo "----- Fetching a node IP"
NODE_IP=$(kubectl get nodes -o json  | jq -r '.items[].status.addresses[] | select(.type=="ExternalIP") | .address' | head -n 1)
echo "----- Fetching the kpm registry nodeport"
KPM_REGISTRY_PORT=$(kubectl --namespace=kpm -o json get service kpm-registry  | jq '.spec.ports[].nodePort')
echo "----- Sleeping for a minute"
sleep 60

echo "----- Pushing artifacts to kpm (http://$NODE_IP:$KPM_REGISTRY_PORT)"
echo "----- Pushing ceph..."
cd $CURRENT_DIR/../ceph; kpm push -f -H http://$NODE_IP:$KPM_REGISTRY_PORT
echo "----- Pushing elasticsearch..."
cd $CURRENT_DIR/../elasticsearch; kpm push -f -H http://$NODE_IP:$KPM_REGISTRY_PORT
echo "----- Pushing concourse..."
cd $CURRENT_DIR/../concourse; kpm push -f -H http://$NODE_IP:$KPM_REGISTRY_PORT
echo "----- Pushing postgres..."
cd $CURRENT_DIR/../postgres; kpm push -f -H http://$NODE_IP:$KPM_REGISTRY_PORT
cd $CURRENT_DIR

echo "----- Deploying artifacts to cluster"
echo "----- Deploying ceph..."
kpm deploy wescale/ceph --namespace=ceph -H http://$NODE_IP:$KPM_REGISTRY_PORT
echo "----- Deploying concourse..."
kpm deploy wescale/concourse --namespace=concourse -H http://$NODE_IP:$KPM_REGISTRY_PORT
echo "----- Deploying elasticsearch in demo namespace..."
kpm deploy wescale/elasticsearch --namespace=demo -H http://$NODE_IP:$KPM_REGISTRY_PORT

sleep 60
echo "----- Detecting TSA Host"
TSA_HOST=$(kubectl --namespace=concourse -o json get service concourse-worker | jq -r '.status.loadBalancer.ingress[].ip')

if gcloud deployment-manager deployments describe wescale-concourse-workers &>/dev/null; then
  echo "----- wescale Concourse Workers already deployed"
else
  echo "----- Deploying wescale Concourse Workers"
  gcloud deployment-manager deployments create wescale-concourse-workers --properties=tsa:$TSA_HOST,zone:europe-west1-c,count:3,machineType:n1-standard-2,hasExternalIp:true --config $CURRENT_DIR/../concourse/workers/wescale-concourse-worker.jinja
fi
