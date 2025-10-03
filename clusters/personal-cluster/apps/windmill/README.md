# Windmill - Open-source developer platform
# TODO: Configure Windmill deployment
#
# Windmill consists of:
# - Windmill Server (API + Frontend)
# - Windmill Worker (Job execution)
# - PostgreSQL Database
# - Redis (optional, for caching)
#
# Common Windmill configuration:
# - Server Image: windmill/windmill:main
# - Worker Image: windmill/windmill:main
# - Database: PostgreSQL 14+
# - Ports: 8000 (server), 8001 (metrics)
#
# Resources to create:
# 1. Namespace (windmill)
# 2. PostgreSQL deployment + service + PVC
# 3. Windmill server deployment + service
# 4. Windmill worker deployment
# 5. Ingress for web access
# 6. ConfigMap for configuration
# 7. Secrets for database credentials