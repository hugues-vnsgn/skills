# osxsystem-skills

## 1.8.0

### Minor Changes

- [#12](https://github.com/hugues-vnsgn/skills/pull/12) [`ad5422b`](https://github.com/hugues-vnsgn/skills/commit/ad5422b571355a3eb401779ccfaaebc294552078) Thanks [@hugues-vnsgn](https://github.com/hugues-vnsgn)! - Ship `use-git-worktree`: promote it out of `in-development/` into `house/platform/`, and restate what that domain is for.

  The skill itself is unchanged apart from two lines. It drops `metadata.internal: true`, which is what kept it out of the installer picker, so it now installs like any other promoted skill. And the paragraph explaining why an old submodule guard was wrong becomes a one-sentence prohibition, because its job was never to record history: it was to stop the next agent helpfully adding the guard back. The trigger is untouched, deliberately. It was rewritten once already against how the worktree actually gets made, and tightening it now on a hunch would trade a calibrated trigger for a guess.

  **Platform's charter was lying before this landed.** It read "the toolchain itself: repo configuration for the engineering flow, bringing capabilities across from other codebases, and unsticking a design", which already failed to describe `herdr` (a terminal multiplexer) and `when-stuck` (re-framing a design problem). Adding a worktree skill made it undeniable. The domain is now **the workbench rather than the code**: the workspace a change is built in, the repo configured for the engineering flow, capabilities brought across from elsewhere, and unsticking a design. That is a boundary a future skill can be tested against, which "toolchain" had stopped being. Restated in all four places that carry it: the bucket `README.md`, the top-level `README.md`, `CLAUDE.md`, and the `.fork/divergence.md` Additions row.

  Platform gains its first **Model-invoked** section, in both its own README and the top-level one; every resident until now was user-invoked or beta.

  Registration for a promoted skill, in full: catalog entry moved to the `platform` domain with `status: beta` dropped, `CATALOG.md` and `marketplace.json` regenerated, a docs page at `docs/house/platform/use-git-worktree.md`, an entry in the engineer reading order, and a routing paragraph in `ask-matt` at the point in the main flow where code first gets written. The router paragraph says plainly that the skill fires per change rather than per step, since that is the thing a numbered list would otherwise imply and get wrong.

  Two things found while writing it, both filed rather than fixed here:

  - `use-git-worktree` allows exactly two branch prefixes and says not to invent a third, while `prototype` puts its work on a `prototype/<name>` branch. A prototype detour that reaches for the worktree skill therefore gets `feat/<slug>` and quietly breaks a convention that exists so the prototype stays findable. Filed as `skills-7e0`.
  - `skills-dpk`, which reported both fork guards false-positiving on nested worktrees, was already fixed and shipped. Closed against the two code locations that prove it.

- [#10](https://github.com/hugues-vnsgn/skills/pull/10) [`9dc983b`](https://github.com/hugues-vnsgn/skills/commit/9dc983b3690f94580cf91586e724d8cba0cca52e) Thanks [@hugues-vnsgn](https://github.com/hugues-vnsgn)! - Rewrite `compose-multiplatform-ui` against current Compose Multiplatform (1.11.x), pulled from the official JetBrains multiplatform-dev docs.

  The skill was a correct fact sheet that had gone quiet on the things that now bite hardest on iOS. Four gaps closed:

  **It never named the shell decision.** A CMP iOS app either runs one `ComposeUIViewController` that owns tabs and back stack, or hands the navigation chrome to SwiftUI's `TabView`/`NavigationStack` and renders one Compose screen per destination. The second shape is the only route to iOS 26 **Liquid Glass**, because the system draws those effects through the native containers and no Compose API or shader reproduces them. It also decides navigation library, entry-point count, and the Swift side all at once, and reversing it later is a rewrite. The decision now sits above the screen-writing sections, with the worked migration (navigation interception via `snapshotFlow`, the `LocalUseNativeNavigation` local, the two `UIViewControllerRepresentable` bridges) and the `if #available(iOS 26.0, *)` fallback in the reference.

  **`UIKitInteropProperties` was missing entirely**, which is where interop bugs actually get fixed and whose defaults are the surprising part: touches run through a cooperative 150ms delay since 1.7.0 (so a full-screen map feels laggy and fights the scroll until `interactionMode = NonCooperative`), `isNativeAccessibilityEnabled` is off (so VoiceOver skipping a native view is a property, not a semantics bug), and `placedAsOverlay` is what a transparent native layer needs.

  **The `compose.*` Gradle aliases are deprecated** from 1.10.0-beta01, so `implementation(compose.material3)` is exactly the muscle memory that now writes deprecated code. The skill asks for direct Maven coordinates and notes the BOM is planned, not shipped.

  **Navigation 3** (CMP 1.10+) is now covered alongside `navigation-compose`, including the leak that has nothing warning about it: without `entryDecorators`, ViewModels stay scoped to the Activity instead of the destination.

  Also added: the `ComposeUIViewController(configure = { ... })` knob table (`opaque`, `onFocusBehavior`, `enforceStrictPlistSanityCheck`, `parallelRendering`), concurrent rendering going default-on in 1.11.0, `compose.resources` Gradle knobs (`nameOfResClass`, `customDirectory`), `PlatformImeOptions` for iOS keyboard traits, a version anchor in the body, and explicit routing to `kmp-module-setup` / `kmp-ios-integration` / `kmp-boundaries` for anything build-shaped.

  Four errors the skill had been carrying, caught by review and corrected against the docs:

  - The `composeResources` tree named `strings/` and `fonts/`, neither of which exists. The real directories are `values/` (holding `strings.xml`, with locale qualifiers as `values-es/`) and `font/`, singular. A misnamed directory generates nothing and reports nothing, so this was the most expensive kind of wrong.
  - `CADisableMinimumFrameDurationOnPhone` was described as causing a silent frame-rate cap when missing. Since 1.7.0 the check is strict and the app **crashes at startup**; the silent cap only survives behind `enforceStrictPlistSanityCheck = false`. The docs page went further and said "there's no crash or warning pointing at it", which was the exact opposite of current behaviour.
  - `accessibilitySyncOptions` was presented as a live `configure` knob. It was **removed in 1.8.0**, when the iOS accessibility tree became lazy and needs no configuration, so the snippet passing `AccessibilitySyncOptions.Always(...)` would not have compiled on the version the skill anchors to.
  - `interopProperties =` was offered as the older name for the `UIKitInteropProperties` parameter. It has been `properties =` since the API shipped in 1.7.0; `interopProperties` exists only as a typo in one JetBrains migration-doc snippet, so hedging between them taught an API that never existed.

  Smaller corrections in the same pass: Navigation 3 is no longer alpha off Android (stable 1.1.x as of 1.11), the Navigation 3 decorator coordinates now name the multiplatform artifacts rather than the Android-flavoured ones, `useSeparateRenderThreadWhenPossible` is marked as changelog prose rather than a real property, the `placedAsOverlay` snippet carries the `@OptIn` it needs to compile, the Kotlin floor notes the 2.1.0-vs-2.2 discrepancy between the compatibility page and the 1.10.0 release notes, and a leaked research note ("The assigned URL 404'd") is gone from the reference. The docs page also gained the `## Where it fits` section the template requires.

  Removed: `reference.md`'s CocoaPods section, which was a verbatim duplicate of `kmp-ios-integration/cocoapods-reference.md`. It is a pointer now, keeping only the two facts that change what Compose code can assume (iOS resources land outside `.lproj`, so `CFBundleLocalizations` does nothing to them; raw `pod install` drops them from the bundle where `./gradlew podInstall` does not).

## 1.7.0

### Minor Changes

- [#6](https://github.com/hugues-vnsgn/skills/pull/6) [`3e05621`](https://github.com/hugues-vnsgn/skills/commit/3e056212ec11f3541431c3b4db8f7383af970c67) Thanks [@hugues-vnsgn](https://github.com/hugues-vnsgn)! - Promote `unslop` out of `in-development/` into a new `house/writing/` domain, for prose a human reads (the counterpart to `writing-for-agents`, which covers documents an agent reads).

  The skill was rewritten around three gaps. It now sets a **register** (reference, argument, conversation) before editing, because the voice advice that saves an essay ruins a config doc. It holds back any edit that would change a claim, reporting the problem instead of smoothing it, along with code, quoted material, and terms of art the project actually uses. And the 31 flat rules are regrouped into ten sections ranked by yield, led by the tell no pattern can find: a sentence that says nothing.

  It also ships `scripts/check-tells.py`, a stdlib-only checker for the tells that are pattern matching rather than judgment. It masks code, links, and fenced blocks before matching, and splits results into `strict` (fix every hit) and `candidate` (the agent decides, because some of those words are the project's real vocabulary).

- [#5](https://github.com/hugues-vnsgn/skills/pull/5) [`7345fa1`](https://github.com/hugues-vnsgn/skills/commit/7345fa15d38abc216f14bf23ebdd4a1c699a6a31) Thanks [@hugues-vnsgn](https://github.com/hugues-vnsgn)! - Rewrite `show-me` around two gaps: it was anchored on TypeScript and it stopped at "understand".

  The eight notation forms were never language-bound (a structure tree describes a Compose screen, a SwiftUI body, or a Terraform module equally well), but three of them were written in TS/React and every example lived in the same imaginary TS monorepo, so the agent pattern-matched the examples and emitted JSX-shaped trees for code that was not JSX. Notation now defaults to pseudocode and plain trees, with real syntax licensed for exactly two cases: the user needs something copyable, or the syntax is itself the point.

  The skill also gained the second half its name implies. **Compress** cuts every element the current question does not need, replacing the old "don't overwhelm the user" (a negation, which makes the unwanted behaviour more available, not less) with a checkable bar. **Collapse** then reads the picture back, because complexity is often only visible once drawn: five named shapes (hub, repeat, pass-through, round trip, fan-out on load) tell the agent what to look for, and when one appears it draws the smaller shape beside the current one. It draws only, handing off to `codebase-design`, `improve-codebase-architecture`, and `when-stuck`, and it says so plainly when the picture is already clean rather than inventing a smell to have something to collapse.

  Two smaller fixes: a question-to-form table replaces the flat list of eight peers, so picking a form is no longer a coin flip; and the HTML branch no longer assumes a web product, so it still works for a CLI, a library, or a native app with no web surface.

- [#7](https://github.com/hugues-vnsgn/skills/pull/7) [`28f950f`](https://github.com/hugues-vnsgn/skills/commit/28f950f9326f51ab5b7a6bd9352bb45c25a3d278) Thanks [@hugues-vnsgn](https://github.com/hugues-vnsgn)! - Rebuild `use-git-worktree` around the maintainer's actual habit, register it, and fix two bugs the old version shipped.

  The skill had drifted from how the worktree gets made in practice. It ordered native harness tools ahead of plain git, which reads sensibly but meant the documented `.worktrees/` fallback was dead code in Claude Code: `EnterWorktree` always won and always landed in `.claude/worktrees/`. The recipe now runs the other way. `git worktree add .worktrees/<branch>` creates the worktree, then `EnterWorktree` is called with `path:` to move the session into it, which keeps the `.worktrees/` layout while still letting later tool calls read and write the worktree rather than the main checkout. Branch names are `feat/<slug>` and `fix/<slug>`, matching the fork's conventional-commit subjects, and the worktree path mirrors the branch.

  Two guards were quietly broken, both found by running the commands rather than reading them:

  - `git check-ignore -q .worktrees` reports "not ignored" whenever the directory does not exist yet, because a directory-only pattern cannot match a path git has not seen on disk. On a fresh repo the guard therefore appended `.worktrees/` to `.gitignore` on every single invocation. Querying `.worktrees/` with the trailing slash matches under every pattern style, present directory or not.
  - Appending the rule with a bare `echo` corrupts a `.gitignore` that ends without a newline, fusing the two lines into `node_modules.worktrees/`. The `printf` now leads with a newline.

  The submodule guard was wrong rather than merely redundant: it claimed the git dir and the common git dir differ inside a submodule, and they are identical, because submodules do not use the worktree mechanism at all. So a submodule never tripped the test the guard existed to disambiguate, and the guard was dead code justified by a false premise. Detection is now the one comparison that is actually true (`--git-dir` against `--git-common-dir`), which classifies a submodule as a plain checkout and a worktree _of_ a submodule as a worktree, both correct, and folds four `rev-parse` calls into one.

  That call carries `--path-format=absolute`, which is load-bearing rather than tidy. Git answers `--git-common-dir` relative to the cwd, so from a subdirectory an unnormalised comparison sees `/repo/.git` against `../../.git`: one directory, two spellings, which a string test calls a worktree. The skill would then announce "already isolated" from any subdirectory and create nothing. The previous version normalised with `cd "$(git rev-parse --git-dir)" && pwd -P`; dropping that as a token saving reintroduced the bug, and the flag is the cheap way to keep it fixed.

  `git worktree add` now names its base ref explicitly. Without one git branches from the main checkout's current `HEAD`, and this skill's entire premise is that the checkout was left parked wherever the user had it, so a new feature branch silently forks from whatever stale work was checked out. Verified: with `HEAD` on an unrelated branch, the new worktree inherited that branch's files.

  Scope shrank to match the recipe, which stops at a ready workspace. Dependency install and the baseline test suite are gone: they were the bulk of the skill's cost, they ran a full install and a full suite on every worktree however small the task, and a dirty baseline is the next step's problem to report. `SKILL.md` is 78 lines against 167, and the detection phase is one shell call against five.

  The description gained a size floor and a stand-down clause. It fires on features, fixes, refactors, upgrades, and plans that span more than one file, and explicitly stands down for one-line edits and for a user who says to work on the current branch. Without those, "picks up a bug fix" claimed a worktree, a branch, and a permanent `.gitignore` edit for fixing a typo in a README. Refactors and upgrades now map to `feat/` by an explicit rule, so the agent stops improvising a third prefix.

  Registration was missing entirely, which is why none of this was reachable: the skill had no `.fork/catalog.yaml` entry, no line in the `in-development` bucket README, no `agents/openai.yaml`, and no `metadata.internal: true`. All four are in place, `status: beta`, so it stays out of the installer picker, the top-level README, `docs/`, and `ask-matt` until it is promoted.

### Patch Changes

- [#8](https://github.com/hugues-vnsgn/skills/pull/8) [`84b5ee5`](https://github.com/hugues-vnsgn/skills/commit/84b5ee5afd738b6a3484e62509b84b3b573c5be3) Thanks [@hugues-vnsgn](https://github.com/hugues-vnsgn)! - Add the `implement-spec` skill (in-progress bucket, user-invoked). It takes a spec and its tickets and drives them to a single PR: the tickets are read as a task graph with blocking edges, so implementer subagents run in background worktrees across the ready frontier for concurrency, a merger subagent folds each one back into the PR branch, and the flow closes with `/code-review` before the PR is marked ready.

- [#7](https://github.com/hugues-vnsgn/skills/pull/7) [`28f950f`](https://github.com/hugues-vnsgn/skills/commit/28f950f9326f51ab5b7a6bd9352bb45c25a3d278) Thanks [@hugues-vnsgn](https://github.com/hugues-vnsgn)! - Teach `forkcheck` and `skillcheck` to skip nested worktrees, found by smoke testing `use-git-worktree` against this repo.

  Creating `.worktrees/feat/<slug>` put a full checkout of `main` inside the repo, and three repo-wide assertions walk the tree with `os.walk` rather than asking git what is tracked. They found every file twice and reported the copy against the original: `plugin-dir-marketplace-only` flagged the worktree's own root `.claude-plugin/` as a forbidden second plugin directory, while `no-stale-repo-coordinates` and `no-stale-tree-name` flagged the `.scratch/` records and `CHANGELOG.md` entries that legitimately exist at that commit. Four checks failed across the two scripts, `test_forkcheck.sh` dropped to 23/26, and none of it was real drift.

  `skillcheck.py` gains a `WALK_SKIP_DIRS` constant shared by both of its walks, and `.worktrees/` joins `COORDINATE_SKIP`. `forkcheck.py`'s plugin walk gains the same two entries. Both now also skip `.claude/`, which is where a harness puts a worktree when it picks the location itself: `skillcheck`'s comment already claimed "a second working tree" was never scanned, and that was true only of the coordinate walk, not the plugin walk beside it.

  The wider skip list does not soften the guards. A stray `.claude-plugin/` planted at `docs/.claude-plugin/` and a pre-rename tree reference planted at `docs/stray-probe.md` are both still caught, and both scripts return to PASS once removed. Writing that second probe out longhand here would trip `no-stale-tree-name` on this very file, which is its own small proof the guard reaches changeset prose.

- [#6](https://github.com/hugues-vnsgn/skills/pull/6) [`3e05621`](https://github.com/hugues-vnsgn/skills/commit/3e056212ec11f3541431c3b4db8f7383af970c67) Thanks [@hugues-vnsgn](https://github.com/hugues-vnsgn)! - Reconcile `unslop`'s em-dash rule with the one in `CLAUDE.md`. The skill said parentheses only trade one tell for another; the repo rule lists parentheses as a legitimate rewrite. Both were defensible in isolation and contradicted each other in the same repo, with the skill being the copy an agent actually reads.

  The rule now names what the sentence can actually want (period, semicolon, comma, colon, or the conjunction the dash was hiding) and locates the real tell in mechanical substitution rather than in any one mark. A parenthesis earns its place around a genuine aside; it fails when it is dropped in wherever the dash sat, because the sentence keeps the dash's shape. The checker's fix hint says the same thing.

  Wording drawn from doing this 682 times by hand across the fork's own prose.

- [#6](https://github.com/hugues-vnsgn/skills/pull/6) [`3e05621`](https://github.com/hugues-vnsgn/skills/commit/3e056212ec11f3541431c3b4db8f7383af970c67) Thanks [@hugues-vnsgn](https://github.com/hugues-vnsgn)! - Remove every em dash from fork-owned prose, closing the rule `CLAUDE.md` has stated since upstream's 2026-08-20 sync without anything enforcing it. 682 occurrences across 57 files, rewritten rather than substituted: a colon where a list or definition follows, a semicolon between independent clauses, a comma for an appositive, a period where the clause was really a second sentence, and a conjunction where the dash was hiding the logical connective.

  Three things changed beyond punctuation. The `⚠ TBD` marker `to-prd` writes into a PRD is now `⚠ TBD: <who decides>` in both the skill and its docs page, so the two still agree. `CUSTOMIZING.md` no longer claims the promoted house domains are mobile and platform, which stopped being true when delivery, discovery, quality and writing landed. Empty Sync note cells in `.fork/divergence.md` read `None` instead of a bare dash.

  Seven skill descriptions were rewritten. Four are unquoted YAML scalars where a colon-space would have made the front matter invalid and dropped the skill from skills.sh discovery silently, which is the same failure a changeset already fixed once before; each was parsed to confirm.

  Upstream territory is untouched: the three en dashes in `docs/engineering/diagnosing-bugs.md` are upstream's own bytes and stay as they are.

- [#6](https://github.com/hugues-vnsgn/skills/pull/6) [`3e05621`](https://github.com/hugues-vnsgn/skills/commit/3e056212ec11f3541431c3b4db8f7383af970c67) Thanks [@hugues-vnsgn](https://github.com/hugues-vnsgn)! - Rework `unslop` against its own eval results. The body loses a quarter of its words, the claim rule gains a third move, and the register set gains a fourth entry.

  Splitting the tell list follows the seam the skill already had. Everything `check-tells.py` matches now lives in `references/tells.md` and is reprinted with its fix in the checker's own output, so `SKILL.md` carries only the tells that need a person's judgment. That is what a skill body costs: it rides along on every turn once the skill fires, so the half a regex can do for you does not belong in it.

  The claim rule used to have two settings, leave it or cut it, and both produce a thinner page than the one the author wanted. It now has three, and the new one is to write the missing explanation and mark it in place as the skill's own inference, so the reader gets the mechanism and the author can confirm or delete it in one keystroke. What stays banned is the quiet version, where a claim changes and nobody is told.

  A commit body moves from Reference to Argument, because it argues that this was the right fix rather than reporting what moved. A new Instruction register covers documents an agent reads, which makes the `writing-for-agents` relationship a layering rather than a handoff: that skill owns the structure, this one owns the prose inside it.

  Also: the description carries non-triggers so the skill stops firing on chat replies and one-line commit subjects, `surface` joins `harness` and `primitive` as a checker candidate so the leave-alone examples are actually enforced, quoting rules now say the source's words are untouchable while the marks around them are yours, and `evacuate` returns to the abstract-noun list it fell out of.

## 1.6.1

### Patch Changes

- [#2](https://github.com/hugues-vnsgn/skills/pull/2) [`7864fb9`](https://github.com/hugues-vnsgn/skills/commit/7864fb92fe83f111bced78892ab8b4805ad92838) Thanks [@hugues-vnsgn](https://github.com/hugues-vnsgn)! - Move the repo from the `osxsystem` GitHub account to `hugues-vnsgn`, and rewrite every reference that is a _coordinate_ rather than an identity or a record.

  **Install commands change.** The canonical whole-set and single-skill commands now read `npx skills@latest add hugues-vnsgn/skills`, and the skills.sh URL follows. Anyone who installed from the old address should re-add from the new one; the old repository is being retired, so no redirect covers it.

  **What deliberately did not change.** The package is still named `osxsystem-skills`, its description still says "osxsystem team", and the published `setup-osxsystem-skills` skill keeps its name. An account move is not a rebrand, and renaming a published skill would cost every consumer a reinstall. Searching the repo for the old account name therefore still returns well over a hundred hits, and that is correct.

  **Changelog links.** The three link classes in `CHANGELOG.md` did not have the same right answer. The 19 commit links were repointed to the new address, where they resolve, because every commit was carried over. The 14 pull-request links were de-linked to plain `#N` text, because those pull requests exist at neither address and each already sits beside a commit link that does resolve. The 4 issue links turned out to reference upstream issue numbers that never existed in this repo, so they were repointed at `mattpocock/skills`, fixing links that were broken before this change.

  **New guard.** `skillcheck.py` gains `no-stale-repo-coordinates`, which asserts the old account appears only inside a recorded allowlist, and `coordinate-scan-readable`, which fails closed when a file cannot be read. `scripts/harness/test_coordinates.sh` proves both, including that a stale string inside the allowlist still passes. The distinction between a coordinate and an identity string is now executable rather than remembered.

  **CI gap closed.** `scripts/generate-catalog.py --check` has always existed but was never called by the workflow, so a stale `CATALOG.md` drifted silently. It now runs alongside the installer-manifest check. This change is what surfaced it: rewriting 53 `owner:` fields in the catalog source left the generated catalog stale with nothing to catch it.

## 1.6.0

### Minor Changes

- [`36c463a`](https://github.com/hugues-vnsgn/skills/commit/36c463abffbaa2150a76696d4896b8e3dd9a5f13) Thanks [@osxsystem](https://github.com/osxsystem)! - Add `to-prd` and open the `discovery` team domain.

  **Skills**

  - New skill `to-prd` (`skills/team/discovery/`) — turn the current conversation into a Product Requirements Document. Synthesis first: it drafts every section it can defend from what was already discussed, asks one batched round of questions only for the decisions no agent can make (Key Result targets, contacts, the release cut), and marks deferred decisions `⚠ TBD` instead of inventing them. Unripe ideas are refused and routed to `grill-with-docs`. Adapted from the ecosystem's `create-prd` (phuryn/pm-skills) into this repo's synthesis idiom. Smoke-tested in isolation on both paths: rich post-grilling context (full PRD, zero invented numbers) and a two-line idea (refusal with routing).
  - `discovery` is the first skill's landing that opens the reserved domain folder — bucket README, top-level README section, docs page, and analyst/staff role-page entries all added.

  **Flow**

  - `ask-matt`'s main flow gains a step: `grill-with-docs → to-prd (initiative-scale only) → to-spec → to-tickets → implement`. A single well-scoped feature skips the PRD step.

### Patch Changes

- #25 [`6747567`](https://github.com/hugues-vnsgn/skills/commit/6747567b75b54446c0ebff510b8632d0445f9257) Thanks [@osxsystem](https://github.com/osxsystem)! - Add `sync-upstream`, a maintainer skill that drives an upstream merge. It defers to `.fork/sync-playbook.md` for the steps and carries what the playbook cannot: how to read the delta, how to classify a conflict before resolving it, how to handle a repo-wide style sweep, and the failures that look like breakage and are not. Beta, and marked internal so the installer does not offer a skill that only works in this repo.

- #24 [`4f28947`](https://github.com/hugues-vnsgn/skills/commit/4f289474bad013fe2be8f8769d733f59d9103d6b) Thanks [@osxsystem](https://github.com/osxsystem)! - Quote the `description` front matter in `to-spec`, `code-review`, `setup-matt-pocock-skills`, `writing-fragments`, `writing-shape`, and `wait-what`. An unquoted colon-space left over from the em-dash sweep in [#905](https://github.com/mattpocock/skills/issues/905) made each block invalid YAML, so `skills.sh` skipped all six during discovery and they couldn't be listed or installed via `npx skills`.

- #24 [`85f83d3`](https://github.com/hugues-vnsgn/skills/commit/85f83d3fde1d3a90d5c9a657f6998c79a6c37308) Thanks [@osxsystem](https://github.com/osxsystem)! - grilling: update the round template so consecutive questions are separated by a horizontal rule (`---`) instead of running together.

- #24 [`e6e9577`](https://github.com/hugues-vnsgn/skills/commit/e6e957797d8cceb5b351c0dc840369523f9fb8fb) Thanks [@osxsystem](https://github.com/osxsystem)! - Remove every em-dash from the repo's prose (docs, `SKILL.md` files, ADRs, `README.md`, scripts, JSON/YAML metadata), hand-rewriting each sentence with a comma, colon, period, parentheses, or conjunction rather than mechanically substituting the character. `CLAUDE.md`/`AGENTS.md` now says not to reintroduce them.

- #24 [`594f0f8`](https://github.com/hugues-vnsgn/skills/commit/594f0f83188921a60d45d63d6cdac509de20df2c) Thanks [@osxsystem](https://github.com/osxsystem)! - wait-what: follow `CONTEXT-MAP.md` to the right `CONTEXT.md` when a repo indexes multiple contexts that way instead of keeping a single root `CONTEXT.md`.

## 1.5.0

### Minor Changes

- #21 [`e48c68d`](https://github.com/hugues-vnsgn/skills/commit/e48c68dc093f4458b384ab8e7b4ac5757384edfb) Thanks [@osxsystem](https://github.com/osxsystem)! - Tidy the mobile domain and make the fork record self-checking.

  **Skills**

  - Retired `kotlin-multiplatform`. It was transplanted from another codebase and never adapted, and its central guidance had gone stale: it routed to `expect`/`actual` by default, which JetBrains now advise against for classes. Its one sound section — the custom intermediate source set for sharing across a target subset — moved into `kmp-boundaries`.
  - `kmp-boundaries` gains that section, plus the `expect`/`actual`-classes-are-Beta caveat and the functions-vs-classes distinction. Fixed `skikoMain` (not a real source set) and a pointer to a `references/ios-interop.md` that never existed.
  - `kmp-ktor` no longer points at skills outside this repo, and defines the error type it tells you to map to.
  - Six skills registered as `status: beta`: `kmp-boundaries`, `kmp-ktor`, `herdr`, `bro`, `improve-claude-md`, `show-me`.

  **Harness**

  - New `forkcheck` assertion `declared-trees-exist`: a row in `divergence.md`'s Additions table can no longer outlive the tree it describes. Paths marked `(planned)` are exempt so a tree can still be forward-declared.

## 1.4.0

### Minor Changes

- #17 [`a1e7cdf`](https://github.com/hugues-vnsgn/skills/commit/a1e7cdfc2f4bc78993ff22bd4e7aefdd5577bf0f) Thanks [@osxsystem](https://github.com/osxsystem)! - Group the installer's skill picker by domain, with a select-all per group.

  `npx skills@latest add osxsystem/skills` previously listed all 45 skills flat, one keystroke per skill. It now renders six collapsible groups — Engineering, Productivity, Team Delivery, Team Mobile, Team Platform, Team Quality — each with a header row that selects everything under it. Upstream's `misc/` and `in-progress/` skills stay installable under the picker's own "Other" heading.

  The installer derives groups from `.claude-plugin/marketplace.json` and nothing else, so this fork now generates that one file from `.fork/catalog.yaml` (`python3 scripts/generate-marketplace.py`, gated by `--check` in CI). It is picker metadata, not an install route: `plugin.json` stays deleted, skills.sh remains the only documented way in, and the `plugin-dir-marketplace-only` guard fails the build if a sync brings the rest of the directory back.

  `CLAUDE.md` gains the convention that a skill this fork does not ship carries `metadata.internal: true`, which keeps it out of the picker while `--skill=<name>` still installs it.

  Known trade-off: the installer disables type-to-filter search whenever groups are present, and opens them expanded. Both are upstream behaviours in [vercel-labs/skills](https://github.com/vercel-labs/skills); a fix is being sent there separately.

## 1.3.0

### Minor Changes

- #7 [`f1c4af3`](https://github.com/hugues-vnsgn/skills/commit/f1c4af306bc7da1d231dc65f83384b54df6d0764) Thanks [@osxsystem](https://github.com/osxsystem)! - Restructure the tree by provenance: every fork-authored skill now lives under
  `skills/team/`, grouped by capability domain.

  **No skill was renamed.** `/kmp-module-setup`, `/port-from-repo`,
  `/setup-osxsystem-skills` and the rest answer to exactly the same names as
  before — only their directories moved, so invocation is unchanged. Re-run
  `scripts/link-skills.sh` to relink from the new paths.

  - **`skills/team/mobile/`** — the four Kotlin Multiplatform / Compose
    Multiplatform skills, from `skills/mobile/`.
  - **`skills/team/platform/`** — `setup-osxsystem-skills` (from
    `skills/engineering/`), `port-from-repo` (from `skills/engineering/`), and
    `when-stuck` (from `skills/in-progress/`, still beta).

  Upstream's buckets (`engineering/`, `productivity/`, `misc/`, `in-progress/`,
  `deprecated/`) are now byte-frozen vendor territory, so an upstream sync is a
  merge plus assertions rather than an act of curation.

  **New skill:** `kmp-test-seams` (model-invoked) — which source set a test
  belongs in and which Gradle task proves a slice green. It was the KMP section
  appended to upstream's `tdd` skill; extracting it restores `tdd` verbatim and
  retires a guaranteed merge conflict. `ask-matt` routes to it under the
  platform-knowledge layer.

  **Fork control plane** — `.fork/` holds the per-skill sidecar taxonomy
  (`catalog.yaml`: origin, domain, audience, owner), the last-synced upstream SHA
  (`upstream.lock`), the divergence record with a resolution recipe per entry, the
  sanctioned-edits list CI consumes, and the sync playbook. `CATALOG.md` at the
  repo root is generated from the catalog and must never be hand-edited.

  **CI guard** — `scripts/harness/forkcheck.py` joins the validate job and fails
  the build on four invariants: upstream paths drifting from `upstream/main`
  outside the sanctioned list, two skills sharing a directory basename anywhere in
  the tree, a catalog that doesn't match the skills on disk, and the reappearance
  of the `.claude-plugin/` directory this fork deleted.

  **Ownership and discovery** — `CODEOWNERS` maps one line per team domain plus a
  maintainers line over vendor territory and the control plane, and `docs/roles/`
  adds an entry page per audience (engineer, designer, analyst, qa, staff) giving
  each discipline a curated reading order instead of a folder taxonomy to learn.

### Patch Changes

- #2 [`4810a38`](https://github.com/hugues-vnsgn/skills/commit/4810a3810442760fe8e9135f451c91252426af28) Thanks [@osxsystem](https://github.com/osxsystem)! - `ask-matt` now routes to the mobile bucket.

  The router mapped every promoted skill except the four Kotlin Multiplatform /
  Compose Multiplatform ones, which have shipped in `skills/mobile/` since the
  fork added the bucket. They now appear as a **Platform knowledge** layer that
  runs beneath the main flow, alongside the existing vocabulary layer.

  No skill behaviour changes — this is the map catching up with the repo.

- [#848](https://github.com/mattpocock/skills/pull/848) [`f02e2ed`](https://github.com/hugues-vnsgn/skills/commit/f02e2ed3624d031272f8547742d23bf6bca8b072) Thanks [@mattpocock](https://github.com/mattpocock)! - domain-modeling: trigger on discussing codebase terminology and on writing or editing a CONTEXT.md or an ADR directly, replacing the narrower "pin down domain terminology or a ubiquitous language" / "record an architectural decision" phrasing. Also drops the "another skill needs to maintain the domain model" caveat — that's the invoking skill's job to state explicitly, not this description's.

- [#879](https://github.com/mattpocock/skills/pull/879) [`d419977`](https://github.com/hugues-vnsgn/skills/commit/d419977fe07d9e1607d3523f3579310bbb076b93) Thanks [@mattpocock](https://github.com/mattpocock)! - grilling: remove em-dashes from `SKILL.md`, replacing them with colons and semicolons so the instructions read as plain text.

- #4 [`ffd206a`](https://github.com/hugues-vnsgn/skills/commit/ffd206ac0814767690a5f7bb249d6e24161a1239) Thanks [@osxsystem](https://github.com/osxsystem)! - Fix two bugs in `git-guardrails-claude-code`'s hook script, and add the missing
  `## Common questions` section to five docs pages.

  **The guardrail no longer blocks commands that merely mention a dangerous one.**
  Patterns were matched anywhere in the command string, so `git pushd /tmp`,
  `git commit -m "docs: explain git push safety"`, and `grep -r "git push" docs/`
  were all blocked. Patterns are now anchored to the start of each command
  segment, so a mention runs and an invocation still blocks.

  **The guardrail now fails closed.** Previously, unparseable hook input made `jq`
  error, left the command string empty, matched nothing, and exited `0` — allowing
  the command. A missing `jq` did the same. Both now block (exit 2). If you relied
  on the old behaviour to slip commands past the hook, they will now be refused.

  Dangerous commands are still caught when they are not the leading command in a
  chain (`cd foo && git push`), behind an env-var prefix, or via `git -C <path>`.

  Also in this release: `docs/mobile/*` (all four) and
  `docs/productivity/wait-what.md` gained the `## Common questions` section
  required by `.agents/writing-docs.md`, and the stale claim in `CLAUDE.md` and
  `.agents/writing-docs.md` that only `engineering/` and `productivity/` are
  promoted now names `mobile/` too.

- #2 [`297de67`](https://github.com/hugues-vnsgn/skills/commit/297de67ce52a8824828a191c4216423d15d6622c) Thanks [@osxsystem](https://github.com/osxsystem)! - The four `skills/mobile/` skills now carry the `agents/openai.yaml` that
  `.agents/invocation.md` requires of every skill. They stay model-invoked, so
  the files hold Codex UI metadata only and no `policy` block.

- #1 [`03c7993`](https://github.com/hugues-vnsgn/skills/commit/03c7993928c03a963a2a46e1e33b42b35ceb54c4) Thanks [@osxsystem](https://github.com/osxsystem)! - Rename `setup-matt-pocock-skills` to `setup-osxsystem-skills`.

  The skill's behaviour is unchanged — only its name, directory, and docs page
  move. Run `/setup-osxsystem-skills` instead of the old command.

  **If you installed a previous version,** the old skill is still linked under its
  old name and will surface a broken slash command. Remove it:

  ```bash
  rm -f ~/.claude/skills/setup-matt-pocock-skills \
        ~/.agents/skills/setup-matt-pocock-skills
  ```

  Also in this release: `package.json` now identifies this fork rather than
  upstream, and `scripts/sync-plugin-version.mjs` is deleted. That script synced a
  `.claude-plugin/plugin.json` this fork does not ship, and its failure was
  breaking the release workflow.

- #6 [`bfb933b`](https://github.com/hugues-vnsgn/skills/commit/bfb933bb7d45153f1c0198f2fa432f63216331b4) Thanks [@osxsystem](https://github.com/osxsystem)! - Two new skills, from a second pass over ClaudeKit's catalogue.

  `port-from-repo` (engineering, user-invoked) brings a capability across from
  another codebase without bringing its architecture with it — understand,
  challenge, adapt, verify. It delegates four of those phases to skills this repo
  already owns, so it stays small: `/grilling` for the challenge, `/codebase-design`
  for the seam, `/tdd` for the build, `/code-review` for close-out.

  `when-stuck` (in-progress, model-invoked) collects five techniques for
  design-level stuck-ness — inversion, the scale game, simplification cascades,
  meta-patterns, collision — scoped away from bugs and undecided plans so it
  doesn't compete with `/diagnosing-bugs` or `/grilling`.

  `ask-matt` gains an on-ramp for `port-from-repo`, and its opening line stops
  claiming a fixed number of on-ramps now that there are four.

- [#878](https://github.com/mattpocock/skills/pull/878) [`e3e547b`](https://github.com/hugues-vnsgn/skills/commit/e3e547b57d549110a0aa6ff40fd7b871c01c76c9) Thanks [@mattpocock](https://github.com/mattpocock)! - Standardize cross-skill invocation on an explicit "call the Skill tool" instruction instead of bare `/skill`-style prose, across `code-review`, `diagnosing-bugs`, `grill-with-docs`, `grill-me`, `improve-codebase-architecture`, `tdd`, `to-spec`, `to-tickets`, `triage`, and `wayfinder`.

  - A skill that names another skill in prose ("run the `/grilling` skill") does not reliably cause it to load — this is the documented rough edge behind `grill-with-docs`'s most-reported problem. Naming the tool directly (`Call the Skill tool with "grilling"`) is intended to raise the hit rate. Dropping the leading `/` also makes the instruction harness-neutral rather than less: it no longer assumes Claude Code's trigger syntax.
  - A step needing more than one skill now says so as multiple calls ("Call the Skill tool twice, for `grilling` and `domain-modeling`"), not one call carrying two names.
  - Documents the convention in `.agents/invocation.md` for future skills to follow.

- #5 [`ffd4a94`](https://github.com/hugues-vnsgn/skills/commit/ffd4a94eb6e1d8eae8644a682bf6ee4bebc5b9ef) Thanks [@osxsystem](https://github.com/osxsystem)! - Skill validation now runs in CI.

  The structural validator that checks this repo's own invariants — bucket-README
  membership and grouping, docs-page sections, invocation-mode consistency across
  `SKILL.md` and `agents/openai.yaml`, link resolution, `ask-matt` routing
  freshness, the verbatim install block — has moved into `scripts/harness/` and
  runs on every pull request. A new `scripts/check-confusable-skills.py` fails
  when two model-invoked skill descriptions overlap enough to compete for the
  same trigger.

  No skill behaviour changes. The rules were already written down in `CLAUDE.md`;
  now something checks them.

- [#880](https://github.com/mattpocock/skills/pull/880) [`1dab982`](https://github.com/hugues-vnsgn/skills/commit/1dab98299c3b81f560026c01b7ebf55ed5d91373) Thanks [@mattpocock](https://github.com/mattpocock)! - Stop skills from trying to reach user-invoked skills through the Skill tool — fix cross-skill references that violated the "no other skill can call it" invariant in `.agents/invocation.md`, in `to-spec`, `wayfinder`, `to-tickets`, `triage`, `code-review`, and `diagnosing-bugs`.

  - `to-spec`, `wayfinder`, `to-tickets`, `triage`, and `code-review` each carried a precondition ("...run `/setup-matt-pocock-skills` if not") that PR [#878](https://github.com/mattpocock/skills/issues/878) rewrote into a literal `Call the Skill tool with "setup-matt-pocock-skills"` instruction. `setup-matt-pocock-skills` is user-invoked, so none of these skills — user-invoked or model-invoked — can call it. Reworded all five as instructions for the agent to tell the human to run it instead.
  - `diagnosing-bugs`'s Phase 6 post-mortem hand off to `improve-codebase-architecture` (also user-invoked) the same way, from an autonomous, often-unattended bug-fixing flow with no human in the loop to catch the failed call. Removed the hand-off outright rather than softening it — it rarely fired in practice. Phase 6 is now "Cleanup" only; the mechanical checklist is untouched.
  - Added a carve-out paragraph to `.agents/invocation.md`'s "Dependencies between them" section: the `Call the Skill tool with "name"` convention only applies when the named skill is model-invoked. This is the section PR [#878](https://github.com/mattpocock/skills/issues/878) introduced without reconciling it against the user-invoked/model-invoked invariant stated eight lines above it — the gap is most of why this bug reached six call sites instead of one.

  Fixes [#453](https://github.com/mattpocock/skills/issues/453).

## 1.2.3

### Patch Changes

- [#779](https://github.com/mattpocock/skills/pull/779) [`efce423`](https://github.com/mattpocock/skills/commit/efce423018fc6468a3239621f1c1bcaacc723801) Thanks [@mattpocock](https://github.com/mattpocock)! - Make `diagnosing-bugs` redact secrets.

  - Add a **Redact** section to `SKILL.md`. The skill has the agent show commands, outputs and captured artifacts; the section makes redaction the first move on each — write `<REDACTED>`, build loops against env vars so the credential stays in the environment, and quote only the signal-carrying lines of a captured artifact.
  - The Phase 1 completion criterion said "paste the invocation and its output". It now says show it redacted, and Phase 1 asks the user for a **redacted** captured artifact.
  - Note in `scripts/hitl-loop.template.sh` that `capture` prints its value back to the terminal, so it takes observations while signing in stays a `step`.

- [#781](https://github.com/mattpocock/skills/pull/781) [`14bfbbd`](https://github.com/mattpocock/skills/commit/14bfbbd8654a8d2910299e1a004c19c1979687d8) Thanks [@mattpocock](https://github.com/mattpocock)! - Drop Claude Code's tool and agent-type names from the subagent-dispatch instructions in `code-review`, `codebase-design`, and `improve-codebase-architecture`, so the step is followable on Codex and other harnesses.

- [#783](https://github.com/mattpocock/skills/pull/783) [`c0fd1e9`](https://github.com/mattpocock/skills/commit/c0fd1e973e040347d424e09934099f1bd6c2dee0) Thanks [@mattpocock](https://github.com/mattpocock)! - wizard: remove the time estimate. The template drops `TOTAL_MINUTES` and the time-remaining display, `stage` takes a name only, and progress is counted in stages.

## 1.2.2

### Patch Changes

- [#766](https://github.com/mattpocock/skills/pull/766) [`4aaccb5`](https://github.com/mattpocock/skills/commit/4aaccb58d40559d7e3c59a029b2290ae5ba538de) Thanks [@mattpocock](https://github.com/mattpocock)! - Make `writing-for-agents` model-invokable in Codex again.

  - Drop `policy.allow_implicit_invocation: false` from `agents/openai.yaml`. Codex filtered the skill out of the model-visible skills list, so its description could not trigger it — only an explicit `$writing-for-agents` mention worked.
  - Update the stale `interface.display_name` and `interface.short_description`, which still named the old `writing-great-skills` skill.
  - Move the skill from the **User-invoked** list to the **Model-invoked** list in `README.md` and `skills/productivity/README.md`.

## 1.2.0

### Minor Changes

- [#551](https://github.com/mattpocock/skills/pull/551) [`697d4ce`](https://github.com/mattpocock/skills/commit/697d4ce9742da558fd1ba6697c8e9775e2e302dd) Thanks [@mattpocock](https://github.com/mattpocock)! - Add Codex metadata alongside each skill's Claude Code frontmatter so the set works in both harnesses without generated copies.

  - Add an `agents/openai.yaml` beside every `SKILL.md` with Codex UI metadata (`interface.display_name`, `interface.short_description`).
  - Mark every user-invoked skill with `policy.allow_implicit_invocation: false`, the Codex analog of `disable-model-invocation: true`, so Codex excludes it from implicit invocation while explicit `$skill` invocation still works.
  - Document the dual-harness invocation model in `.agents/invocation.md`, `CLAUDE.md`, and the promoted-bucket READMEs.
  - Add `AGENTS.md` as a symlink to `CLAUDE.md` so Codex reads the same repo instructions.

- [#593](https://github.com/mattpocock/skills/pull/593) [`0f2bdbd`](https://github.com/mattpocock/skills/commit/0f2bdbdb06220d2df3718b8f0483157c6c8a8600) Thanks [@mattpocock](https://github.com/mattpocock)! - Graduate **`to-questionnaire`** out of `in-progress/` into the **Productivity** bucket, so it ships in the plugin. It turns a decision you can't answer alone into a Markdown questionnaire for the one person who can — filled in async, or worked through together in a meeting.

  Its defining move is that it grills you about the **send**, not the subject: a normal grilling session interrogates the topic, which is exactly what you can't answer here, so the interview asks only who the questionnaire is going to and what you need back, then aims every question at the gap between the two.

  Now wired as a promoted skill — plugin entry, top-level + Productivity READMEs under **User-invoked**, a docs page at `docs/productivity/to-questionnaire.md`, and a Standalone route in `ask-matt` framing it as the inverse of `/grill-me` (mine someone else, not yourself).

- [#680](https://github.com/mattpocock/skills/pull/680) [`b3376f8`](https://github.com/mattpocock/skills/commit/b3376f8d39848dd08572ec2667da4739a67c8c04) Thanks [@mattpocock](https://github.com/mattpocock)! - Graduate **`wizard`** out of `in-progress/` into the **Engineering** bucket, so it ships in the plugin — and make it model-invoked. It generates an interactive bash script that walks a human through a manual procedure — third-party setup, a one-off migration, an A→B state transition — opening each URL, saying what to click, capturing the values, and writing them into `.env` files and GitHub Actions secrets.

  The delightful UX is pre-solved by the bundled `template.sh` (progress with time-remaining, confirmation gates, cross-platform URL opening including WSL, hidden secret entry, idempotent `.env` upserts, `gh secret`/`gh variable` writes with graceful degradation, closing skip summary). Everything above the `STAGES` marker is a fixed library that's never hand-edited — the skill's job is only to scope the procedure and author its **stages**.

  Engineering rather than Productivity: it reads `.env*`, `docker-compose*`, framework config and every `secrets.*`/`vars.*` reference in `.github/workflows/` to scope itself, writes CI secrets, and verifies its output with `bash -n` and `shellcheck`.

  Because it is model-invoked, the agent can reach for it the moment it hits a step only a human can perform, instead of dumping numbered instructions into the chat and hoping you follow them. Typing `/wizard` works exactly as before — model-invocation only ever _adds_ the agent's reach. The description is written as the pointer that decides when it fires: what it produces, four trigger branches (provisioning infrastructure, setting up credentials or CI secrets, walking an unfamiliar third-party dashboard, a one-off migration or cutover), and an explicit non-trigger — don't invoke it for steps the agent can perform itself. Work an agent can do, an agent should do; the wizard is for the clicks, approvals and dashboard trips you would not hand to one. The stage-list confirmation before a line is written now doubles as the proposal when the agent fires it mid-build.

  Now wired as a promoted skill — plugin entry, top-level + Engineering READMEs under **Model-invoked**, a docs page at `docs/engineering/wizard.md`, and a Standalone route in `ask-matt` for the steps only a human can take. Model-invocation also puts it out of the reach of [#693](https://github.com/mattpocock/skills/issues/693), which drops user-invoked skills from the listing on Claude's desktop and web surfaces.

- [#763](https://github.com/mattpocock/skills/pull/763) [`77d207e`](https://github.com/mattpocock/skills/commit/77d207ef03219cc603e2832e1159cbdd1c91818e) Thanks [@mattpocock](https://github.com/mattpocock)! - Reshape the **`prototype`** skill around two ideas: the demo is **a single shareable HTML file**, and the prototype is **a primary source**.

  The logic branch now produces one self-contained file (plain HTML/CSS/JS, no build, no server) instead of a terminal app — a non-developer can open it by double-click and drive it in their own domain language: a labelled state panel, always-available free-play buttons, and a set of tabbed **guided walkthroughs**, each a scenario with the ordered buttons to press underneath it. The portable pure-logic module still lifts into the real code; the HTML shell is the throwaway.

  Throwaway no longer means deleted. Rather than being removed once it has answered its question, the prototype is captured as runnable evidence on a throwaway branch (`prototype/<name>`) out of main, with a context pointer to it left on the implementation issue — so the main branch keeps only the validated decision while the exploration stays findable. The answer (verdict + question) is still captured durably in an issue/ADR/commit.

- [#536](https://github.com/mattpocock/skills/pull/536) [`42a5b70`](https://github.com/mattpocock/skills/commit/42a5b70fcacc7baff1977b13f3919fb2f63af14e) Thanks [@mattpocock](https://github.com/mattpocock)! - Ship the skill set as a native **Claude Code plugin**, listed in Claude Code's official marketplace. You can now subscribe to the promoted skills as a managed, read-only bundle instead of copying editable files:

  ```bash
  claude plugins install mattpocock-skills
  ```

  Or, from inside a session:

  ```
  /plugin install mattpocock-skills
  ```

  There is no marketplace to add first — the official marketplace is configured by default.

  `.claude-plugin/plugin.json` carries the full plugin metadata (version, description, author, license, keywords) and the explicit list of promoted skills. `skills.sh` remains the universal installer (and the path for Codex and other harnesses today); a native Codex plugin is deferred — see `.agents/adr/0002-ship-as-a-claude-code-plugin.md` for why.

- [#751](https://github.com/mattpocock/skills/pull/751) [`355fa74`](https://github.com/mattpocock/skills/commit/355fa7420b418af838998f7ec4365ceda1c8dfcc) Thanks [@mattpocock](https://github.com/mattpocock)! - Add **`wait-what`** — a one-word corrective for model verbosity. Type it the moment a message doesn't land, and the agent re-pitches it: a little context, ASD-STE100 Simplified Technical English, and the ubiquitous language from your `CONTEXT.md`. User-invoked, three lines long.

  The mechanism is the name. Concision skills fail by growing — a 400-line skill still leaves the model verbose — so this one is a single precise leading word and nothing else. Names that describe the _output_ (`/tldr`, `/no-fluff`) make the model clip words and lose you further; naming the _listener's_ state asks for both halves at once, fewer words **and** the context you were missing. It also reuses the leading words already in your global `CLAUDE.md`, so the skill, `CLAUDE.md` and every `CONTEXT.md` reach for the same tokens.

  It repairs one message; it doesn't prevent the next one. The cure for jargon is a shared language built upfront with `/grill-with-docs`; this is what you reach for when you don't have one yet.

- [#763](https://github.com/mattpocock/skills/pull/763) [`77d207e`](https://github.com/mattpocock/skills/commit/77d207ef03219cc603e2832e1159cbdd1c91818e) Thanks [@mattpocock](https://github.com/mattpocock)! - Name the `/wayfinder` unit a **decision ticket**, and burn research tickets down with subagents.

  People kept reading a wayfinder ticket as an ordinary _implementation_ ticket — a slice of a build to execute — when wayfinder uses them as **decision tickets**: questions whose resolution is a decision. The skill description and its opening line now introduce the term (and say what makes it one), with the `ask-matt` / engineering README blurbs and the docs page matching — while "ticket" stays the everyday word once the term is established. `CONTEXT.md` records **Decision ticket** as a domain term, so the "avoid: ticket" guidance no longer contradicts wayfinder's deliberate use of the word.

  Research tickets are no longer parked for a separately-launched session. Research stays a real ticket type — it's a genuine shared blocker that downstream decisions hang on, and that dependency is exactly what the frontier's blocking edges exist to render. What changes is how it's resolved: because research is AFK, charting doesn't stop and read it. After creating the tickets, the charting session fires a `/research` subagent for each research ticket to burn it down in parallel, capturing the findings on a throwaway `research/<name>` branch with a context pointer. Research tickets are the one exception to _one ticket per session_.

- [#763](https://github.com/mattpocock/skills/pull/763) [`77d207e`](https://github.com/mattpocock/skills/commit/77d207ef03219cc603e2832e1159cbdd1c91818e) Thanks [@mattpocock](https://github.com/mattpocock)! - **Breaking:** rename **`writing-great-skills`** → **`writing-for-agents`**, restructure it, and add a new leading word.

  The reference now covers any document an agent consumes — skills, `AGENTS.md` / `CLAUDE.md`, docs reached by a pointer — not just skills. `GLOSSARY.md` is merged into `SKILL.md` (one authoritative treatment per term; the `_Avoid_` synonym lists and the standalone Predictability definition are gone); the skill-only mechanics (frontmatter, model- vs user-invoked, router skills, the invocation cut of splitting) are disclosed to a new `SKILL-MECHANICS.md`. The skill is now **model-invoked**: it fires when creating or editing skills or modifying `AGENTS.md`/`CLAUDE.md`. `ask-matt`'s pointer updated. Reinstall under the new name; the old name is gone (no alias).

  The pruning section gains **cache**. Single source of truth now reaches past the document into the environment — `package.json` scripts, config files, directory layout, `--help` output are themselves authoritative, so a doc that restates them is a cache of a lookup, earning its load only when the lookup is expensive. The positive target: cache what the agent cannot find by looking (unwritten conventions, the reason behind a choice, gotchas no config confesses), and leave one-file, one-command lookups to the environment, where they cannot go stale.

- [#533](https://github.com/mattpocock/skills/pull/533) [`45afd80`](https://github.com/mattpocock/skills/commit/45afd8074a8b7de5fe073845d080fa9dd6c429fa) Thanks [@mattpocock](https://github.com/mattpocock)! - Add a YAGNI scoping filter to the **`improve-codebase-architecture`** skill's Explore step. Instead of scanning the whole repo evenly, it now scopes to where change is actually landing: if you name a direction it takes it, otherwise it reads the last ~20 commit messages to bias exploration toward actively-developed paths. A deepening opportunity in code nobody touches is a refactor you'll never cash in — the leverage only pays off where you keep editing — so the report stops tidying dormant corners of the repo.

### Patch Changes

- [#763](https://github.com/mattpocock/skills/pull/763) [`77d207e`](https://github.com/mattpocock/skills/commit/77d207ef03219cc603e2832e1159cbdd1c91818e) Thanks [@mattpocock](https://github.com/mattpocock)! - Sharpen `/ask-matt` — the router now covers phase boundaries, the two wayfinder mistakes, and two skills it never mentioned.

  **Phase boundaries.** A **phase** is a chunk of work inside a session — the grilling, the implementation, the QA — and the boundary between two of them is where you decide what to do with the context you've built. The two-bullet `Crossing sessions` section is replaced by a decision tree carrying all five options in order (**continue**, `/clear`, `/handoff`, **subagent**, `/compact`), with the reasoning disclosed in a new `PHASE-BOUNDARIES.md`. Three fixes come with it:

  - **`/handoff` was oversold.** It read as the general bridge between context windows. It's narrow: you need it only when something has to _travel_ — a new harness, a new directory, a colleague, or a side task forked mid-phase. What it buys is portability.
  - **`/compact` is the default, not the first reach.** It sits at the bottom of the tree, after the four cheaper or more precise questions above it. Starting there produces a session that's confidently wrong about whatever the summary flattened.
  - **Two branches were missing entirely.** **Continue** is the one to rule out first — it's the only move that keeps the conversation as a primary source rather than a summary of one — and a **subagent** handles anything scoped tightly enough to run AFK.

  Context hygiene's escape hatch now says `/compact` rather than `/handoff` (same harness, same directory, at a boundary — the handoff clause doesn't apply), and the smart zone figure is updated from ~120k to ~150k tokens.

  **Wayfinder routing.** The two mistakes people most often make with the heaviest, most cognitively demanding flow:

  - **Over-reaching for it.** It's slower and denser than a single grill, so it's flagged as the heaviest flow and reserved for the idea that genuinely won't fit one session — a well-scoped feature belongs on `/grill-with-docs`, not here.
  - **Losing the way at the handoff.** When the map clears, wayfinder hands off, it doesn't build: merge onto the main flow at `/to-spec` (which collapses the map's linked decisions into a buildable plan) rather than looping the map straight into `/implement`. Straight-to-`/implement` is only for efforts that turned out genuinely small.

  **Missing routes.** `/grilling` and `/resolving-merge-conflicts` were absent from the router altogether and are now in it, and `grill-me` splits from `grill-with-docs` on whether you are in a working directory.

- [#502](https://github.com/mattpocock/skills/pull/502) [`44eed54`](https://github.com/mattpocock/skills/commit/44eed545186ffd0263e8004867750b80cfddd215) Thanks [@mattpocock](https://github.com/mattpocock)! - Make `/setup-matt-pocock-skills` friendlier and align the local-markdown tracker with the current spec.

  - **Triage labels** are now asked about only when the `triage` skill is installed, and then as a single recommended-yes question ("keep the default triage labels?") instead of an override interrogation. When `triage` isn't installed, the section — and `docs/agents/triage-labels.md` — are skipped.
  - **External PRs as a request surface** is no longer a setup question. The GitHub/GitLab templates still carry the flag, defaulted off; a user can flip it in `docs/agents/issue-tracker.md` later.
  - **Domain docs** default to single-context without asking; multi-context is only offered when the repo shows monorepo signals.
  - **Local-markdown tickets** are now one file per ticket under `.scratch/<feature>/issues/<NN>-<slug>.md` — never a single combined `tickets.md`. `/to-tickets` and the local issue-tracker template now agree, and the spec file is `spec.md` (not `PRD.md`) to match `/to-spec`.

  Docs pages for `setup-matt-pocock-skills` and `to-tickets` re-synced.

- [#532](https://github.com/mattpocock/skills/pull/532) [`170ad48`](https://github.com/mattpocock/skills/commit/170ad48655825783d0193e850e31a9aac957bb95) Thanks [@mattpocock](https://github.com/mattpocock)! - Reword **`grilling`** for general use. Its description and body no longer scope the interview to a software plan: "this plan" → "this", "enact the plan" → "act on it", and "exploring the codebase" → "exploring the environment". The technique is unchanged; it now reads as a stress-test of any plan, decision, or idea.

- [#593](https://github.com/mattpocock/skills/pull/593) [`a4b2009`](https://github.com/mattpocock/skills/commit/a4b2009a1a3ac9575506c10b4c84f08f9bba7a38) Thanks [@mattpocock](https://github.com/mattpocock)! - Rework **`grilling`** from one-question-at-a-time to round-by-round. It now maps the decision tree and asks the whole **frontier** — every question whose prerequisites are already settled — in a single numbered round, then recomputes the frontier from the user's answers and asks the next round. Same 13 questions land in ~3 rounds instead of 13. Facts the environment can answer are dispatched to background sub-agents so research never blocks the round: only questions downstream of a running exploration wait for it. The session ends when the frontier is empty.

  Every question in a round is emitted in one fixed shape — `❓ **Q1** - **<title>**`, then the body (prose or multiple choices), then the recommendation on its own `➡️` line. A round reads as a scannable numbered list with each recommendation visually separated from the question, so you can answer by number instead of quoting questions back.

  `grill-me`, `grill-with-docs` and `triage` run the frontier a round at a time as well — `triage`'s grill step and `grilling`'s Codex `short_description` now say so instead of describing the old rhythm. The opt-out for one-question-at-a-time (a line in your global `CLAUDE.md`) is unchanged.

- [#752](https://github.com/mattpocock/skills/pull/752) [`c66bdee`](https://github.com/mattpocock/skills/commit/c66bdeeee002d81e3f8b21403c07f9a0d7bea6da) Thanks [@mattpocock](https://github.com/mattpocock)! - Remove six skills from the repo. None of them was in the Claude Code plugin, but all six were installable through [skills.sh](https://skills.sh/mattpocock/skills), which serves every skill in the repo — so this is what leaves that listing, and where each one went.

  Four retired skills, each already absorbed by a skill that does the job better:

  - **`ubiquitous-language`** → **`/domain-modeling`**, which builds and maintains the whole domain model rather than dumping a glossary from one conversation.
  - **`design-an-interface`** → **`/codebase-design`**. Nothing is lost: the "design it twice" technique — parallel sub-agents generating radically different designs, from Ousterhout — ships inside that skill as `DESIGN-IT-TWICE.md`.
  - **`qa`** → **`/triage`** and **`/to-tickets`**.
  - **`request-refactor-plan`** → **`/to-spec`** and **`/improve-codebase-architecture`**.

  And two that were only ever mine — tied to my own machine and never meant for anyone else. The `personal/` bucket goes with them:

  - **`edit-article`**
  - **`obsidian-vault`**, which hardcoded a path to my own Obsidian vault.

  `skills/deprecated/` stays as a bucket, now empty. `skills/in-progress/` is unchanged and is now described for what it actually is: a beta channel, published on purpose, installable one skill at a time through skills.sh.

- [#734](https://github.com/mattpocock/skills/pull/734) [`a2f9333`](https://github.com/mattpocock/skills/commit/a2f9333669ff53db762c87ecda5a15442060a3be) Thanks [@mattpocock](https://github.com/mattpocock)! - Finish the `to-prd` → `to-spec` rename: "spec" is now the only term in the shipped text.

  - **`to-spec`** no longer opens with "you may know this document as a PRD" — the parenthetical is dropped from the skill and its docs page. The local-markdown tracker template drops the same hedge.
  - **`code-review`** talks about the originating issue/spec rather than issue/PRD, in its frontmatter description, its two-axis summary, and the spec-source search order. Both READMEs re-synced.
  - **The GitHub and GitLab tracker templates** now say "Issues and specs for this repo live as GitHub/GitLab issues" — they had been left on "PRDs" when the local template was updated, so the stale term propagated into every repo they were written into.
  - **`docs/engineering/research.md`** pointed at `https://aihero.dev/skills-to-prd`, a dead slug for the renamed skill; it now links `to-spec` like the other nineteen docs pages do.

  The CHANGELOG and existing changesets still name PRDs where they document the rename itself, which is correct.

## 1.1.0

### Minor Changes

- [#406](https://github.com/mattpocock/skills/pull/406) [`930a450`](https://github.com/mattpocock/skills/commit/930a450089f77a49af09001d955db8452a4b867d) Thanks [@mattpocock](https://github.com/mattpocock)! - Bring the **`ask-matt`** router up to date with the full skill set. It now maps five skills it was missing: **`tdd`** (woven into the main flow as the red-green engine `implement` drives), **`diagnosing-bugs`** (a new "Something's broken" on-ramp — there was previously no route for a bug), **`domain-modeling`** and **`codebase-design`** (a new "Vocabulary underneath" section), and **`grilling`** (the shared interview primitive). `prototype` is fleshed out as a standalone and the description broadens from "user-invoked skills" to "the skills". A maintenance rule is added to `CLAUDE.md` so any future skill add/rename/remove or flow change triggers an `ask-matt` re-check, beside the existing docs-page re-sync rule.

- [#464](https://github.com/mattpocock/skills/pull/464) [`639df6e`](https://github.com/mattpocock/skills/commit/639df6e7386dfddc739b2aecdeff37a876f2483b) Thanks [@mattpocock](https://github.com/mattpocock)! - Promote and harden **`code-review`**. The in-progress **`review`** skill is renamed to **`code-review`** and moved from `in-progress/` into `engineering/`: it now ships in the plugin, is listed in the top-level and Engineering READMEs (Model-invoked), and has a docs page at `docs/engineering/code-review.md`. The `/implement` skill and docs point at `/code-review`.

  It also gains an always-on **Fowler smell baseline** on its Standards axis — a curated ~12 high-signal "Bad Smells in Code" (Mysterious Name, Duplicated Code, Feature Envy, Data Clumps, Primitive Obsession, Repeated Switches, Shotgun Surgery, Divergent Change, Speculative Generality, Message Chains, Middle Man, Refused Bequest) inlined into `SKILL.md` as a fixed baseline alongside whatever the repo documents, not a new third axis. Two binding rules keep it safe: a documented repo standard overrides the baseline, and every smell is reported as a judgement call, never a hard violation.

- [#464](https://github.com/mattpocock/skills/pull/464) [`639df6e`](https://github.com/mattpocock/skills/commit/639df6e7386dfddc739b2aecdeff37a876f2483b) Thanks [@mattpocock](https://github.com/mattpocock)! - Sharpen **`grilling`** on two fronts.

  **A confirmation gate.** The agent won't enact the plan until you confirm the shared understanding has been reached — turning the skill's existing "shared understanding" completion criterion into an explicit stop-gate. The `description` also recruits the pretrained **`grill`** leading word ("Grill the user relentlessly") to sharpen invocation, and the docs page is re-synced.

  **Facts vs. decisions.** Grilling now splits _facts_ (look them up — explore the codebase) from _decisions_ (put each one to the human and wait for their answer). The old blanket line — "if a question can be answered by exploring the codebase, explore the codebase instead" — was written for the live-human case, but once another skill runs grilling inside a resolve-the-ticket frame it read as license to answer _decisions_ autonomously too. Separating the two keeps a grilling agent from racing ahead and answering its own questions.

- [#463](https://github.com/mattpocock/skills/pull/463) [`af6d692`](https://github.com/mattpocock/skills/commit/af6d6922c3e2b5288eef155346cbe319e4ed3bd0) Thanks [@mattpocock](https://github.com/mattpocock)! - Add two adjacent Steering failure modes to **`writing-great-skills`**, both about how language you think of as "off" still steers the agent. **Negation** — the _elephant_ — is steering by prohibition: naming what _not_ to do drags the forbidden behaviour into context and makes it _more_ available, not less (_don't think of an elephant_), so the cure is to prompt the **positive**. **Negative Space** — the void — is blindness to the steering done by what you leave _out_: every decision a skill declines is delegated to the agent's priors rather than left neutral, so the cure is to read a draft for its silences and decide each omission deliberately (fill it, or leave it open as a real **branch**). Kept as two entries, not one — they carry different diagnostics and different cures — each a full `GLOSSARY.md` entry plus a `SKILL.md` failure-mode bullet, matching how every other failure mode is carried.

- [`850873c`](https://github.com/mattpocock/skills/commit/850873cd73d5f81826ebf512ad35d2b1e113001f) Thanks [@mattpocock](https://github.com/mattpocock)! - Make the **`prototype`** skill model-invoked, so the agent can reach for it autonomously (and other skills can too). Its description is rewritten around the leading word _prototype_ — throwaway code that answers a design question — with one trigger per branch (state/logic sanity-check, or UI exploration).

- [#409](https://github.com/mattpocock/skills/pull/409) [`0d74d01`](https://github.com/mattpocock/skills/commit/0d74d01cbc64ca27778a49b38599f70c534e76a0) Thanks [@mattpocock](https://github.com/mattpocock)! - Add the **`research`** skill — a small, model-invoked skill that spins up a **background agent** to investigate a question against **primary sources** (official docs, source code, specs, first-party APIs), then leaves a single cited Markdown file wherever the repo keeps such notes. It's delegable reading legwork: you keep working while it reads, and get back a document to grill, plan, or design against. Listed in the top-level and Engineering READMEs (Model-invoked), added to `.claude-plugin/plugin.json`, given a docs page at `docs/engineering/research.md`, and routed as a Standalone in `ask-matt`.

- [#469](https://github.com/mattpocock/skills/pull/469) [`a0329ba`](https://github.com/mattpocock/skills/commit/a0329ba95751f58566ed7ab484475917a68f1629) Thanks [@mattpocock](https://github.com/mattpocock)! - Split the **`to-issues`** skill into a lean **Process** and a **Reference** section, and teach it to handle a **wide refactor** — a single mechanical change (like renaming a column) whose **blast radius** fans across the whole codebase, breaking thousands of call sites at once so no vertical slice can land green. The drafting step now points at two co-located reference blocks: the **Vertical slice rules** for ordinary tracer bullets, and **Wide refactors**, which slices the change by **expand–contract** (expand the new form beside the old, migrate call sites in batches sized by blast radius, then contract the old form away) so CI stays green batch to batch — or, when it can't, only at a final integrate-and-verify issue. The issue body template moves into Reference too.

- [#464](https://github.com/mattpocock/skills/pull/464) [`386d4ff`](https://github.com/mattpocock/skills/commit/386d4ff719a7c420ad1454232d0436b01f1b8c17) Thanks [@mattpocock](https://github.com/mattpocock)! - Unify the planning skills. **`to-prd` is renamed to `to-spec`** — "spec" is now the single through-line term (it still opens with "you may know this document as a PRD" for discoverability). **`to-plan` and `to-issues` are merged into one `to-tickets` skill, and `to-issues` is deleted.**

  `to-tickets` breaks a plan, spec, or conversation into a set of **tickets** — tracer-bullet vertical slices, each declaring its **blocking edges**. That one artifact reads two ways depending on the tracker `/setup-matt-pocock-skills` configured: a **local file** (`tickets.md`) writes the edges as text and you work it top-to-bottom by hand; a **real tracker** writes them as native blocking links, so any ticket whose blockers are done is on the frontier and several agents can run at once. The edges live in the ticket either way — the medium only decides whether anything acts on them in parallel.

  Publishing prefers the tracker's **native sub-issues** for parent → slice and **native blocking edges** for `Blocked by` where the tracker supports them, keeping the `## Parent` / `## Blocked by` body sections as the fallback. The "What to build" template points at where a `/prototype`'s code lives rather than inlining a snippet from it.

  `ask-matt`'s main flow now routes `idea → /to-spec → /to-tickets → /implement`, and there are human-facing docs pages at `docs/engineering/to-spec.md` and `docs/engineering/to-tickets.md`.

- [#464](https://github.com/mattpocock/skills/pull/464) [`0557d57`](https://github.com/mattpocock/skills/commit/0557d57579d9b3d39839fdaf8d4a6542b17539ce) Thanks [@mattpocock](https://github.com/mattpocock)! - Settle wayfinder's place in the docs as a **situational on-ramp**, not the new main entry flow — the grill-led _idea → ship_ chain stays the front door (crowning wayfinder as the default spine is a v2-sized move, not a 1.1). The **`ask-matt`** router now names wayfinder's concrete triggers — a greenfield project or a huge feature build, too big for one session — and the two grill front doors (**`grill-me`**, **`grill-with-docs`**) signpost _up_ to wayfinder for the effort that's too big to hold in one session, so the on-ramp is discoverable from where a reader actually starts.

- [#464](https://github.com/mattpocock/skills/pull/464) [`639df6e`](https://github.com/mattpocock/skills/commit/639df6e7386dfddc739b2aecdeff37a876f2483b) Thanks [@mattpocock](https://github.com/mattpocock)! - Graduate and reframe **`wayfinder`** — the skill for planning a huge chunk of work, more than one agent session can hold. It moves out of `in-progress/` into `engineering/` (plugin entry, top-level + Engineering READMEs under **User-invoked**, a docs page at `docs/engineering/wayfinder.md`, and a route in `ask-matt`), landing as a mature skill. The rename and reframe that got it there:

  - **`decision-mapping` is renamed to `wayfinder`**, invoked as `/wayfinder`. "Decision map" was jargony and inaccurate — only one ticket type is actually a decision. The reframe charts a route through a foggy problem instead, giving one coherent leading-word frame — **fog of war**, **frontier**, **the map** — rather than an invented term layered on top.
  - **Destination as the leading word.** Wayfinding finds the _way_ to a destination; it doesn't charge at building it. Naming the destination is the first act of charting — it fixes the scope and shapes every ticket — so the map gains a `## Destination` field every session orients to, and triage pins it before any ticket exists.
  - **Plan, don't do.** The map produces **decisions, not deliverables**; it's done when nothing is left to decide before someone builds the thing. An effort can override this in its Notes.
  - **The map is an index, not a store.** A decision lives in exactly one place — its ticket — so the map only gists and links, never restates; graduating fog into a ticket clears the graduated patch so nothing lingers in two places.
  - **Collaborative by default.** The map moves off a local Markdown file onto the repo's issue tracker: a single `wayfinder:map` issue whose tickets are its child issues — one shared URL the team can watch. Sessions load the map at low resolution and zoom into tickets on demand. Wayfinder stays tracker-agnostic (GitHub, GitLab, local-markdown) behind a pointer in `docs/agents/issue-tracker.md`, and `setup-matt-pocock-skills` seeds the "Wayfinding operations" section.
  - **Claim by assignment, not a label.** A session claims a ticket by assigning it to the driving dev — the assignee _is_ the claim — freeing the label vocabulary to `wayfinder:<type>` alone.
  - **Native blocking.** Blocking prefers the tracker's native dependency relationship, which renders the frontier visually in the tracker's own UI so the human sees what's takeable without opening the map. GitHub and GitLab templates spell out the native recipe, with a body-convention fallback.
  - **Fog vs. out of scope, split.** Two plainly-named map sections — `## Not yet specified` (in-scope fog that graduates as the frontier advances) and `## Out of scope` (work ruled beyond the destination, closed, never graduating) — so beyond-destination work no longer reads as takeable frontier.
  - **A fourth `task` ticket type.** For literal manual work that blocks a decision (provisioning access, moving data, signing up for a service) — the one type that _does_ rather than decides, earning its place by unblocking a decision.
  - **HITL / AFK ticket classification.** Every ticket type is **HITL** (human in the loop — grilling, prototype) or **AFK** (agent alone — research; task is either). A HITL ticket only resolves through the live exchange, so "wait for the human" falls out of the label — a grilling agent that answers its own questions has, by definition, broken HITL. (This fixes students' reports of `/wayfinder` grilling _itself_ instead of the human.)
  - **No-fog early exit restored.** If the opening breadth-first grilling surfaces no fog, the journey is small enough for one session — so it stops and asks how you'd like to proceed rather than building a map nobody needs.

### Patch Changes

- [#464](https://github.com/mattpocock/skills/pull/464) [`639df6e`](https://github.com/mattpocock/skills/commit/639df6e7386dfddc739b2aecdeff37a876f2483b) Thanks [@mattpocock](https://github.com/mattpocock)! - Reshape **`tdd`** into a reference-only skill and add a missing anti-pattern.

  **Reference-only.** The red → green → refactor loop is anchored by leading words the model already holds, so the step-by-step Workflow was largely restating the loop. Dropped the Workflow and per-cycle checklist; folded their one durable idea — vertical slices / tracer bullets — into the Anti-patterns section and a short Rules-of-the-loop list. Introduced **seam** as the leading word for where tests go: test only at pre-agreed seams, confirmed with the user before any test is written. Also dropped the refactor stage — TDD is now red → green; refactoring belongs to the review stage, so the refactor rule and `refactoring.md` moved out (its home is `code-review`).

  **Tautological tests.** Added the tautological-test anti-pattern: a test whose assertion is recomputed the way the code computes it passes by construction and gives zero confidence — distinct from the implementation-coupling anti-pattern already covered. Added as a peer at the same sites: a Philosophy principle (expected values must come from an independent source of truth), a checklist gate, and a BAD/GOOD example pair in `tests.md`.

- [`e00eadb`](https://github.com/mattpocock/skills/commit/e00eadb4bb32c3d5a631ead1a5ed5d6a7c5f74e2) Thanks [@mattpocock](https://github.com/mattpocock)! - Extend the **`triage`** skill to triage external pull requests, treating a PR as an issue with attached code that runs through the same roles and state machine. PRs flow inline alongside issues (gated by a per-repo setup toggle), discovery surfaces only external PRs, the bug-only "reproduce" step is generalized into a single "verify the claim" step, and a redundancy check resolves already-implemented requests to `wontfix` without polluting the out-of-scope knowledge base. `setup-matt-pocock-skills` gains the PRs-as-a-request-surface toggle for GitHub/GitLab.

- [#472](https://github.com/mattpocock/skills/pull/472) [`d869d45`](https://github.com/mattpocock/skills/commit/d869d45afc32beab1c2d1350f8de5e81589512cd) Thanks [@mattpocock](https://github.com/mattpocock)! - Fix **`wayfinder`** hardcoding the issue-tracker doc path, which broke the indirection the rest of the suite relies on.

  `to-issues`, `to-prd`, and `triage` never name a path — they resolve the tracker through the `### Issue tracker` block that `setup-matt-pocock-skills` writes into `CLAUDE.md` / `AGENTS.md`, which points at the tracker doc wherever it lives. Wayfinder instead pinned the literal `docs/agents/issue-tracker.md`, so in a repo that keeps its agent docs elsewhere it silently fell back to the local-markdown tracker — even one whose `CLAUDE.md` clearly declares GitHub issues. It now resolves the doc via that same pointer and reads its "Wayfinding operations" section by name, keeping the indirection consistent across the suite.

## 1.0.1

### Patch Changes

- [`d20ee26`](https://github.com/mattpocock/skills/commit/d20ee2684e2a9442698ac3c1e0f2c5b68c4cf296) Thanks [@mattpocock](https://github.com/mattpocock)! - Make the **`teach`** skill reuse-first. Lessons are now built from reusable **components** in `./assets/` — stylesheets, quiz widgets, simulators, diagram helpers. Reuse is the default: the agent reads `./assets/` before authoring a lesson, builds from what's there, and extracts anything new and reusable into a component rather than inlining it.

## 1.0.0

### Major Changes

- [`47bde84`](https://github.com/mattpocock/skills/commit/47bde84da032afb2e5058f997f3bbca47d321dbd) Thanks [@mattpocock](https://github.com/mattpocock)! - Add the **`ask-matt`** skill — a user-invoked router that points you at the right skill or flow for your situation.

  **Breaking:** `ask-matt` routes over the other user-invoked skills in this repo, so it expects them to be installed.

- [`47bde84`](https://github.com/mattpocock/skills/commit/47bde84da032afb2e5058f997f3bbca47d321dbd) Thanks [@mattpocock](https://github.com/mattpocock)! - Add the shared design skills and rewire existing skills onto them.

  - New **`codebase-design`** skill — the deep-module vocabulary (module, interface, depth, seam, adapter) and the principles for putting a lot of behaviour behind a small interface. The language that previously lived in `improve-codebase-architecture/LANGUAGE.md` now lives here, generalized for reuse across skills.
  - New **`domain-modeling`** skill — actively build and sharpen a project's domain model, stress-testing terms against the glossary and keeping `CONTEXT.md` and ADRs current.
  - `improve-codebase-architecture` now draws its architecture vocabulary from `/codebase-design` and its domain model from `/domain-modeling`.
  - `tdd` now leans on `/codebase-design` for interface-design guidance — its inline `deep-modules.md` / `interface-design.md` notes were removed in favour of the shared skill.
  - `grill-with-docs` now builds the domain model inline via `/domain-modeling`.

  **Breaking:** these skills now depend on the new `codebase-design` / `domain-modeling` skills, so you must install them too.

- [`47bde84`](https://github.com/mattpocock/skills/commit/47bde84da032afb2e5058f997f3bbca47d321dbd) Thanks [@mattpocock](https://github.com/mattpocock)! - Remove the **`caveman`** and **`zoom-out`** skills.

  - `caveman` was a duplicate of another skill I was testing and was never meant to be public.
  - `zoom-out` went unused in practice, so it's been removed from the repo.

  **Breaking:** both skills have been removed.

- [`47bde84`](https://github.com/mattpocock/skills/commit/47bde84da032afb2e5058f997f3bbca47d321dbd) Thanks [@mattpocock](https://github.com/mattpocock)! - Rename the **`diagnose`** skill to **`diagnosing-bugs`**.

  **Breaking:** invoke it as `/diagnosing-bugs` — the old `/diagnose` name no longer exists.

- [`47bde84`](https://github.com/mattpocock/skills/commit/47bde84da032afb2e5058f997f3bbca47d321dbd) Thanks [@mattpocock](https://github.com/mattpocock)! - Replace **`write-a-skill`** with **`writing-great-skills`**.

  - Removed `write-a-skill`.
  - Added `writing-great-skills` (plus its `GLOSSARY.md`) — a reference for writing and editing skills well: the vocabulary and principles that make a skill predictable, hunting no-ops down to the sentence level.
  - Exposed `grilling` as a model-invoked skill — the reusable interview loop behind `grill-me` and `grill-with-docs`.

  **Breaking:** `write-a-skill` has been removed; use `writing-great-skills` instead.

### Minor Changes

- [`47bde84`](https://github.com/mattpocock/skills/commit/47bde84da032afb2e5058f997f3bbca47d321dbd) Thanks [@mattpocock](https://github.com/mattpocock)! - Add the **`resolving-merge-conflicts`** skill — a loop for resolving an in-progress git merge or rebase conflict. Standalone, with no dependencies on other skills.

- [`47bde84`](https://github.com/mattpocock/skills/commit/47bde84da032afb2e5058f997f3bbca47d321dbd) Thanks [@mattpocock](https://github.com/mattpocock)! - Rename the skill taxonomy from **Commands / Skills** to **User-invoked / Model-invoked** across the docs, and add `docs/invocation.md` defining the split: user-invoked skills are reachable only when you type them and exist to orchestrate; model-invoked skills can also be reached automatically when the task fits. A user-invoked skill may invoke model-invoked skills, but never another user-invoked one.

### Patch Changes

- [`47bde84`](https://github.com/mattpocock/skills/commit/47bde84da032afb2e5058f997f3bbca47d321dbd) Thanks [@mattpocock](https://github.com/mattpocock)! - Tighten the **`review`** skill: fail-fast ref check, single-sourced rules, and no-op cuts.
