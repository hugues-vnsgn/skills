---
"osxsystem-skills": minor
---

Rewrite `show-me` around two gaps: it was anchored on TypeScript and it stopped at "understand".

The eight notation forms were never language-bound (a structure tree describes a Compose screen, a SwiftUI body, or a Terraform module equally well), but three of them were written in TS/React and every example lived in the same imaginary TS monorepo, so the agent pattern-matched the examples and emitted JSX-shaped trees for code that was not JSX. Notation now defaults to pseudocode and plain trees, with real syntax licensed for exactly two cases: the user needs something copyable, or the syntax is itself the point.

The skill also gained the second half its name implies. **Compress** cuts every element the current question does not need, replacing the old "don't overwhelm the user" (a negation, which makes the unwanted behaviour more available, not less) with a checkable bar. **Collapse** then reads the picture back, because complexity is often only visible once drawn: five named shapes (hub, repeat, pass-through, round trip, fan-out on load) tell the agent what to look for, and when one appears it draws the smaller shape beside the current one. It draws only, handing off to `codebase-design`, `improve-codebase-architecture`, and `when-stuck`, and it says so plainly when the picture is already clean rather than inventing a smell to have something to collapse.

Two smaller fixes: a question-to-form table replaces the flat list of eight peers, so picking a form is no longer a coin flip; and the HTML branch no longer assumes a web product, so it still works for a CLI, a library, or a native app with no web surface.
