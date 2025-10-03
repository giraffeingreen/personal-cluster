# Plex Media Server Application
# TODO: Configure Plex deployment
# 
# Common Plex configuration:
# - Image: linuxserver/plex:latest
# - Port: 32400
# - Environment variables: PUID, PGID, TZ
# - Volumes: config, transcode, media
# - Ingress: for web access
#
# Resources to create:
# 1. Namespace (media or plex)
# 2. Deployment with Plex container
# 3. Service (LoadBalancer or NodePort)
# 4. PVC for config and media storage
# 5. Ingress (optional)
# 6. ConfigMap for configuration