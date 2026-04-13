# node-red-custom-image

Custom Node-RED Docker image for the k3s cluster at [idefxH/gitops-cluster](https://github.com/idefxH/gitops-cluster).

## How it works

Node-RED runs stateless on the cluster (emptyDir `/data`). State is persisted via Kubernetes ConfigMap/Secret. Custom nodes are baked into this image at build time so they survive pod restarts.

### Adding custom nodes

1. Install nodes via the Node-RED UI — the `state-syncer` sidecar detects `package.json` changes and commits them back to this repo.
2. A GitHub Actions workflow rebuilds the multi-arch image and pushes it to GHCR.
3. Update the image tag in [apps/node-red/values.yaml](https://github.com/idefxH/gitops-cluster/blob/main/apps/node-red/values.yaml) to deploy the new image.

### Manual node install

Edit `package.json` directly, add entries under `dependencies`, and push to `main`.

## Image

```
ghcr.io/idefxh/node-red-custom:latest
```

## Deploy key

The `state-syncer` sidecar pushes to this repo using an SSH deploy key stored in the cluster as:

```
kubectl create secret generic node-red-git-deploy-key \
  --from-file=id_rsa=<path-to-private-key>
```

Create a deploy key with write access in this repo's **Settings → Deploy keys**.
