#!/bin/bash

# Exit immediately if any command fails
set -e

# Define absolute paths based on your environment
REPO_ROOT="$HOME/workspace/personal-cluster"
FLUX_SYSTEM_DIR="$REPO_ROOT/clusters/personal-cluster/flux-system"
SECRETS_DIR="$REPO_ROOT/clusters/personal-cluster/secrets"
SOPS_KEY="$REPO_ROOT/.sops/age.key"

echo "🔄 Starting automated FluxCD redeployment pipeline..."

# -------------------------------------------------------------------------
# Step 1: Apply Base Flux Components
# -------------------------------------------------------------------------
echo "📦 Step 1/4: Applying core FluxCD manifests to the cluster..."
kubectl apply -f "$FLUX_SYSTEM_DIR/gotk-components.yaml"
kubectl apply -f "$FLUX_SYSTEM_DIR/gotk-sync.yaml"

# -------------------------------------------------------------------------
# Step 2: Prime the GitHub Token via Local SOPS Decryption
# -------------------------------------------------------------------------
echo "🔑 Step 2/4: Decrypting GitHub PAT using local age key..."
export SOPS_AGE_KEY_FILE="$SOPS_KEY"

if [ -f "$SECRETS_DIR/github-pat.yaml" ]; then
    sops -d "$SECRETS_DIR/github-pat.yaml" | kubectl apply -f -
else
    echo "❌ Error: github-pat.yaml not found at $SECRETS_DIR/github-pat.yaml"
    exit 1
fi

# -------------------------------------------------------------------------
# Step 3: Inject the SOPS Decryption Key into the Cluster
# -------------------------------------------------------------------------
echo "🛡️ Step 3/4: Creating the 'sops-age' secret inside the cluster..."
# Remove any stale/half-configured secret if it exists
kubectl delete secret generic sops-age --namespace=flux-system --ignore-not-found

if [ -f "$SOPS_KEY" ]; then
    kubectl create secret generic sops-age \
      --namespace=flux-system \
      --from-file=age.agekey="$SOPS_KEY"
else
    echo "❌ Error: age.key not found at $SOPS_KEY"
    exit 1
fi

# -------------------------------------------------------------------------
# Step 4: Force Reconciliation & Synchronization
# -------------------------------------------------------------------------
echo "🚀 Step 4/4: Kicking off immediate reconciliation loop..."
flux reconcile source git flux-system
flux reconcile kustomization flux-system

echo "========================================================================="
echo "✅ Success! FluxCD has been completely reapplied and primed."
echo "💡 Run 'flux get kustomizations --watch' to track your application states."
echo "========================================================================="
