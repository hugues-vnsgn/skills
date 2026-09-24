# Pre-commit quality audit

Apply to the changed behavior and its affected tests. Mark conditional checks not applicable when justified. This checklist establishes readiness; committing still follows the user's authorized scope.

## Evidence checklist

- [ ] Each accepted behavior has an appropriate observable test or a specific justified exception.
- [ ] The new regression/feature test failed for its intended reason before implementation, or the already-green/unavailable-execution exception is recorded.
- [ ] Tests exercise the real subject with independent expectations and fail on missing callbacks, wrong values, or wrong errors.
- [ ] Relevant boundaries, errors, repeated events, cancellation, and stale results are covered.
- [ ] Each case gets isolated fixtures/dependencies; tasks, observers, subscriptions, sessions, and temporary storage are cleaned up.
- [ ] Interaction checks express a contract; private implementation choices are not the primary assertion target.
- [ ] Async isolation and mutable recording follow the actual Swift mode without broad warning suppression.
- [ ] Important adapter, resource, and UI binding gaps are checked at the appropriate integration layer.
- [ ] Relevant tests and project-required checks executed against the reported target/destination, with nonzero test discovery and no unexplained skips.
- [ ] The final diff contains no unrelated refactors, hidden live network dependencies, weakened assertions, or disabled tests masking failures.

## Smell audit

| Finding | Required response |
|---|---|
| SUT replaced with a mock | Restore real subject; double its dependency |
| Assertions only inside an unawaited callback | Wait for observed completion and assert outcome |
| Expected value recomputed with production logic | Use independent examples or invariants |
| Huge shared builder hides important input | Use fresh minimal baseline and explicit scenario overrides |
| Private cache dictionary/helper order assertions | Assert result, no additional I/O, or other stable behavior |
| Broad SDK/service subclass mock | Audit inherited side effects; introduce consumer protocol when feasible |
| Shared singleton/request handler | Inject isolated state; reset unavoidable legacy state and document its limit |
| Multiple identical expectations used as event count | Count a filtered event and assert its sequence |
| Immediate stub used as concurrency proof | Add controllable completion and test promised isolation |
| Sleep or arbitrary tiny wait | Control clock/scheduler or wait on actual condition |
| Initial publisher emission accepted as action result | Assert intended transition; manage initial state explicitly |
| Canceled request assumed unable to finish | Test late/out-of-order completion against request identity |
| Ambiguous nil/nil result | Introduce explicit error/success semantics within scope |
| Legacy observation treated as a new requirement | Separate characterization baseline from corrective behavior |
| Coverage percentage used as sole evidence | Check assertion sensitivity and relevant untested branches |
| Assertion loosened after a regression | Establish requirement or test defect before changing expectation |

Investigate repeat/order-dependent tests when evidence points to leaked state; do not routinely rerun passing suites without a reason. If an environment failure prevents execution, report it separately from code failures and leave verification status unresolved. Static review or successful compilation alone is not a passed test run.

## Completion report

Give the user the implemented behavior, meaningful red evidence (or exception), passing commands with test target/destination, and any remaining risks or unrun checks. Include only material details; no ceremonial log file is required.
