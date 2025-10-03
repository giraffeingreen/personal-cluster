# Notification System

This directory contains the Flux notification configuration for Discord alerts.

## Current Implementation

✅ **Discord Provider** - Configured and ready to send notifications  
✅ **Flux System Alerts** - Monitors GitRepository and Kustomization events  
✅ **Application Alerts** - Monitors HelmRelease and application deployment events  
✅ **Encrypted Secrets** - Discord webhook URL encrypted with SOPS + AGE  

## Files

- `discord-provider.yaml` - Discord notification provider configuration
- `flux-alerts.yaml` - Alert rules for Flux system and application events
- `kustomization.yaml` - Kustomize configuration including all resources

**Note**: The Discord webhook secret (`discord-webhook.yaml`) is stored in the `../secrets/` directory and managed via the secrets kustomization.

## Discord Notifications Include

### Flux System Events
- GitRepository reconciliation success/failure
- Kustomization reconciliation success/failure  
- Health check failures
- Dependency issues

### Application Events  
- HelmRelease deployment status (ready/failed/suspended)
- Application deployment status
- Kustomization status for applications

## Adding Additional Providers

Flux supports multiple notification providers that can be added:

- **Slack** (webhooks)
- **Microsoft Teams** 
- **Email** (SMTP)
- **Generic Webhooks**

To add additional providers:

1. Create provider configuration (e.g., `slack-provider.yaml`)
2. Create encrypted secrets for credentials
3. Create alert resources referencing the new provider
4. Update `kustomization.yaml` to include new resources

## Customizing Alerts

Edit `flux-alerts.yaml` to:
- Add/remove event sources
- Modify inclusion/exclusion patterns
- Change event severity filters
- Customize notification summaries

Example patterns:
```yaml
inclusionList:
  - ".*reconciliation succeeded.*"
  - ".*reconciliation failed.*" 
  - ".*health check failed.*"
  - ".*dependency.*"
```