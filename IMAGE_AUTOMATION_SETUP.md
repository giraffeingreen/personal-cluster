# FluxCD Image Automation Setup Verification

## ✅ Components Created

### 1. ImageRepository Resources (5)
- ✅ `imagerepository-plex.yaml` - Tracks lscr.io/linuxserver/plex
- ✅ `imagerepository-sonarr.yaml` - Tracks lscr.io/linuxserver/sonarr
- ✅ `imagerepository-radarr.yaml` - Tracks lscr.io/linuxserver/radarr
- ✅ `imagerepository-qbittorrent.yaml` - Tracks lscr.io/linuxserver/qbittorrent
- ✅ `imagerepository-cloudflared.yaml` - Tracks cloudflare/cloudflared

### 2. ImagePolicy Resources (5)
- ✅ `imagepolicy-plex.yaml` - Policy: alphabetical (latest)
- ✅ `imagepolicy-sonarr.yaml` - Policy: alphabetical (latest)
- ✅ `imagepolicy-radarr.yaml` - Policy: alphabetical (latest)
- ✅ `imagepolicy-qbittorrent.yaml` - Policy: alphabetical (latest)
- ✅ `imagepolicy-cloudflared.yaml` - Policy: alphabetical (latest)

### 3. ImageUpdateAutomation
- ✅ `imageupdateautomation.yaml` - Configured to:
  - Source: flux-system GitRepository
  - Path: ./clusters/personal-cluster
  - Strategy: Setters
  - Interval: 5m
  - Auto-commit and push to main branch

### 4. Deployment Annotations
- ✅ `apps/plex/deployment.yaml` - Annotated with flux-system:plex-latest
- ✅ `apps/sonarr/deployment.yaml` - Annotated with flux-system:sonarr-latest
- ✅ `apps/radarr/deployment.yaml` - Annotated with flux-system:radarr-latest
- ✅ `apps/qbittorrent/deployment.yaml` - Annotated with flux-system:qbittorrent-latest
- ✅ `infra/cloudflared/deployment.yaml` - Annotated with flux-system:cloudflared-latest

### 5. Kustomization Files
- ✅ `image-automation/kustomization.yaml` - Lists all image automation resources
- ✅ `clusters/personal-cluster/kustomization.yaml` - Updated to include ./image-automation

## 🔍 How It Works

1. **ImageRepository** resources scan the container registries every 5 minutes for new tags
2. **ImagePolicy** resources select the "latest" tag using alphabetical ordering
3. **ImageUpdateAutomation** checks for policy changes every 5 minutes and:
   - Updates the image tags in deployment files based on the annotations
   - Commits the changes to Git with message "Update images to latest"
   - Pushes the changes back to the main branch
4. **Flux** detects the Git changes and reconciles the deployments with the new images

## 📋 Prerequisites

Before this will work, ensure:
- [ ] Flux image-reflector-controller is installed
- [ ] Flux image-automation-controller is installed
- [ ] GitRepository has write access (SSH key or token configured)
- [ ] All resources are applied to the cluster

## 🚀 Next Steps

1. Commit and push these changes to your Git repository
2. Flux will automatically apply the image automation resources
3. Check the status:
   ```bash
   kubectl get imagerepositories -n flux-system
   kubectl get imagepolicies -n flux-system
   kubectl get imageupdateautomation -n flux-system
   ```
4. Monitor for automatic updates:
   ```bash
   kubectl logs -n flux-system -l app=image-automation-controller -f
   kubectl logs -n flux-system -l app=image-reflector-controller -f
   ```

## 🔧 Troubleshooting

If images aren't updating automatically:
1. Check ImageRepository status: `kubectl describe imagerepository -n flux-system <name>`
2. Check ImagePolicy status: `kubectl describe imagepolicy -n flux-system <name>`
3. Check ImageUpdateAutomation status: `kubectl describe imageupdateautomation -n flux-system image-automation`
4. Verify Git write permissions
5. Check controller logs for errors
