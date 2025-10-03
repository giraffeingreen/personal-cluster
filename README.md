# personal-cluster

GitOps repository for managing my personal Kubernetes cluster with Flux.

## Overview

This repo is structured for Flux v2. The `clusters/personal-cluster` path contains the top-level Flux configuration ("flux-system") that bootstraps and reconciles the rest of the cluster state.

## Repo layout

- `clusters/personal-cluster/flux-system/` — Flux installation and top-level Kustomizations/Sources for this cluster
- `clusters/personal-cluster/apps/` — Application deployments (Plex, Windmill, etc.)
- `clusters/personal-cluster/notifications/` — Flux notification providers and alerts (Discord integration)
- `clusters/personal-cluster/secrets/` — Encrypted secrets (Discord webhooks, app configs)
- `clusters/personal-cluster/monitoring/` — Monitoring stack (planned)
- `.sops/` — SOPS configuration and AGE encryption keys

You can add more application and infrastructure manifests under your own directories and reference them from Flux `Kustomization` objects.

## Features

- **GitOps with Flux v2**: Automated cluster state management
- **Discord Notifications**: Real-time alerts for Flux operations via Discord webhooks
- **Secret Encryption**: SOPS + AGE encryption for sensitive data like webhook URLs
- **Application Management**: Kustomize-based application deployments

## Prerequisites

- A reachable Kubernetes cluster and valid kubeconfig
- `kubectl` and `flux` CLIs installed
- `sops` CLI installed (for secret encryption)
- `age` CLI installed (for SOPS encryption keys)
- GitHub access to this repository
- Discord server with webhook access (for notifications)

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

## Discord Notifications

This cluster is configured to send Discord notifications for Flux operations. The notifications include:

- Git repository reconciliation status
- Kustomization deployment status  
- HelmRelease deployment status
- Application health status

### Setting up Discord Notifications

1. **Create Discord Webhook**:
   - Go to your Discord server settings
   - Navigate to "Integrations" → "Webhooks" 
   - Click "New Webhook"
   - Choose the channel for notifications
   - Copy the webhook URL

2. **Update the Secret**:
   ```bash
   # Edit the secret with your webhook URL
   sops clusters/personal-cluster/secrets/discord-webhook.yaml
   ```

3. **The notifications are automatically enabled** via the kustomization in `clusters/personal-cluster/notifications/`

## Secret Management with SOPS + AGE

This repository uses SOPS with AGE encryption to securely store sensitive data like Discord webhook URLs.

### Encrypting Secrets

To encrypt a new secret file:

```bash
sops --age=$(cat .sops/age.pub) \
  --encrypt --encrypted-regex '^(data|stringData)$' \
  --in-place path/to/secret.yaml
```

### Editing Encrypted Secrets

To edit an existing encrypted secret:

```bash
sops clusters/personal-cluster/secrets/discord-webhook.yaml
```

### Decrypting Secrets (for debugging)

To view decrypted content:

```bash
sops -d clusters/personal-cluster/secrets/discord-webhook.yaml
```

### AGE Key Management

- Public key: Stored in `.sops/age.pub` 
- Private key: Should be stored securely (not in repo)
- Flux automatically decrypts secrets using the AGE key during deployment

## Notes

- **Secrets are encrypted** using SOPS + AGE before being committed to the repository
- **Discord notifications** are configured to alert on reconciliation status and failures
- For multiple clusters, create additional directories under `clusters/<cluster-name>` and bootstrap each cluster to its corresponding path
- The AGE private key must be available to Flux for secret decryption in the cluster
