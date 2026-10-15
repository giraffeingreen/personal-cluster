# Proposal

## Why

The GitOps repository is currently hosted on GitHub (`github.com/giraffeingreen/personal-cluster`), and Flux pulls cluster state from it using a GitHub personal access token. The desired home for this repository is GitLab (gitlab.com, SaaS) at `gitlab.com/goldencanopy/personal-cluster`. The repository content and Flux sync path stay the same; only the hosting forge, credentials, and the automated image-update flow that depend on GitHub need to move.

## What Changes

- Point the Flux `GitRepository` source at the GitLab project URL instead of GitHub.
- Replace the GitHub PAT with a GitLab access token (same `flux-system` Secret shape, `username`/`password`), re-encrypted with the existing SOPS + AGE key.
- Change the documented/bootstrap command from `flux bootstrap github` to `flux bootstrap gitlab` (SaaS, token auth).
- **BREAKING** (tooling): replace the GitHub Actions image-update PR workflow (`.github/workflows/flux-image-update-pr.yaml`, uses `gh` + `GITHUB_TOKEN`) with a GitLab CI job that opens a merge request from the `flux-image-updates` branch.
- Keep `ImageUpdateAutomation` pushing the `flux-image-updates` branch, but confirm the GitLab token has write access and adjust the commit author identity if desired.
- Update `redeploy-flux.sh` and `README.md` to GitLab terminology and the new token secret, and delete the GitHub-specific `.github/` directory (Actions workflow plus Copilot instructions).
- Add the GitLab remote and push the branch/history; replay the equivalent branch protection and CI variables on GitLab.
- Run CI on owned infrastructure: deploy the official `gitlab/gitlab-runner` Helm chart (Kubernetes executor) into the cluster as a group-level runner for `goldencanopy`, so CI jobs run on in-cluster hardware instead of GitLab shared runners.

Out of scope: migrating the cluster, re-encrypting unrelated secrets, changing k0s/OpenEBS, and changing container image sources (upstream images such as `ghcr.io/home-assistant/...` are not our repository).

## Capabilities

### New Capabilities
- `gitops-source`: The cluster reconciles its state from the configured Git forge (GitLab) over an authenticated HTTPS source, with credentials stored as an encrypted in-cluster Secret.
- `gitlab-runner`: A GitLab Runner runs in the cluster and executes the project's CI jobs on owned infrastructure, registered at the group level.
- `image-update-automation`: Automated image tag updates are pushed to a dedicated branch and surfaced as a review request (merge request) rather than applied directly to the default branch.

### Modified Capabilities
<!-- None: no existing spec covers this behavior. -->

## Impact

- `clusters/personal-cluster/flux-system/gotk-sync.yaml` — source URL and auth secret ref.
- `clusters/personal-cluster/secrets/gitlab-token.yaml` — new encrypted token file (the existing `github-pat.yaml` is left in place but unreferenced).
- `clusters/personal-cluster/secrets/kustomization.yaml` — resource reference swapped to the new token file.
- `clusters/personal-cluster/image-automation/imageupdateautomation.yaml` — push token capability, commit author.
- `.github/workflows/flux-image-update-pr.yaml` and `.github/copilot-instructions.md` — deleted; replaced by `.gitlab-ci.yml`.
- `clusters/personal-cluster/infra/gitlab-runner/` — new `HelmRepository`/`HelmRelease` for `gitlab/gitlab-runner`, runner config, and the SOPS-encrypted runner auth token.
- `README.md`, `redeploy-flux.sh` — docs and redeploy flow.
- Git remotes/history and GitLab project settings (CI/CD variables, protected `main`).
- Unaffected: SOPS + AGE keys, Discord notification stack (in-cluster), apps, k0s, OpenEBS.
