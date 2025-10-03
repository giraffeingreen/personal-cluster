# Monitoring Stack
# TODO: Configure monitoring components
#
# Common monitoring stack includes:
# - Prometheus (metrics collection)
# - Grafana (visualization)
# - AlertManager (alerting)
# - Node Exporter (node metrics)
# - kube-state-metrics (Kubernetes metrics)
#
# Resources to create:
# 1. Namespace (monitoring)
# 2. Prometheus deployment + config + service
# 3. Grafana deployment + service + ingress
# 4. AlertManager deployment + config
# 5. ServiceMonitor resources
# 6. PrometheusRule resources
# 7. PVCs for data persistence