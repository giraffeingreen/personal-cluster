# Sonarr

Sonarr deployment for the personal cluster, based on the LinuxServer.io Docker image.

## Configuration

This deployment includes:
- **Namespace**: `plex` (shared namespace for all media applications)
- **Image**: `lscr.io/linuxserver/sonarr:latest`
- **Port**: 8989
- **Node Selector**: Deployed to node with hostname `media`
- **Environment Variables**:
  - PUID: 1000
  - PGID: 1000
  - TZ: Etc/UTC

## Storage

- **Config PVC**: `sonarr-config` - 5Gi for Sonarr configuration
- **Media PVC**: `media-shared` - 500Gi shared storage for all media applications

## Access

The service is exposed as ClusterIP on port 8989. You may want to add an Ingress or change to NodePort/LoadBalancer depending on your cluster setup.

## Deployment

To enable this app, uncomment the sonarr line in the parent `kustomization.yaml`:

```yaml
resources:
  - ./sonarr
```

Then apply with Flux or manually with:
```bash
kubectl apply -k .
```
