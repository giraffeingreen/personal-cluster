# personal-cluster

GitOps repository for managing my personal Kubernetes cluster with Flux.

## Overview

This repo is structured for Flux v2. The `clusters/personal-cluster` path contains the top-level Flux configuration ("flux-system") that bootstraps and reconciles the rest of the cluster state.

## Repo layout

- `clusters/personal-cluster/flux-system/` — Flux installation and top-level Kustomizations/Sources for this cluster.

You can add more application and infrastructure manifests under your own directories and reference them from Flux `Kustomization` objects.

## Prerequisites

- A reachable Kubernetes cluster and valid kubeconfig
- `kubectl` and `flux` CLIs installed
- GitHub access to this repository

## Bootstrap (one-time)

If you need to (re)bootstrap Flux on a fresh cluster using this repository:

```bash
flux bootstrap github \
  --owner giraffeingreen \
  --repository personal-cluster \
  --branch main \
  --path clusters/personal-cluster \
  --personal
```

This installs Flux controllers and points them at this repo/path. Adjust flags as needed.

## Day-2 operations

- Check Flux status:

```bash
flux check
flux get sources git
flux get ks -A
```

- Force a reconciliation (useful after pushing changes):

```bash
flux reconcile source git flux-system -n flux-system
flux reconcile kustomization flux-system -n flux-system
```

## Making changes

1. Commit and push your Kubernetes manifests and/or Flux objects to this repository.
2. Ensure they are referenced by a Flux `Kustomization` reachable from `clusters/personal-cluster/flux-system`.
3. Flux will reconcile automatically, or you can trigger a reconcile as shown above.

## Notes

- Keep secrets out of the repo or manage them with a tool like SOPS + Age and Flux `Secret` decryption.
- For multiple clusters, create additional directories under `clusters/<cluster-name>` and bootstrap each cluster to its corresponding path.
