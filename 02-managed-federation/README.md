# 02 - Managed federation

⏱ estimated time: 3 minutes

## What you'll build

![Architecture diagram of the supergraph](diagram.png)

## Part A: Publishing subgraphs

Trigger the deploy workflows, this time setting `publish=true` to publish to Studio.

```sh
gh workflow run deploy-gke --repo $GITHUB_ORG/apollo-supergraph-k8s-subgraph-a \
  -f version=main \
  -f cluster=apollo-supergraph-k8s-dev \
  -f publish=true \
  -f variant=dev \
  -f dry-run=false \
  -f debug=false

gh workflow run deploy-gke --repo $GITHUB_ORG/apollo-supergraph-k8s-subgraph-a \
  -f version=main \
  -f cluster=apollo-supergraph-k8s-prod \
  -f publish=true \
  -f variant=prod \
  -f dry-run=false \
  -f debug=false

gh workflow run deploy-gke --repo $GITHUB_ORG/apollo-supergraph-k8s-subgraph-b \
  -f version=main \
  -f cluster=apollo-supergraph-k8s-dev \
  -f publish=true \
  -f variant=dev \
  -f dry-run=false \
  -f debug=false

gh workflow run deploy-gke --repo $GITHUB_ORG/apollo-supergraph-k8s-subgraph-b \
  -f version=main \
  -f cluster=apollo-supergraph-k8s-prod \
  -f publish=true \
  -f variant=prod \
  -f dry-run=false \
  -f debug=false
```

## Part B: Deploy Apollo Router

```
gh workflow run "Deploy Router GKE" --repo $GITHUB_ORG/apollo-supergraph-k8s-infrastructure \
  -f version=v0.16.0 \
  -f cluster=apollo-supergraph-k8s-dev \
  -f variant=dev \
  -f dry-run=false \
  -f debug=false

gh workflow run "Deploy Router GKE" --repo $GITHUB_ORG/apollo-supergraph-k8s-infrastructure \
  -f version=v0.16.0 \
  -f cluster=apollo-supergraph-k8s-prod \
  -f variant=prod \
  -f dry-run=false \
  -f debug=false
```

```sh
kubectl port-forward svc/router -n router 4000:80
open http://localhost:4000
```
