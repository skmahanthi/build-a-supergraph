# 05 - Load testing and cleanup

⏱ estimated time: TODO

## What you'll build

![Architecture diagram of the supergraph](diagram.png)

## Part A: Deploy load testing client

- TODO: manifests for load testing client in infra repo

## Part B: Run load test and analyze results

- TODO: instructions for running a load test and seeing results

## Part C: Cleanup

```sh
terraform destroy
# takes 10 minutes

kubectl config delete-context apollo-supergraph-k8s-dev
kubectl config delete-context apollo-supergraph-k8s-prod
```

Terraform does not delete the Docker containers from Github. Visit `https://github.com/<your github username>?tab=packages` and delete the packages created by the previous versions of the repos.

## Congratulations! 🎉

You've completed the tutorial!
