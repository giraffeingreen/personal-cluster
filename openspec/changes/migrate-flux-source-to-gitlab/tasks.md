# Tasks

## 1. GitLab project and credentials

- [ ] 1.1 Create the private GitLab project `goldencanopy/personal-cluster` on gitlab.com and verify it loads at `https://gitlab.com/goldencanopy/personal-cluster`
- [ ] 1.2 Create a Personal Access Token (scopes `api` + `write_repository`; project-scoped tokens need Premium) and verify `git ls-remote https://oauth2:<token>@gitlab.com/goldencanopy/personal-cluster.git` succeeds
- [ ] 1.3 Add the merge-request token as a **masked** CI/CD variable (e.g. `GITLAB_MR_TOKEN`) — not protected, because the `flux-image-updates` branch is unprotected and protected variables would not reach its jobs; verify it appears masked in the project's CI/CD variables list
- [ ] 1.4 Protect `main` and require merge requests on the GitLab project and verify the protected-branch setting is active

## 2. Self-hosted GitLab Runner

- [ ] 2.1 Create a group-level runner for `goldencanopy`, capture its `glrt-...` authentication token, tag it `self-hosted`, and disable shared runners; verify the runner appears under the group's CI/CD runners (offline until deployed)
- [ ] 2.2 Add `clusters/personal-cluster/infra/gitlab-runner/` with a `HelmRepository` for `https://charts.gitlab.io` and a `HelmRelease` for `gitlab/gitlab-runner` that tracks the latest chart (Kubernetes executor, namespace `gitlab-runner`); verify `kustomize build` renders and the HelmRelease reaches `Ready`
- [ ] 2.3 Store the runner authentication token as a SOPS-encrypted Secret and wire it into the HelmRelease values; verify the token appears only encrypted in the repo and the runner reports **online** in GitLab
- [ ] 2.4 Verify a tagged job executes in-cluster by confirming a job pod appears in the `gitlab-runner` namespace during a pipeline run

## 3. Repository remote and history

- [ ] 3.1 Add the GitLab remote and push all history: `git remote add gitlab https://gitlab.com/goldencanopy/personal-cluster.git && git push gitlab --all --tags`, then verify the GitLab project shows `main` and the branch list
- [ ] 3.2 Repoint `origin` to GitLab and verify `git remote -v` shows only GitLab for fetch and push
- [ ] 3.3 Verify a fresh clone of the GitLab repo matches the pushed history (`git log --oneline -1` on both)

## 4. Flux source and token Secret

- [ ] 4.1 Add `clusters/personal-cluster/secrets/gitlab-token.yaml` defining Secret `flux-system` (namespace `flux-system`) with the GitLab token, encrypt with `sops`, and verify `sops -d` shows the token and `sops -d ... | kubectl apply --dry-run=client -f -` succeeds
- [ ] 4.2 Swap `secrets/kustomization.yaml` to reference `gitlab-token.yaml` instead of `github-pat.yaml` and verify `kustomize build clusters/personal-cluster/secrets` contains exactly one `flux-system` Secret
- [ ] 4.3 Update `flux-system/gotk-sync.yaml` `url` to `https://gitlab.com/goldencanopy/personal-cluster.git` and verify no `github.com` remains in `clusters/`
- [ ] 4.4 Confirm `ImageUpdateAutomation` uses a token that can push `flux-image-updates`, adjusting the commit author identity if desired, and verify the manifest still references the `flux-system` GitRepository

## 5. Image-update merge-request CI

- [ ] 5.1 Add `.gitlab-ci.yml` with a job on push to `flux-image-updates` that creates or updates an MR into `main` using the CI token, tagged `self-hosted`; verify YAML validity (`glab ci lint` or a pipeline run)
- [ ] 5.2 Delete `.github/` (workflow and `copilot-instructions.md`) and verify no `.github` references remain in `README.md` or elsewhere
- [ ] 5.3 Verify the next image update opens exactly one merge request from `flux-image-updates`, runs on the in-cluster runner, and a subsequent push updates it rather than creating a duplicate

## 6. Docs and redeploy

- [ ] 6.1 Update `redeploy-flux.sh` to decrypt/apply `gitlab-token.yaml` and GitLab wording; verify the script reaches the `flux reconcile` step against a test context (or `bash -n` plus a dry inspection)
- [ ] 6.2 Update `README.md` bootstrap section to `flux bootstrap gitlab --owner goldencanopy --repository personal-cluster --token-auth`, GitLab prerequisites, and the self-hosted runner; verify no `github`/`pull request` wording remains

## 7. Cutover verification

- [ ] 7.1 Apply the updated manifests (via `redeploy-flux.sh`) and verify `flux get sources git` reports the GitLab URL with a successful/cloned status
- [ ] 7.2 Force reconciliation and verify `flux reconcile source git flux-system && flux reconcile kustomization flux-system` reports `Reconciliation finished`
- [ ] 7.3 Verify the top-level Kustomization is `Ready=True`, the runner is online, and previously deployed apps remain healthy

## Workflow follow-up

- Archive the change after the cutover is verified and the project's review requirements are satisfied.
- Decide the fate of the old GitHub repository (archive read-only or delete).
