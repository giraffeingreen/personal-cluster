# AI Agent Instructions for personal-cluster

## Repository Overview
This is a GitOps repository for managing a personal Kubernetes cluster using Flux v2. The repository follows a cluster-centric structure with all manifests organized under `clusters/personal-cluster/`.

## Key Architecture Patterns
- **GitOps-driven**: All cluster state is defined in this repository and reconciled by Flux
- **Single Cluster**: Repository targets one Kubernetes cluster, with room for expansion
- **Flux Bootstrap**: Core Flux components are installed via `flux bootstrap github` command
- **Kustomize-based**: Uses Kustomize for manifest composition and customization
- **Discord Notifications**: Real-time alerts for Flux operations via Discord webhooks
- **SOPS Encryption**: Secrets encrypted with SOPS + AGE before committing to repository

## Critical Files and Directories
- `clusters/personal-cluster/flux-system/` - Core Flux installation manifests
  - `gotk-sync.yaml` - Defines repo sync configuration (1m interval for Git, 10m for Kustomize)
  - `gotk-components.yaml` - Core Flux component definitions
  - `kustomization.yaml` - Combines Flux resources
- `clusters/personal-cluster/notifications/` - Notification providers and alerts
  - `discord-provider.yaml` - Discord notification provider configuration
  - `flux-alerts.yaml` - Alert rules for Flux system and application events
- `clusters/personal-cluster/secrets/` - Encrypted secrets (SOPS encrypted)
  - `discord-webhook.yaml` - Encrypted Discord webhook URL
- `clusters/personal-cluster/apps/` - Application deployments (Plex, Windmill, etc.)
- `.sops/age.pub` - AGE public key for SOPS encryption

## Developer Workflows
1. **Adding New Resources**:
   - Create Kubernetes manifests in appropriate subdirectories
   - Reference them from Flux `Kustomization` objects
   - Changes auto-reconcile, or force with:
     ```bash
     flux reconcile source git flux-system -n flux-system
     flux reconcile kustomization flux-system -n flux-system
     ```

2. **Monitoring Flux**:
   Key commands for checking system health:
   ```bash
   flux check
   flux get sources git
   flux get ks -A
   ```

## Project Conventions
- New applications/resources should be organized in dedicated directories under `clusters/personal-cluster/`
- **Secrets Management**: All secrets MUST be encrypted with SOPS + AGE before committing
- **Notifications**: Discord notifications are configured for Flux system and application events
- Repository branch: `main`
- Flux sync path: `clusters/personal-cluster`

## Secret Management with SOPS
- **Encryption Command**: `sops --age=$(cat .sops/age.pub) --encrypt --encrypted-regex '^(data|stringData)$' --in-place path/to/secret.yaml`
- **Editing Encrypted Secrets**: `sops path/to/encrypted-secret.yaml`
- **AGE Key Location**: Public key stored in `.sops/age.pub`, private key must be available to Flux for decryption

## Common Tasks
- **Bootstrap New Cluster**: Use `flux bootstrap github` with appropriate flags
- **Force Reconciliation**: Use `flux reconcile` commands after pushing changes
- **View Resources**: Standard `kubectl` commands work alongside Flux tools

## Integration Points
- GitHub repository integration via Flux's GitHub source controller
- Kubernetes cluster connectivity via kubeconfig
- **Discord Webhooks**: Notifications sent to Discord channel for Flux events
- **SOPS+AGE Encryption**: Required for all secrets, integrated with Flux secret decryption
- **Notification System**: Monitors GitRepository, Kustomization, and HelmRelease events

## Notification Events
The Discord provider sends alerts for:
- Flux reconciliation success/failure (GitRepository, Kustomization)
- Application deployment status (HelmRelease ready/failed/suspended)
- Health check failures and dependency issues
- Custom patterns can be added via `inclusionList` in alert resources