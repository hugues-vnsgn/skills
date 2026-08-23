# Migrate the repo from `osxsystem` to `hugues-vnsgn`

## Problem Statement

The repository's GitHub home is moving from the `osxsystem` account to the `hugues-vnsgn`
account. The repository does not merely *live* at that address, it *describes* itself by
that address in 290 places: the canonical install command a user pastes to get the skills,
the ownership manifest that says who reviews what, the generated installer manifest, the
generated catalog, the changeset changelog generator, the local issue tracker's sync
remote, and a CI assertion that fails the build if the README's install command changes.

Two failure modes bracket the work. Doing nothing leaves a repository that instructs every
reader to install from an account that no longer hosts it. Doing the obvious thing, a
single token replacement of `osxsystem` with `hugues-vnsgn`, corrupts 120 strings that must
not change: the package name, the name of a published skill, the fork's own description of
itself, and a changelog whose entries are a dated record of what was true. It also breaks
three CI gates, because two of the affected files are generated from a source of truth and
one is a test fixture asserting the package name.

Underneath that, the transport itself is a trap. A mirror clone and push, the usual reflex
for "move a repo", would silently discard 25 pull requests, 3 releases, and the issue
history, produce no redirect for the old address, and fail outright on the 25 `refs/pull/*`
refs that a mirror clone drags along.

## Solution

Move the repository with GitHub's ownership transfer, so that commits, branches, tags,
releases, pull requests, and issues arrive intact and the old address keeps resolving
through a permanent redirect. Then rewrite only the references that are genuinely
*coordinates* (where the repo lives, who owns it), leaving the references that are
*identity* (what the project is called) and *record* (what was true on a past date)
untouched.

Finally, encode the resulting invariant as a permanent CI check, so that the distinction
between a coordinate and an identity string survives as an executable rule rather than as
a decision someone has to remember. A future edit that reintroduces the old address
outside the recorded exceptions fails the build.

## User Stories

1. As the repo owner, I want the repository moved to my own account with its commits, tags, releases, and pull requests intact, so that I keep the project's full record and do not start over from a bare history.
2. As the repo owner, I want commit SHAs left byte-identical, so that existing clones fast-forward instead of diverging and every recorded SHA stays a valid reference.
3. As the repo owner, I want every link to the old address to keep resolving after the move, so that nothing I have already written, bookmarked, or installed silently rots.
4. As the repo owner, I want the release queue emptied before the move, so that the migration is not entangled with six unrelated pending changelog entries.
5. As the repo owner, I want the repository to be a clean tagged release at the moment it moves, so that the pre-move and post-move states are both nameable.
6. As the repo owner, I want a recoverable copy taken before the transfer, so that a fat-fingered force push during cutover is survivable.
7. As the repo owner, I want to know which steps only I can perform, so that I am not waiting on an agent for something it cannot do and not surprised by an agent doing something outward-facing on my behalf.
8. As the repo owner, I want no other account left with write access after the move, so that the new repository starts with exactly one collaborator.
9. As the repo owner, I want my `gh` configuration and my account credentials left alone unless I explicitly run the command, so that authentication state stays something I control.
10. As a person installing these skills, I want the canonical install command to name the new address, so that pasting it from the README actually works.
11. As a person installing these skills, I want the single-skill install and update commands to name the new address too, so that the narrow path works as well as the broad one.
12. As a person who already installed these skills, I want the old install command to keep working, so that I am not broken by a move I did not participate in.
13. As a person installing these skills, I want the skill names unchanged, so that a rename does not force me to uninstall and reinstall anything.
14. As a coding agent reading the repo's own instructions, I want the fork's self-description to stay coherent, so that I do not conclude the project was renamed when only its address changed.
15. As a coding agent, I want the installer's grouping manifest regenerated rather than hand-patched, so that it agrees with the catalog it is derived from.
16. As a future maintainer, I want the changelog to keep saying what was true on the date it was written, so that it remains a record rather than a retroactively tidied story.
17. As a future maintainer, I want the architecture decision records left intact, so that a decision's stated context is not quietly edited to match a later world.
18. As a future maintainer, I want the planning notes under the scratch tree left intact, so that the historical reasoning stays readable as it was.
19. As a future maintainer, I want the ownership manifest's org-upgrade note to stop naming an account the project has left, so that the upgrade path it describes is still followable.
20. As a future maintainer, I want the ownership manifest kept rather than deleted, so that the intended review boundaries stay documented even while there is one owner.
21. As a future maintainer, I want no required-review rule added, so that the sole owner is not blocked from merging their own work.
22. As a future maintainer, I want the reason each surviving old-address reference survives to be recorded, so that a later reader can tell an intentional exception from an oversight.
23. As a future maintainer, I want a reintroduced old address to fail CI, so that the migration cannot silently regress.
24. As a future maintainer, I want that check to fail closed when its own inputs are missing or unreadable, so that a broken guard reads as a failure and not as a pass.
25. As CI, I want the README's install command and the assertion that checks it to move together in one change, so that the build is never green against a stale expectation and never red against a correct README.
26. As CI, I want the generated catalog checked for staleness on every run, so that a forgotten regeneration is caught instead of drifting silently.
27. As CI, I want the fork boundary guard to pass without new exemptions, so that the migration does not widen the set of upstream files allowed to differ.
28. As a reviewer, I want the whole rewrite to land as one atomic change, so that no intermediate commit exists in which the generated files disagree with their sources.
29. As a reviewer, I want the change reviewable as a diff before it is committed, so that I can see what the automated rewrite actually touched.
30. As a reviewer, I want the migration to carry its own changelog entry, so that the move is discoverable from the release history.
31. As the repo owner on this machine, I want my local clone pointed at the new address explicitly, so that I am not depending on a redirect for day-to-day work.
32. As the repo owner on this machine, I want the abandoned migration branches and the leftover worktree cleaned up, so that the checkout does not accumulate dead state.
33. As the repo owner on this machine, I want the issue tracker's sync remote updated and then verified with a real write, so that I do not repeat a previously diagnosed failure where writes silently went to the wrong store.
34. As the repo owner on this machine, I want the locally linked skill directories re-verified after the move, so that my agent harness is still reading the skills it thinks it is.
35. As the repo owner, I want the installer verified against the new address for real, not just asserted in a test, so that I know the end-to-end path works before I rely on it.
36. As the repo owner, I want the audit to state an expected number of surviving old-address hits rather than expecting zero, so that a correct result does not read as a failure every time I run it.
37. As the repo owner, I want the upstream sync relationship untouched, so that the fork control plane keeps working exactly as before the move.
38. As the repo owner, I want to be told which decisions were assumed rather than confirmed, so that I can override them before anything irreversible happens.

## Implementation Decisions

### Transport

- **Ownership transfer, not mirror push.** Transfer carries commits, branches, tags, the 3
  releases, all 25 pull requests, and issue history, and installs a permanent redirect from
  the old address. A mirror push carries git objects only, creates no redirect, and is
  additionally blocked in practice: a mirror clone fetches the 25 `refs/pull/*` refs and the
  subsequent push is rejected as a hidden-ref update.
- **No history rewrite.** No filter-repo, no rebase, no tag re-cutting. Commit SHAs stay
  identical, which is what makes existing clones fast-forwardable.
- **The transfer is initiated from the source account.** The target account has no push
  access to the source repository (verified: the collaborators endpoint returns 403 for it),
  so the target cannot initiate. The target then accepts the incoming invitation.
- **The name collision is already cleared.** The target account previously held a repository
  at the destination name. It was a stale fork of the upstream project with no local work in
  it (all of its commits were authored upstream), and it has been deleted; the name now
  resolves 404 at both the API and git level. Nothing is salvaged from it.
- **Post-transfer topology is unchanged.** The source is not a GitHub fork, so the
  transferred repository is not one either. The relationship to the upstream project stays
  what it already is, a plain git remote, which means the fork control plane (the boundary
  guard, the upstream lock, the sync skill) requires no change at all.

### Sequencing

Ordered, because several steps are only safe in this order:

1. **Merge the open release pull request first.** It versions the project, folds the 6
   pending changesets into the changelog, deletes them, and tags. This empties the changeset
   queue, makes the pre-move state a clean tagged release, and removes 6 files from the
   rewrite entirely. Its content then falls under the preserved-record policy and needs no
   rewriting.
2. **Take a git mirror backup**, outside the working tree, before any transfer.
3. **Transfer**, then accept, then revoke any residual collaborators.
4. **Point the local clone at the new address explicitly.**
5. **Then rewrite the references**, on a fresh branch cut after the transfer.

The rewrite comes *after* the transfer, not before. The repository's location is the fact
and the text is a description of it, so the description follows. Rewriting first would put a
README on the default branch advertising an address that does not yet exist.

### Rewrite scope

Three classes of reference, and only the first two move:

- **Coordinates** (move): where the repository lives and how to install from it. Repository
  URLs, the whole-set and single-skill install commands, the package manifest's repository
  field, the changeset changelog generator's repo field, the issue tracker's sync remote.
- **Ownership handles** (move): the single handle in the ownership manifest and on every
  entry of the catalog source of truth, plus one occurrence in the sync playbook.
- **Identity** (stays): the package name, the package description, the name of the published
  setup skill and its docs page, and the fork's prose description of itself. An account move
  is not a rebrand. Renaming the published skill would additionally cost every existing
  consumer a reinstall.
- **Record** (stays): the changelog, the architecture decision records, the scratch planning
  notes, and the out-of-scope notes. These are dated statements that were true when written.

### Rewrite mechanism

A blanket token replacement is rejected: it would corrupt 68 occurrences of the package name
form (62 of which are references to the published setup skill), 22 prose occurrences, and 27
preserved-record links. The rewrite is therefore two path-scoped patterns, which is the one
place this spec inlines a precise artifact, because the exclusion list is the decision and
prose cannot state it unambiguously:

```
Pattern A   osxsystem/skills  ->  hugues-vnsgn/skills
  applied repo-wide EXCEPT: CHANGELOG.md, .agents/adr/, .scratch/,
                            .out-of-scope/, .git/, node_modules/

Pattern B   @osxsystem  ->  @hugues-vnsgn
  applied to exactly three files: the ownership manifest,
  the catalog source of truth, the sync playbook
  NOT the changelog (preserved), NOT the generated catalog (regenerated)

Neither pattern matches `osxsystem-skills` or bare `osxsystem`, which is what
keeps the identity class intact by construction.
```

Pattern A is deliberately broad enough to cover the install commands, every repository URL,
the package manifest, the changeset config, the installer manifest generator's embedded
install string, and the structural validator's hardcoded canonical install string in a
single pass. That last point is the important one: the README and the CI assertion that
checks the README move in the same sweep, so they cannot fall out of lockstep.

### Generated artifacts and the one hand edit

- The catalog and the installer manifest are **regenerated from their generators**, never
  swept and never hand-edited. The installer manifest generator additionally holds one
  identity-class string that must survive, which is a second reason not to sed it.
- One **hand edit**: the ownership manifest carries a comment describing an upgrade path
  "when the repo transfers to an `osxsystem` org". That is incoherent once the project has
  left that account, and the destination is a personal account that cannot become an
  organization under its own name. It becomes account-agnostic, naming no specific
  organization.

### Fork boundary

No new boundary exemptions are required. Every file the rewrite touches is either already
listed as a sanctioned upstream edit (the README, the two agent instruction files, the
context and instruction files, the package manifest and lockfile, the changeset config, the
installer manifest, all eight upstream docs pages, all six upstream skill definitions, one
bucket README) or lives in a fork-owned, sync-inert tree. The changelog and the changesets
are explicitly skipped by the boundary guard already.

### Ownership manifest

Kept, with the handle swapped. It is a documented set of review boundaries already shaped
for a later move to an organization, and deleting it to save lines would discard a design
artifact. No branch protection is added: a required-review rule on a single-owner repository
would block the owner's own merges.

### Local cutover

The local issue tracker's configuration is **untracked**, so its sync remote change is a
machine-local edit and not part of the pull request. Also local and outside the pull request:
pointing the clone's remote at the new address, deleting the two abandoned migration branches
(both of which contain zero commits beyond the default branch) and the leftover worktree, and
re-verifying the linked skill directories.

### Delivery

One atomic pull request on a branch cut after the transfer, with all CI gates green in a
single commit-set, carrying its own patch changeset. Staged delivery is rejected: it produces
intermediate states in which the generated files and their sources disagree, which is exactly
what the staleness gates exist to catch.

## Testing Decisions

### What makes a good test here

Assert observable behavior, not the mechanism. The observable behavior of this change is
that the installer resolves the new address, that the repository's own gates pass, and that
the coordinate invariant holds with a bounded and enumerated set of exceptions. Tests must
not assert on how the rewrite was performed: not diff line counts, not sed invocations, not
the order files were touched. A rewrite done by hand and a rewrite done by script must be
indistinguishable to the tests.

The central assertion is an **allowlist, not a zero**. A repo-wide search for the old address
is *expected* to return roughly 90 identity-class hits plus 27 preserved-record hits. A test
that expects zero would be permanently red, and a human running the audit informally would
read a correct result as a failure. The expected exceptions are enumerated, so an unexpected
hit is distinguishable from an intended one.

### Seam

**One seam, and it already exists.** The structural validator module is the repo's existing
home for repo-coordinate assertions: it already requires the canonical install command
verbatim in the README, and already asserts that install commands are absent from published
docs pages. The new coordinate invariant is a sibling check in that same module, registered
the same way as its four existing checks.

A standalone new guard script was considered and rejected. It would be a second seam for the
same concern, and the concern already has a home.

The new check must **fail closed**: unreadable inputs or a missing allowlist are failures, not
passes. This matches the existing boundary guard, which fails closed on an unresolvable
upstream ref or an unreadable lock.

### Modules tested

- The **structural validator**, gaining the coordinate check. Prior art for its shape is the
  existing install-block check in the same module: a verbatim string assertion over repository
  files with an explicitly scoped exception (that check already carves out one docs subtree).
- The **catalog generator's staleness flag**, which already exists but is not called by CI.
  It gets wired in, closing a silent-drift hole by omission rather than by writing anything new.
- The **boundary guard** and the **installer manifest staleness check**, unchanged, run as
  regression gates.

Prior art for fail-closed harness testing is the existing boundary-guard test suite: a
fixture-driven bash suite that constructs bad states and asserts the guard rejects them. The
coordinate check gets the same treatment, including a negative case that reintroduces the old
address outside the allowlist and asserts a failure.

### Verification beyond CI

- **All existing gates green**, locally and then on the new remote.
- **A live installer run against the new address**, into a throwaway directory, confirming the
  new namespace resolves for real rather than only in assertion.
- **An issue tracker write round-trip** after the sync remote edit. This is not ceremony: this
  project has a diagnosed history of tracker writes silently routing to a store where they
  could not be closed, with the built-in diagnostics reporting no errors throughout. A create
  and a close are the only reliable evidence.
- **The linked skill directories re-verified**, noting that this is expected to be close to a
  no-op precisely because the skill names are unchanged.

## Out of Scope

- **Rebranding.** The package name, the package description, the name of the published setup
  skill, its docs page filename, and the fork's prose self-description all keep the old token.
  If a rebrand is wanted it is a separate change, and it is a breaking one for consumers.
- **Rewriting the record.** The changelog, both architecture decision records, the scratch
  planning notes, and the out-of-scope notes are not swept.
- **Any git history rewrite.** No filter-repo, no commit author rewriting. This also means
  other contributors' names stay in the history; the "not all the contributors" requirement is
  satisfied by revoking *access*, not by editing authorship.
- **Issue tracker data migration.** Only the sync remote string changes. No Dolt remote
  migration, and the separate planning store is not touched.
- **Branch protection**, required reviews, or any other new repository setting.
- **Anything from the deleted stale fork.** It held no local work.
- **A pull request and issue metadata backup dump.** Carrying that metadata is precisely what
  transfer does well, so dumping it hedges the wrong risk.
- **Winding down the source account.** The plan assumes it survives (see Further Notes).
- **Moving the local clone directory.** Its path is unchanged.
- **The upstream sync relationship.** Untouched, and by design unaffected.

## Further Notes

### Confirmed inputs

- **Source account survival: confirmed.** The source account stays alive and its old
  repository name is left permanently empty, so the transfer redirect survives indefinitely.
  **This is what carries the preserved-record policy above**: the 17 changelog links and the
  one decision-record link keep resolving, so they are not rewritten and no third sweep
  pattern exists. Should that ever change, the correct move reverses: rewrite those links,
  which resolve under the new address anyway, because transfer carries the pull requests with
  it.
- **Backup location: confirmed.** A git mirror is taken to `~/Backups/` before the transfer.
- **Harness linking: declined.** The repo's own implementation skill is not linked into the
  local agent harness for this work; the spec already names the seam and the gates, which is
  the substance of what that skill would direct.

### Standing recommendations, uncontested

Two decisions were put to the owner and left unanswered rather than overridden. They are
carried as recommendations and remain open to reversal:

1. **Execution boundary.** The owner personally runs the four privileged steps (merge the
   release pull request, initiate the transfer, accept it, revoke collaborators), because they
   are outward-facing and because switching the authenticated account writes outside the
   working tree. Everything after is automated.
2. **Deliverable shape.** A written runbook plus automated execution of the non-privileged
   half. An interactive wizard was considered and judged not worth its cost for four one-line
   human steps run once.

### The redirect is fragile in one specific way

Creating *any* repository at the old address after the transfer retires the redirect
immediately. This is the instinctive move, leaving a placeholder that points at the new home,
and it destroys the single biggest reason transfer was chosen over a mirror push. The old
address must stay empty.

### One correction to the record

An earlier reading held that the generated catalog had no staleness gate at all. It does have
one, as a flag on its generator; CI simply never calls it. The fix is therefore a one-line CI
wiring change, not a new check.

### Why the audit cannot expect zero

Worth restating because it is the most likely thing to be misremembered later: after this
change, searching the repository for the old account name returns well over a hundred hits,
and that is correct. Roughly 90 are the project's own name and the name of a published skill;
27 are dated historical links. The coordinate check exists to make that distinction
machine-checkable, so nobody has to re-derive it by reading.
