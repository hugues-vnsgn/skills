# Refresh vendored mobile skills during every upstream sync

## Problem Statement

The fork's upstream sync merges `mattpocock/skills`. It does not fetch the independent repositories from which `swiftui-expert-skill` and `uikit-expert` were copied. Both skills live in the fork-owned mobile tree, so that merge will preserve them unchanged even when their original authors publish fixes. Their source commits are currently written in the mobile bucket README, but there is no sync gate or merge base for reconciling future local edits. A fresh copy of either repository would also overwrite adjustments made here, including the initial prose and packaging changes.

## Solution

Every run of the primary upstream sync checks both vendor repositories for new commits and reconciles each changed skill into its fork-owned copy before the sync can be shipped. An unchanged vendor source produces an explicit checked-and-unchanged result, not a content edit. A changed source is merged against the last integrated source commit so fork-local changes survive. Conflicts, missing sources, and licensing changes stop the sync for review instead of being silently skipped or overwritten. The completed sync records both integrated vendor commits and reports the outcome for each source alongside the primary upstream range.

## User Stories

1. As a fork maintainer, I want a vendor refresh to run on every primary upstream sync, so neither mobile skill silently falls behind its original repository.
2. As a maintainer, I want to see the exact old and fetched source commits for each skill, so the provenance and update range are auditable.
3. As a maintainer, I want an unchanged source to be reported explicitly without rewriting files, so a no-op check does not create noise.
4. As a maintainer who has edited a vendored skill, I want my changes reconciled against the new source rather than replaced by a fresh copy, so local decisions remain intact.
5. As a reviewer, I want overlapping edits, upstream deletions, and moved files to be surfaced for a deliberate resolution, so an apparently clean sync cannot drop guidance or assets.
6. As a maintainer, I want new upstream reference files, scripts, and assets considered as part of the skill package, so an updated entry point does not point at missing material.
7. As a maintainer, I want changed license terms or missing license notices to block publication until reviewed, so redistribution remains authorized.
8. As an agent using the skills, I want the local no-em-dash rule, invocation metadata, references, and runnable tooling to keep working after a refresh.
9. As a reviewer, I want the sync PR to separate the primary merge from each vendor refresh and name the source ranges and conflict decisions, so I can audit what changed and why.
10. As a maintainer, I want a failed fetch or unresolved conflict to leave recorded source commits unchanged and stop the sync, so the next attempt starts from the real integrated base.

## Implementation Decisions

- The trigger is the existing primary upstream sync workflow, whether launched through its skill or its playbook. Vendor checks are a required gate before the sync PR is considered ready. This is not a periodic updater or a change to the primary upstream merge's ownership rules.
- Maintain a fork-owned, machine-readable provenance record for exactly these two vendor skills. Each entry names the source repository, source subtree, destination skill, last integrated full commit SHA, and license location. Bootstrap it from the source SHAs already recorded in the mobile bucket README. Do not reuse the primary upstream lock, which has a different remote and ancestor invariant.
- Fetch each vendor repository's default branch at sync time and compare its fetched full SHA with the recorded integrated SHA. A source with no new commit remains byte-for-byte unchanged. A changed source contributes its skill subtree and required root license, including references, scripts, and binary assets; unrelated files from the vendor repository stay out of scope.
- Use the recorded source commit as the base of a three-way reconciliation: old vendor content, current fork content, new vendor content. Treat local typography, metadata, and future author edits as fork changes. Handle upstream additions, removals, and renames; stop on conflicts or ambiguous mapping. Never replace the destination directory wholesale or resolve conflicts by automatically taking the vendor side. The fork keeps ownership of its registration and audience decisions.
- Preserve each author's copyright and permission notice. If the license is removed or changed, require an explicit licensing decision before advancing that vendor's recorded SHA. Keep source attribution and integrated SHA visible in the mobile bucket README as the human-facing view of the provenance record.
- Reconcile the fork's prose rule and packaging requirements after the merge. If the skill's behavior, name, invocation trigger, or audience changes, update its human-facing docs, catalog, role pages, and router as appropriate; regenerate catalog and marketplace outputs from their sources, never by hand.
- Amend the sync-only branch policy with a narrow exception for these vendor refreshes. Keep the primary merge and each vendor's reconciliation separately reviewable on the same sync branch. The PR records fetched SHA, prior SHA, changed or unchanged status, manual resolutions, and validation for each vendor. Advance source SHAs only after reconciliation and validation; do not mark an unshipped update as integrated.
- Network or authentication failure, inaccessible old source SHA, missing required package material, failed validation, or unresolved conflict blocks completion. Report the exact blocker; do not substitute a cached result for a successful fresh check.

## Testing Decisions

- Test the refresh gate at its workflow boundary with two small local Git repositories standing in for the vendor sources. Verify both are checked on every run, unchanged sources cause no file rewrite, and advancing one source updates only its destination and recorded SHA.
- Exercise a local edit plus a non-overlapping vendor edit and show that both survive. Exercise overlapping edits and upstream deletion or rename against locally changed content and show that the gate stops without advancing the SHA or discarding the local change.
- Exercise a failed fetch and a missing or changed license and show that the sync cannot be marked ready. Keep these tests network-independent; a real sync performs the live fetch.
- For a real refreshed skill, run the existing repository skill and fork checks, installer discovery with a copied installation, and any changed runnable script's relevant smoke path. Verify every referenced local file resolves. Report any unrelated baseline failures separately rather than treating them as vendor-refresh success.
- Avoid tests that only compare copied bytes or assert a file exists. The test must detect consumer-visible regressions: lost local guidance, missing references, unusable install, or a falsely advanced source SHA.

## Out of Scope

- Refreshing the fork's own KMP/CMP skills, whose currency follows a separate documentation and release cadence.
- Automatically publishing source releases, committing, pushing, or merging a PR without the existing approval workflow.
- Automatically resolving conflicting guidance or making a licensing decision for a maintainer.
- Monitoring vendor repositories between primary upstream syncs, or treating tags as authoritative instead of the fetched default-branch commit.

## Further Notes

The primary merge currently treats the mobile tree as sync-inert; its playbook has no vendor-fetch step. The source commits recorded by the mobile bucket README are `b24e68a965dc4b5bd2cc41dc60c094a26a9379ce` for `avdlee/swiftui-agent-skill` and `45c70f0f31e63c62bcb11da6c7bb3b4759dac393` for `ivan-magda/uikit-expert-skill`. The first vendor's package includes trace-analysis Python scripts and assets; the second includes UIKit references and a vendor-specific plugin manifest. Both are distributed under their respective MIT notices. This spec changes their update policy, not their initial import.
