# Spec Delta

## Purpose

Defines how automated container image updates detected by Flux are proposed for human review instead of being applied directly to the cluster's default branch.

## ADDED Requirements

### Requirement: Image updates are proposed on a dedicated branch
`ImageUpdateAutomation` SHALL commit detected image tag changes to the `flux-image-updates` branch and SHALL NOT write them directly to `main`.

#### Scenario: Newer image detected
- **WHEN** an `ImagePolicy` selects a newer tag than the one in a deployment manifest
- **THEN** Flux commits the updated manifest to the `flux-image-updates` branch

#### Scenario: Default branch protected
- **WHEN** the update automation runs
- **THEN** the resulting commits exist only on `flux-image-updates` until reviewed

### Requirement: A merge request is opened for image updates
The pipeline SHALL open or update a GitLab merge request proposing `flux-image-updates` into `main`, describing the automated change, using GitLab CI rather than GitHub Actions.

#### Scenario: First update on the branch
- **WHEN** the `flux-image-updates` branch is pushed and no merge request exists
- **THEN** a merge request targeting `main` is created with a description of the automated image updates

#### Scenario: Subsequent update
- **WHEN** the `flux-image-updates` branch is pushed and an open merge request already exists
- **THEN** the existing merge request is updated rather than a duplicate created

#### Scenario: CI credentials
- **WHEN** the pipeline creates or updates the merge request
- **THEN** it authenticates with a GitLab CI/CD token that can write to the repository and manage merge requests
