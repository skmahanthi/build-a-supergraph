# 02 - Managed federation

⏱ Estimated time: 5 minutes

## What you'll build

![Architecture diagram of the supergraph](diagram.png)

## Part A: Publish subgraph schemas to Apollo Studio

In both **subgraph-a** and **subgrap-b** repositories:

- Edit `.github/workflows/Merge to Main.yml`
- Add a new job to the bottom of the file:
  ```yaml
  publish:
    needs: [deploy]
    uses: ./.github/workflows/_rover-subgraph-publish.yml
    secrets: inherit
    with:
      subgraph_name: subgraph-a # change this to subgraph-b in that repo
      variant: dev
  ```
- After merging the code to the `main` branch, the `Merge to Main` action will build the docker container, deploy the subgraph application, and finally publish the subgraph schema to Apollo Studio.
- Visit your graph in Apollo Studio to see that the subgraph schemas published successfully and it built a new supergraph schema for the `dev` variant.
- Add a new job to `.github/workflows/Manual Deploy.yml`:
  ```yaml
  publish:
    needs: [deploy]
    uses: ./.github/workflows/_rover-subgraph-publish.yml
    secrets: inherit
    with:
      subgraph_name: subgraph-a # change this to subgraph-b in that repo
      variant: ${{ inputs.environment }}
  ```
- After merging this change to main, trigger the `Manual Deploy` action to deploy and publish to production:

  ```sh
    gh workflow run "Manual Deploy" --repo $GITHUB_ORG/apollo-supergraph-k8s-subgraph-a \
      -f version=main \
      -f environment=prod \
      -f dry-run=false \
      -f debug=false

    gh workflow run "Manual Deploy" --repo $GITHUB_ORG/apollo-supergraph-k8s-subgraph-b \
      -f version=main \
      -f environment=prod \
      -f dry-run=false \
      -f debug=false
  ```

- Visit your graph in Apollo Studio to see that the subgraph schemas published successfully and it built a new supergraph schema for the `prod` variant.

## Part B: Deploy Apollo Router

Now that the supergraph schema is available via Apollo Uplink, you can deploy the router:

```
gh workflow run "Deploy Router GKE" --repo $GITHUB_ORG/apollo-supergraph-k8s-infra \
  -f environment=dev \
  -f dry-run=false \
  -f debug=false

gh workflow run "Deploy Router GKE" --repo $GITHUB_ORG/apollo-supergraph-k8s-infra \
  -f environment=prod \
  -f dry-run=false \
  -f debug=false
```

The router has an IP address, so you can try it out with these commands:

```sh
ROUTER_IP=$(kubectl get ingress -n router -o jsonpath="{.*.*.status.loadBalancer.ingress.*.ip}")
open http://$ROUTER_IP
```

(The ingress might take a little while to create, so if it doesn't work just wait a few minutes.)

## Onward!

[Step 3: Schema Checks](../03-schema-checks/)
