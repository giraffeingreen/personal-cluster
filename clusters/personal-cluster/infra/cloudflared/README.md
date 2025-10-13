# Cloudflared Tunnel

This directory contains the Kubernetes manifests for deploying Cloudflare Tunnel (cloudflared) to the cluster.

## Overview

Cloudflared creates a secure tunnel between your Kubernetes cluster and Cloudflare's network, allowing you to expose services without opening inbound ports or configuring firewalls.

## Components

- **Namespace**: `flux-system` - Uses the existing Flux namespace
- **Secret**: Encrypted tunnel token stored in `clusters/personal-cluster/secrets/cloudflared-token.yaml`
- **Deployment**: Single replica deployment running the cloudflared container

## Configuration

The deployment runs the following command:
```bash
cloudflared tunnel --no-autoupdate run --token <token>
```

### Secret Management

The tunnel token is stored in an encrypted secret using SOPS in the `secrets/` directory:

**To update the tunnel token:**
```bash
sops clusters/personal-cluster/secrets/cloudflared-token.yaml
```

Replace the value of `token` with your Cloudflare tunnel token, then save. SOPS will automatically re-encrypt the file.

**To get a tunnel token:**
1. Log in to the Cloudflare dashboard
2. Navigate to Zero Trust > Networks > Tunnels
3. Create a new tunnel or use an existing one
4. Copy the tunnel token

## Resources

The deployment includes resource requests and limits:
- Requests: 64Mi memory, 100m CPU
- Limits: 128Mi memory, 200m CPU

## Docker Command Equivalent

This Kubernetes deployment is equivalent to:
```bash
docker run cloudflare/cloudflared:latest tunnel --no-autoupdate run --token <token>
```
