# AI Agent Instructions for personal-cluster

## Repository Overview
This is a GitOps repository for managing a personal Kubernetes cluster using Flux v2. The repository follows a cluster-centric structure with all manifests organized under `clusters/personal-cluster/`.

## Key Architecture Patterns
- **GitOps-driven**: All cluster state is defined in this repository and reconciled by Flux
- **Single Cluster**: Repository targets one Kubernetes cluster, with room for expansion
- **Flux Bootstrap**: Core Flux components are installed via `flux bootstrap github` command
- **Kustomize-based**: Uses Kustomize for manifest composition and customization

## Critical Files and Directories
- `clusters/personal-cluster/flux-system/` - Core Flux installation manifests
  - `gotk-sync.yaml` - Defines repo sync configuration (1m interval for Git, 10m for Kustomize)
  - `gotk-components.yaml` - Core Flux component definitions
  - `kustomization.yaml` - Combines Flux resources

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
- Secrets must be managed outside the repository or encrypted using SOPS + Age
- Repository branch: `main`
- Flux sync path: `clusters/personal-cluster`

## Common Tasks
- **Bootstrap New Cluster**: Use `flux bootstrap github` with appropriate flags
- **Force Reconciliation**: Use `flux reconcile` commands after pushing changes
- **View Resources**: Standard `kubectl` commands work alongside Flux tools

## Integration Points
- GitHub repository integration via Flux's GitHub source controller
- Kubernetes cluster connectivity via kubeconfig
- Optional SOPS+Age integration for secret management