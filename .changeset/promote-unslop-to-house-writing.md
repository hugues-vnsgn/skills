---
"osxsystem-skills": minor
---

Promote `unslop` out of `in-development/` into a new `house/writing/` domain, for prose a human reads (the counterpart to `writing-for-agents`, which covers documents an agent reads).

The skill was rewritten around three gaps. It now sets a **register** (reference, argument, conversation) before editing, because the voice advice that saves an essay ruins a config doc. It holds back any edit that would change a claim, reporting the problem instead of smoothing it, along with code, quoted material, and terms of art the project actually uses. And the 31 flat rules are regrouped into ten sections ranked by yield, led by the tell no pattern can find: a sentence that says nothing.

It also ships `scripts/check-tells.py`, a stdlib-only checker for the tells that are pattern matching rather than judgment. It masks code, links, and fenced blocks before matching, and splits results into `strict` (fix every hit) and `candidate` (the agent decides, because some of those words are the project's real vocabulary).
