# 05 - Load testing and cleanup

⏱ Estimated time: 15 minutes

## What you'll build

![Architecture diagram of the supergraph](diagram.png)

## Part A: Deploy load testing client

Run the "Deploy Load Test" workflow to provisions the necessary resources your `prod` cluster:

```sh
gh workflow run "Deploy Load Test" --repo $GITHUB_ORG/apollo-supergraph-k8s-infra
```

Grafana generates a unique password each time it's deployed. To fetch the password:

```sh
kubectx apollo-supergraph-k8s-prod
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

Visit the Grafana UI at [http://localhost:3000/](http://localhost:3000/) using `port-forward`. Login with the username "admin" and the password from the command above.

```sh
kubectl port-forward svc/grafana -n monitoring 3000:80
```

## Part B: Run load test and analyze results

Run a load test by triggering a Github workflow:

```sh
gh workflow run "Run Load Test" --repo $GITHUB_ORG/apollo-supergraph-k8s-infra \
  -f test=short \
  -f parallelism=1
```

[You can find the existing tests in the infra template repo.](https://github.com/apollosolutions/build-a-supergraph-infra/tree/main/deploy/tests/src)

<details>
  <summary>Submitting your own test</summary>

1. Read the K6 blog post on [writing load tests for GraphQL](https://k6.io/blog/load-testing-graphql-with-k6/).
2. Write a JavaScript test file (example: `test.js`).
3. Create a configmap for the test file:
   ```sh
   kubectx apollo-supergraph-k8s-prod
   kubectl create configmap my-test --from-file test.js
   ```
4. Trigger the load test by creating a `K6` resource:
   ```sh
   cat <<EOF | kubectl apply -f -
   apiVersion: k6.io/v1alpha1
   kind: K6
   metadata:
     name: my-test
   spec:
     parallelism: 1
     arguments: "--out influxdb=http://influxdb.monitoring:8086/db"
     script:
       configMap:
         name: my-test
         file: test.js
   EOF
   ```

</details>

<details>
  <summary>Debugging load tests</summary>

Read the blog post for running [distributed tests in Kubernetes](https://k6.io/blog/running-distributed-tests-on-k8s/).

</details>

<details>
  <summary>Cleaning up load test resources</summary>

To clean up jobs and pods, delete the original `K6` resource.

```sh
kubectl get k6

# See list of test run names

kubectl delete k6/run-short-1234
```

</details>

## Part C: Cleanup

```sh
cd 01-setup
terraform destroy # takes 10 minutes
```

You may need to manually delete [Network Endpoint Groups](https://console.cloud.google.com/compute/networkendpointgroups/list) for `terraform destroy` to succeed. You can safely run `terraform destroy` again after deleting resources.

```sh
kubectl config delete-context apollo-supergraph-k8s-dev
kubectl config delete-context apollo-supergraph-k8s-prod
```

Terraform does not delete the Docker containers from Github. Visit `https://github.com/<your github username>?tab=packages` and delete the packages created by the previous versions of the repos.

## Congratulations! 🎉

You've completed the tutorial!
