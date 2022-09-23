#/bin/bash
set -euxo pipefail

# default vars
CLUSTER_PREFIX=${CLUSTER_PREFIX:-"apollo-supergraph-k8s"}
PROJECT_REGION=${PROJECT_REGION:-"us-east1"}
PROJECT_CLUSTERS=("${CLUSTER_PREFIX}-dev" "${CLUSTER_PREFIX}-prod")
# end default vars

if [[ $(which gcloud) == "" ]]; then
  echo "gcloud not installed"
  exit 1
fi

if [[ $(which kubectl) == "" ]]; then
  echo "kubectl not installed"
  exit 1
fi

if [[ $(which kubectx) == "" ]]; then
  echo "kubectx not installed"
  exit 1
fi

if [[ -z "$PROJECT_ID" ]]; then
  echo "Must provide PROJECT_ID in environment" 1>&2
  exit 1
fi

environment_setup(){
    echo "Configuring Kubeconfig for ${1}..."
    gcloud container clusters get-credentials ${1} --zone ${PROJECT_REGION} --project ${PROJECT_ID}

    # short context aliases: supports `kubectx apollo-supergraph-k8s-dev`
    kubectx ${1}=.

    # secrets setup: namespace, service account, and binding
    # the service account name matches the router's service account in its helm chart
    kubectl create namespace router --dry-run=client -o yaml | kubectl apply -f -
    kubectl create serviceaccount -n "router" "secrets-csi-k8s" --dry-run=client -o yaml | kubectl apply -f -
    kubectl annotate serviceaccount -n "router" "secrets-csi-k8s" "iam.gke.io/gcp-service-account=${CLUSTER_PREFIX:0:12}-secrets-csi-k8s@$PROJECT_ID.iam.gserviceaccount.com" --overwrite
    gcloud iam service-accounts add-iam-policy-binding \
        --role roles/iam.workloadIdentityUser \
        --member "serviceAccount:${PROJECT_ID}.svc.id.goog[router/secrets-csi-k8s]" \
        "${CLUSTER_PREFIX:0:12}-secrets-csi-k8s@$PROJECT_ID.iam.gserviceaccount.com"

    # apollo key for Router
    gcloud secrets add-iam-policy-binding "${CLUSTER_PREFIX:0:12}-apollo-key" \
        --member="serviceAccount:${CLUSTER_PREFIX:0:12}-secrets-csi-k8s@$PROJECT_ID.iam.gserviceaccount.com" \
        --role='roles/secretmanager.secretAccessor'

    # monitoring setup: namespace, service account, and binding
    # the service account name matches the otel collector's service account in its helm chart
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    kubectl create serviceaccount -n "monitoring" "metrics-writer" --dry-run=client -o yaml | kubectl apply -f -
    kubectl annotate serviceaccount -n "monitoring" "metrics-writer" "iam.gke.io/gcp-service-account=${CLUSTER_PREFIX:0:12}-metrics-writer@$PROJECT_ID.iam.gserviceaccount.com" --overwrite
    gcloud iam service-accounts add-iam-policy-binding \
        --role roles/iam.workloadIdentityUser \
        --member "serviceAccount:${PROJECT_ID}.svc.id.goog[monitoring/metrics-writer]" \
        "${CLUSTER_PREFIX:0:12}-metrics-writer@$PROJECT_ID.iam.gserviceaccount.com"

    csi_setup $1
}

csi_setup(){
    echo "Installing CSI Driver on ${1}..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/main/deploy/rbac-secretproviderclass.yaml
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/main/deploy/csidriver.yaml
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/main/deploy/secrets-store.csi.x-k8s.io_secretproviderclasses.yaml
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/main/deploy/secrets-store.csi.x-k8s.io_secretproviderclasspodstatuses.yaml
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/main/deploy/secrets-store-csi-driver.yaml
    kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/main/deploy/rbac-secretprovidersyncing.yaml
    kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/secrets-store-csi-driver-provider-gcp/main/deploy/provider-gcp-plugin.yaml
}

for c in "${PROJECT_CLUSTERS[@]}"; do
    environment_setup $c
done
