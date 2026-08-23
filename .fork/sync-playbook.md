# Upstream sync playbook

The mechanical procedure for merging [`mattpocock/skills`](https://github.com/mattpocock/skills) into this fork. [MAINTENANCE.md](../MAINTENANCE.md) says *what* the fork is and why; this file says *what to type*. Every conflict you can expect is enumerated below in [Residual conflict surface](#residual-conflict-surface), with its resolution recipe in [`divergence.md`](./divergence.md); anything else that conflicts is a stop-and-investigate.

The procedure is written to be boring on purpose. It is the one this fork's 2026-08-13 restructure proved out, and the boundary it assumes — upstream buckets byte-frozen, every fork skill under `skills/team/` — is enforced by `scripts/harness/forkcheck.py`, so a sync that drifts fails CI rather than landing quietly.

## One-time setup

Per clone. Both commands are idempotent enough to re-run when in doubt.

```bash
git remote add upstream https://github.com/mattpocock/skills   # skip if it exists
git config rerere.enabled true
```

`rerere` ("reuse recorded resolution") is what keeps the recurring prose conflicts from costing anything twice. The fork's divergence in `README.md`, `CLAUDE.md`, `CONTEXT.md` and the bucket READMEs is appended sections, so the resolution is always "keep both" — resolve it once with rerere on and git replays that resolution at the next sync. It is per-clone local state, not a repo setting: a maintainer who skips this line resolves the same conflicts by hand every time.

## The sync

### 1. Fetch

```bash
git fetch upstream main
```

### 2. Review the delta against the lock

[`upstream.lock`](./upstream.lock) records the last upstream commit this fork merged. That makes "what changed since last sync" one command:

```bash
LAST=$(awk '/^upstream_sha:/ {print $2}' .fork/upstream.lock)
git log --oneline "$LAST"..upstream/main
git diff --stat "$LAST"..upstream/main
```

Read it before merging, not after. What you are looking for:

- **New upstream skills** — they need a catalog entry (step 7).
- **Renamed or removed upstream skills** — anything the fork's skills or `ask-matt` cross-reference by name now points at nothing.
- **Touches to paths in [`sanctioned-edits.txt`](./sanctioned-edits.txt)** — that is your conflict list, known in advance.
- **A new upstream skill whose directory basename collides with a fork skill** — `forkcheck`'s unique-skill-names assertion will fail the merge; decide the rename before you start rather than mid-conflict.

### 3. Branch — sync-only

```bash
git switch -c sync/upstream-$(date +%Y-%m-%d) main
```

A sync branch carries reconciliation and nothing else: no feature work, no drive-by fixes, no new skills. The reason is reviewability — a reviewer needs to be able to read every non-upstream hunk as "this is how the maintainer resolved a conflict". Improvements the sync inspires go in a follow-up PR off `main`.

### 4. Merge — never rebase

```bash
git merge upstream/main
```

Merge, always. Rebasing the fork onto upstream rewrites fork commits that are already published, and it replays every fork commit against every upstream change — turning one resolution per divergence into one per commit. The merge commit is also the honest record of which upstream commit the fork absorbed and when.

### 5. Resolve, by recipe

Every conflict should be a row in [Residual conflict surface](#residual-conflict-surface). Look up the file in [`divergence.md`](./divergence.md) and apply the recipe there — don't re-derive it. Two shapes recur:

- **Modify/delete** (`.claude-plugin/`, `scripts/sync-plugin-version.mjs`, upstream's `setup-matt-pocock-skills`): upstream edited a file this fork deleted. Keep the deletion — `git rm -r --ignore-unmatch <paths>`.
- **Both-modified prose**: keep both sides. rerere replays this once recorded.

If a file conflicts that is *not* in the table: stop. Do not resolve it yet. Either the fork acquired a divergence nobody recorded, or upstream started writing a path the fork thought was its own. Both are boundary changes: work out which, then land the record — a `divergence.md` row plus a `sanctioned-edits.txt` line — as part of this sync, so the next maintainer meets a documented conflict instead of the same surprise.

### 5b. Re-home the changesets upstream brought in

Upstream ships changesets, and each names *upstream's* package. This fork renamed the package to `osxsystem-skills`, so an imported changeset addresses something that isn't in the workspace and `changeset version` aborts — failing the **Release** workflow, which is a different workflow from the one step 6 runs. Nothing conflicts (they arrive as new files with new names), so nothing warns you.

Rewrite the package name in every changeset the merge added:

```bash
sed -i '' 's/^"mattpocock-skills":/"osxsystem-skills":/' .changeset/*.md   # GNU sed: -i without ''
```

Leave the bodies alone — they are upstream's release notes for changes this fork now carries, and they are accurate as written.

`forkcheck`'s `changeset-package` assertion in step 6 catches a missed one, so this step is belt-and-braces rather than the only guard.

### 6. Assert the boundary

`forkcheck` normally compares upstream territory against the *locked* commit — a live comparison would redden CI on an untouched fork every time upstream pushes. During a sync the two are meant to converge, so point it at the merged ref:

```bash
python3 scripts/harness/forkcheck.py --upstream-ref upstream/main
python3 scripts/harness/skillcheck.py
python3 scripts/check-confusable-skills.py
bash scripts/harness/test_guardrail.sh
bash scripts/harness/test_forkcheck.sh
python3 scripts/generate-catalog.py --check
```

Read `forkcheck`'s failures as a to-do list, not a verdict:

- *"upstream territory differs … but is not in `sanctioned-edits.txt`"* — the merge dragged an upstream file off-baseline. Restore it (`git checkout upstream/main -- <path>`) unless the divergence is deliberate, in which case record it in both files.
- *"listed in `sanctioned-edits.txt` but identical to upstream"* — upstream adopted a change the fork was carrying. Drop the entry and its `divergence.md` row; a shrinking list is the point.
- *"fork path not covered by any tree under Additions"* — a new fork-owned path needs its row in `divergence.md`'s Additions table.
- *"N skills share this install name"* — the flat install namespace collided. Rename the *fork* skill (upstream's name is not ours to change), and update its catalog entry, both READMEs, its docs page, and `ask-matt`.

### 7. Catalog the new upstream skills

New upstream skills stay where upstream put them — a sync never re-homes a vendor file. What the fork owes each one is a sidecar entry in [`catalog.yaml`](./catalog.yaml), under the bucket it arrived in:

```yaml
  - name: <directory basename>
    path: skills/<bucket>/<name>
    origin: upstream
    domain: <bucket>
    audience: [engineer]          # every role it genuinely serves
    owner: "@hugues-vnsgn"               # mirror CODEOWNERS — username now, team slug after an org transfer
```

Then regenerate the view and refresh the role pages the new audiences touch:

```bash
python3 scripts/generate-catalog.py     # rewrites CATALOG.md; never hand-edit it
```

`docs/roles/<audience>.md` is curated by hand from the catalog — add the skill to each role page its `audience` names, in reading order. `forkcheck`'s catalog-completeness assertion catches a skipped entry; nothing catches a skipped role page but review.

### 8. Advance the lock

```bash
git rev-parse upstream/main    # → upstream_sha
```

Update the three recorded fields in [`upstream.lock`](./upstream.lock) — `upstream_sha`, `upstream_commit_date`, `recorded_on` — and the "Last verified" line at the bottom of [`sanctioned-edits.txt`](./sanctioned-edits.txt)'s header. An un-advanced lock makes the *next* sync's step 2 replay work already merged.

### 9. Ship it

Open the PR from the sync branch. CODEOWNERS routes it to the maintainers owner (see the CODEOWNERS header for the current identity), because every path a sync touches is upstream territory or the control plane. The PR body should carry the upstream range (`<old sha>..<new sha>`), the conflicts resolved and by which recipe, any change to `sanctioned-edits.txt`, and the new upstream skills catalogued. Then, on each machine:

```bash
scripts/link-skills.sh
```

## Residual conflict surface

The complete set of paths where upstream and this fork can both write — the sync-active half of [`divergence.md`](./divergence.md), one row per section there. **A conflict outside this table is stop-and-investigate** (step 5): it means the boundary moved, and the record has to catch up before the merge lands.

| Conflict | Paths | Shape | Recipe |
|---|---|---|---|
| Plugin route removed | `.claude-plugin/`, `scripts/sync-plugin-version.mjs` | modify/delete | [Keep the deletion](./divergence.md#claude-plugin--deleted-and-scriptssync-plugin-versionmjs); drop any `sync-plugin-version` script upstream re-adds to `package.json` |
| Setup skill re-homed | `skills/engineering/setup-matt-pocock-skills/`, `docs/engineering/setup-matt-pocock-skills.md` | modify/delete | [Keep the deletion](./divergence.md#skillsengineeringsetup-matt-pocock-skills--deleted); port upstream's changes by hand into `skills/team/platform/setup-osxsystem-skills/` |
| Fork framing in prose | `README.md`, `CLAUDE.md`, `CONTEXT.md`, `.agents/install-block.md`, `.agents/writing-docs.md`, `.agents/adr/0001-explicit-setup-pointer-only-for-hard-dependencies.md`, `skills/{engineering,in-progress,misc}/README.md`, `docs/engineering/*.md`, `docs/productivity/wait-what.md` | both modified | [Keep both](./divergence.md#prose-files--readmemd-claudemd-contextmd-maintenancemd-adjacent-conventions), then verify install commands say `hugues-vnsgn/skills`, the fork README framing and its Mobile and Platform sections survived, and no fork skill was re-added to an upstream bucket README. rerere absorbs these after the first sync |
| Fork identity in tooling | `package.json`, `package-lock.json`, `.changeset/config.json`, `.gitignore` | both modified | [Take upstream's dependency and tooling changes](./divergence.md#packagejson-package-lockjson-changesetconfigjson-gitignore); keep the fork's `name`, `description`, `repository`, changeset `repo`, and ignore entries |
| Hardened git guardrail | `skills/misc/git-guardrails-claude-code/` | both modified | [Keep both](./divergence.md#skillsmiscgit-guardrails-claude-code--hardened), then re-run `bash scripts/harness/test_guardrail.sh` — the tests are the arbiter, not the diff |
| Released changeset re-edited | `.changeset/<name>.md` | modify/delete | [Keep the deletion](./divergence.md#additions-sync-inert) (`git rm --ignore-unmatch`): the fork consumed it with `changeset version`, so its content already sits in `CHANGELOG.md`. Restoring it re-releases shipped work |
| Router and cross-references | `skills/engineering/{ask-matt,code-review,to-spec,to-tickets,triage,wayfinder}/SKILL.md` | both modified | [Keep both](./divergence.md#skillsengineeringask-mattcode-reviewto-specto-ticketstriagewayfinderskillmd), then re-read `ask-matt` and confirm every fork skill still appears and every upstream skill it routes to still exists under that name |

Everything else the fork owns — `skills/team/`, `docs/team/`, `docs/roles/`, `research/`, `.fork/`, the harness, `MAINTENANCE.md`, `CUSTOMIZING.md` — is sync-inert. Upstream has never written those paths, so a merge cannot conflict there; they need only to survive, which `forkcheck` confirms.

## Promoting an upstream skill to the team

Sometimes an upstream skill becomes core to a team domain. **Promotion is a catalog and docs edit. It is never a file move.**

Moving the directory out of its upstream bucket would delete an upstream path and add a fork one — which means a modify/delete conflict on every future upstream edit to that skill, a new `sanctioned-edits.txt` entry, and a rename in the flat install namespace. The fork spent the 2026-08-13 restructure removing divergences of exactly that shape.

To promote, leave the bytes alone and change how the skill is described:

1. In [`catalog.yaml`](./catalog.yaml), widen the entry's `audience` to the roles it now serves. `origin` stays `upstream`, `path` and `domain` stay as they are — the skill is still upstream's, still in its bucket.
2. `python3 scripts/generate-catalog.py` to refresh `CATALOG.md`.
3. Add it to each `docs/roles/<audience>.md` page in the right reading position — the role pages are the promotion.

If the team needs *different behaviour*, that is not a promotion: write a fork skill under `skills/team/<domain>/` that cross-references the upstream skill by name, exactly as `kmp-test-seams` does with `tdd`. That is the pattern the retired TDD append was converted into.
