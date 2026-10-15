# Spec Delta

## Purpose

Defines how the cluster's Flux installation locates and authenticates against the Git repository that holds the cluster's desired state, so state changes are pulled and reconciled from the configured forge.

## ADDED Requirements

### Requirement: Flux reconciles from the configured Git forge
The Flux `GitRepository` source SHALL point at the repository's GitLab (gitlab.com) HTTPS URL on the `main` branch, and reconcile the cluster state from the `clusters/personal-cluster` path.

#### Scenario: Source resolves to GitLab
- **WHEN** the `flux-system` GitRepository is reconciled
- **THEN** it clones `https://gitlab.com/goldencanopy/personal-cluster.git` at branch `main`
- **AND** the top-level Kustomization reconciles from `./clusters/personal-cluster`

#### Scenario: No residual forge reference
- **WHEN** the repository manifests are inspected
- **THEN** no `github.com` URL remains as a Flux source

### Requirement: Source credentials are stored as an encrypted Secret
Access credentials for the Git forge SHALL be stored in the `flux-system` Secret as `username` and `password` keys, referenced by the GitRepository, and committed only in SOPS-encrypted form.

#### Scenario: Authenticated pull
- **WHEN** the source repository is private
- **THEN** Flux authenticates using the token in the `flux-system` Secret

#### Scenario: Credentials rotated
- **WHEN** the GitLab token is replaced
- **THEN** the Secret is re-encrypted with the existing AGE key before commit
- **AND** the new token is applied to the cluster

### Requirement: Bootstrap provisions GitLab token auth
Documentation and scripts SHALL describe bootstrapping the cluster against GitLab SaaS using token authentication rather than GitHub authentication.

#### Scenario: Re-bootstrap on a fresh cluster
- **WHEN** an operator bootstraps Flux from scratch using the documented command
- **THEN** the command uses `flux bootstrap gitlab` against `gitlab.com/goldencanopy/personal-cluster`
- **AND** it configures the GitRepository to use the token Secret
