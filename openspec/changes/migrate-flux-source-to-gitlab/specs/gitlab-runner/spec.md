# Spec Delta

## Purpose

Runs the project's GitLab CI jobs on the owner's own cluster hardware instead of GitLab-hosted shared runners, by deploying a GitLab Runner inside the cluster.

## ADDED Requirements

### Requirement: A GitLab Runner runs inside the cluster
The cluster SHALL deploy the official `gitlab/gitlab-runner` Helm chart, reconciled by Flux, using the Kubernetes executor, so CI jobs execute as pods in the cluster.

#### Scenario: Runner pod is running
- **WHEN** the runner HelmRelease is reconciled
- **THEN** the helm-controller reports the release `Ready`
- **AND** a runner pod is running in the runner's namespace

#### Scenario: Job executes in-cluster
- **WHEN** a CI job matching the runner's tag runs
- **THEN** the job executes on the in-cluster runner rather than a GitLab shared runner

### Requirement: The runner is registered at the group level
The runner SHALL be registered to the `goldencanopy` GitLab group using a runner authentication token, and the token SHALL be stored as a SOPS-encrypted Secret in the repository.

#### Scenario: Group runner available to the project
- **WHEN** the project's pipeline runs
- **THEN** the group-level runner is eligible to pick up its jobs

#### Scenario: Token held as an encrypted Secret
- **WHEN** the repository is inspected
- **THEN** the runner authentication token appears only in SOPS-encrypted form

### Requirement: CI jobs target the self-hosted runner
Pipeline jobs SHALL carry a tag that selects the in-cluster runner, and shared runners SHALL not be relied upon for this project's jobs.

#### Scenario: Tagged job selects the runner
- **WHEN** a job declares the runner's tag
- **THEN** the in-cluster runner is chosen and the job does not wait on a shared runner

#### Scenario: Untagged fallback avoided
- **WHEN** shared runners are disabled for the project
- **THEN** an untagged job cannot silently fall back to GitLab-hosted runners

### Requirement: The runner is scoped and least-privilege
The runner SHALL run in its own namespace with only the permissions its executor needs, so CI jobs cannot act cluster-wide beyond the runner's service account.

#### Scenario: Scoped namespace
- **WHEN** the runner is deployed
- **THEN** its pods and job pods run under a dedicated namespace separate from `flux-system`
