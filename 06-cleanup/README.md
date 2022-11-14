## 06 - Cleanup

⏱ Estimated time: 15 minutes

Running Google Cloud resources will continue to incur costs on your account so we have documented all the steps to take for a proper tear-down.

### Automated cleanup

In order to delete some non-Kubernetes resources created by Google Cloud, it's easiest to just delete everything:

```sh
kubectx apollo-supergraph-k8s-dev
kubectl delete daemonsets,replicasets,services,deployments,pods,rc,ingress --all --all-namespaces
```

The command may hang at the end. You can kill the process (`ctrl-c`) and repeat with the prod cluster:

```
kubectx apollo-supergraph-k8s-prod
kubectl delete daemonsets,replicasets,services,deployments,pods,rc,ingress --all --all-namespaces
```

Then you can destroy all the provisioned resources (Kubernetes clusters, GitHub repositories) with terraform:

```sh
cd 01-setup
terraform destroy # takes 10 minutes
```

Lastly, you can remove the contexts from your `kubectl`:

```sh
kubectl config delete-context apollo-supergraph-k8s-dev
kubectl config delete-context apollo-supergraph-k8s-prod
```

Terraform does not delete the Docker containers from GitHub. Visit `https://github.com/<your github username>?tab=packages` and delete the packages created by the previous versions of the repos.

## Congratulations! 🎉

You've completed the tutorial!
