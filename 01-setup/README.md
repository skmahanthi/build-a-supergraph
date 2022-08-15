# 01 - Setup

⏱ estimated time: TODO

## What you'll build

![Architecture diagram of the supergraph](diagram.png)

## Part A: Gather accounts and credentials

### Clone this repo

```
git clone https://github.com/apollosolutions/build-a-supergraph.git
cd build-a-supergraph
```

### Install dependencies

- [GCloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [kubectx](https://github.com/ahmetb/kubectx#installation)
- [Helm](https://helm.sh/docs/intro/install/)

### Gather accounts

- [Github](https://github.com/signup)
- [Apollo Studio](https://studio.apollographql.com/signup?referrer=build-a-supergraph)
- [Google Cloud](https://console.cloud.google.com/freetrial)
  - Must have a project [with billing enabled](https://cloud.google.com/resource-manager/docs/creating-managing-projects#gcloud)

### Gather credentials

- [Github personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
  - [Settings > Developer Settings > Personal Access Tokens](https://github.com/settings/tokens)
  - Grant it permissions to the following scopes:
    - `repo` (for creating repos)
    - `delete-repo` (for cleanup at the end)
- [Apollo Studio graph](https://www.apollographql.com/docs/studio/org/graphs#creating-a-graph)
  - [Apollo Studio key](https://www.apollographql.com/docs/studio/api-keys#graph-api-keys)

```sh
export PROJECT_ID="<your-project-id>"

gcloud components update
gcloud components install gke-gcloud-auth-plugin
gcloud auth application-default login
# expected output:
# > Credentials saved to file: [/Users/you/.config/gcloud/application_default_credentials.json]

gcloud config set project ${PROJECT_ID}
gcloud services enable \
  container.googleapis.com \
  secretmanager.googleapis.com \
  cloudasset.googleapis.com \
  storage.googleapis.com
```

### Setup terraform variables

Copy `terraform.sample_tfvars` to `terraform.tfvars` within the `01-setup` folder and replace the values below appropriately:

```terraform
github_token = ""
github_username = ""
github_email = ""
project_id = ""
project_region = "us-east1"
apollo_key       = ""
apollo_graph_ref = ""
```

## Part B: Provision resources

### Create Kubernetes clusters, basic infrastructure, and Github repositories

**Note: The following commands will create resources on your GCP account, and begin to accrue a cost.** The example infrastructure defaults to a lower-cost environment (small node count and instance size), however it will not be covered by GCP's free tier.

Once you have populated your `terraform.tfvars` file, run the following commands:

```sh
cd 01-setup
terraform init # 2 minutes
terraform plan
terraform apply # will prompt for confirmation
# takes awhile- grab a cup of coffee while it runs
```

The above commands do the following:

- `terraform init`: Installs the required module dependencies for creating the Google Kubernetes Engine (GKE) clusters and networking
- `terraform plan`: Shows the planned infrastructure that's going to be created when running the next command, as well as showing any errors before applying
- `terraform apply`: Applies the planned infrastructure against your GCP account

Once finished, `terraform apply` will output:

- The cluster names in the terminal window you used to run the command
  - By default, these will be `apollo-supergraph-k8s-dev`, `apollo-supergraph-k8s-prod`, and `apollo-supergraph-k8s-tooling-infra`
  - If you change the cluster prefix, you will need to update the cluster script (noted below), however we do not recommend doing so
- A `github-deploy-key.json` file in the `01-setup` folder that includes the credentials for a GCP service account used for the Github workflow
  - Do not commit this to source, as it will allow deploy access to your Kubernetes clusters; this repository automatically excludes this file from tracking

### Run cluster setup script

After creating the necessary clusters, you will need to run the included cluster setup script:

```sh
./setup_clusters.sh
```

This script does a few things for both `dev` and `prod` clusters:

- Configures your local `kubeconfig` with access information, making it easier to apply local Helm charts
- Creates a `router` namespace we'll use to deploy the Apollo Router
- Creates a Kubernetes service account (`secrets-csi-k8s`) used for secrets access
- Installs the [GCP CSI Driver for Kubernetes](https://github.com/GoogleCloudPlatform/secrets-store-csi-driver-provider-gcp)
  - The CSI driver is used by the Apollo Router infrastructure later to access the Apollo API key and graph reference securely, using GCP's Secret Manager
- Configures permissions to allow access to the secrets within Secret Manager

After completing, you should be able to run:

```sh
kubectx apollo-supergraph-k8s-dev
kubectl get pods -A
```

Which returns all running pods (which there should be none).

## Part C: Deploy applications

### Deploy subgraphs

- TODO: add github secrets to subgraph-a and subgraph-b repos for kube cluster access
- TODO: trigger deploy workflows (dev and prod)
- TODO: try them out over nodeports
