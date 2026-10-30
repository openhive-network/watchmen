# Automated contributions

This directory configures the automated development platform that contributes to this
repository. This note says which branches it uses here and how its work reaches the
project's main line.

## Branches

- `aidev/integration` — the integration branch. Automated work lands here and nowhere else.
- `main` — the project's main line; reached from `aidev/integration` only by merge request
  (`aidev handoff`). `main` is fast-forward only, so the hand-off is a linear copy, one
  commit per change. Merge integration MRs **keeping the source branch**
  (`aidev/integration` is protected, so GitLab never deletes it).
- `ai/*` — one branch per task, created and deleted by the platform. Do not commit to them.
- `session/*` — a session's accumulated work, landed on the integration branch as a batch.

## How work reaches the main line

Task and session branches never reach `aidev/integration` through merge requests; the platform
lands them after its own verification. `aidev/integration` reaches `main` by this project's
usual process, merge requests included — the platform never merges into any other branch.

Whether this project's CI pipelines skip `ai/*` and `session/*` branches is decided by the
project's CI rules (today `.gitlab-ci.yml`'s only job runs for merge requests that change
`input/community/`).

**Auto DevOps is on for this project** (project-level setting, Settings > CI/CD > Auto
DevOps). It only acts on a pushed branch that has no `.gitlab-ci.yml`; every branch here
carries one, so it should not start pipelines, but turn it off if a branch ever shows
Auto DevOps jobs (`secret_detection`, `build`, ...).

## Suites run before work lands

The repository has no test suite. Declared in `.aidev/project.yaml` under `verification`,
all through `.aidev/run-checks.sh`, which writes `test-results/<slot>/junit.xml` (one case
per step):

- `quick`, `full`, `canary`, `coverage`, `system` — `syntax compile`
- `baseline` — `compile`
- `static` — `syntax`

`syntax` is `bash -n` of every `scripts/*.sh`. `compile` runs `scripts/compile_badactors.sh`
on a copy of `scripts/` and `input/` and checks that the committed
`output/flat/badactors.txt` holds exactly the accounts the inputs compile to (as sorted
sets: the committed file is sorted in the maintainer's locale, en_US.UTF-8, and the test
image has only the C collation). A change to `input/` therefore has to commit the
recompiled list with it. The whole set takes a second.

There is no coverage tool, so `coverage` repeats the checks without measuring; `system` has
no services to run against and repeats them too.

### Not run

- `scripts/validate-community-mr.sh` (CI's advisory `validate-community-submission` job)
  diffs a merge request against `origin/main`, which a gate's checkout does not have.
- `scripts/update_inputs.sh` downloads the upstream lists (network).

`test-results/` is not in `.gitignore`; do not commit it.

## Test runtime

`.aidev/runtime/Dockerfile` is alpine (CI's job image, pinned by digest) with bash, git and
GNU coreutils/diffutils installed at build time, since CI's `apk add` cannot run offline.
Rebuild and re-pin it with `.aidev/runtime/build.sh --push` when the Dockerfile changes, and
put the printed `repo@sha256:…` into `environment.image`.
