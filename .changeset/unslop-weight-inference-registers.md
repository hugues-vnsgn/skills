---
"osxsystem-skills": patch
---

Rework `unslop` against its own eval results. The body loses a quarter of its words, the claim rule gains a third move, and the register set gains a fourth entry.

Splitting the tell list follows the seam the skill already had. Everything `check-tells.py` matches now lives in `references/tells.md` and is reprinted with its fix in the checker's own output, so `SKILL.md` carries only the tells that need a person's judgment. That is what a skill body costs: it rides along on every turn once the skill fires, so the half a regex can do for you does not belong in it.

The claim rule used to have two settings, leave it or cut it, and both produce a thinner page than the one the author wanted. It now has three, and the new one is to write the missing explanation and mark it in place as the skill's own inference, so the reader gets the mechanism and the author can confirm or delete it in one keystroke. What stays banned is the quiet version, where a claim changes and nobody is told.

A commit body moves from Reference to Argument, because it argues that this was the right fix rather than reporting what moved. A new Instruction register covers documents an agent reads, which makes the `writing-for-agents` relationship a layering rather than a handoff: that skill owns the structure, this one owns the prose inside it.

Also: the description carries non-triggers so the skill stops firing on chat replies and one-line commit subjects, `surface` joins `harness` and `primitive` as a checker candidate so the leave-alone examples are actually enforced, quoting rules now say the source's words are untouchable while the marks around them are yours, and `evacuate` returns to the abstract-noun list it fell out of.
