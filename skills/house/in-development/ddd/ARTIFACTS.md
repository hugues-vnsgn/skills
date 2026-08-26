# Artifact notation

Fixed shapes for the artifacts a `ddd` session produces, so two sessions on the same repo stay comparable and a reader who has read one can read the next. Read the section for each artifact the session owes and skip the rest.

| Artifact | Section | Produced when |
| --- | --- | --- |
| Context map | [Context map](#context-map) | `contexts` settled |
| Glossary | [Ubiquitous language glossary](#ubiquitous-language-glossary) | `language` settled |
| Model diagram | [Model diagram](#model-diagram) | `aggregates` settled |
| Event table and flow | [Domain events](#domain-events) | `events` settled |
| Coverage note | [Coverage](#coverage) | always |

## Context map

One `flowchart LR`, one node per bounded context, labelled with its subdomain class. Every edge runs **upstream to downstream**: the tail's model shapes the head's. Label each edge with what crosses it and the relationship pattern.

Open the map with one line saying whether it draws the system as it runs today or the state the session is steering towards. In a carve-up the answer is usually the target, and a reader who was not in the room has no other way to tell.

```mermaid
flowchart LR
    Ordering["Ordering<br/>(supporting)"]
    Billing["Billing<br/>(core)"]
    Ledger["Ledger<br/>(core)"]
    Tax["Tax<br/>(generic, vendor)"]

    Ordering -->|"OrderPlaced : Customer/Supplier"| Billing
    Billing -->|"InvoiceIssued : Published Language"| Ledger
    Tax -->|"rate lookup : ACL"| Billing
```

Name the pattern from this vocabulary, because each one is a different answer to who absorbs change:

| Pattern | Means |
| --- | --- |
| `Partnership` | the two contexts succeed or fail together and coordinate releases |
| `Shared Kernel` | a small model both own jointly, changed only by agreement |
| `Customer/Supplier` | the downstream's needs sit on the upstream's backlog |
| `Conformist` | the downstream takes the upstream model as it is, no translation |
| `ACL` | the downstream translates at its edge and keeps its own model clean |
| `Open Host Service` | the upstream publishes one protocol for all comers |
| `Published Language` | a shared, versioned interchange format |
| `Separate Ways` | no integration, duplication accepted on purpose |

Subdomain classes are `core` (the reason the business wins), `supporting` (needed, specific, not a differentiator), and `generic` (buyable). Mark a vendor or off-the-shelf system, since a boundary you do not control is the one most worth an ACL.

Quote every node label. `Billing (core)` unquoted is a mermaid parse error; `Billing["Billing<br/>(core)"]` is not.

Keep it to the contexts in scope. A map of every service in the company is an org chart, not a model.

## Ubiquitous language glossary

Group by context, since a term only means something inside one. This is `domain-modeling`'s `CONTEXT.md` shape on purpose, so the handoff is a copy rather than a translation.

```md
### Billing

**Invoice**:
A request for payment issued after fulfilment, denominated in the currency the customer agreed at order time.
_Avoid_: Bill, statement, charge

**Settlement**:
The match of an inbound payment against an invoice that takes its balance to zero.
_Avoid_: Payment. A payment is money moving; a settlement is the match.
```

- One or two sentences. Define what the term **is**, not what it does.
- `_Avoid_` carries the rejected synonyms. Where two teams genuinely meant different things by one word, say which meaning this context kept, because that sentence is the whole reason the entry exists.
- Skip general programming vocabulary (retries, timeouts, DTOs). Only concepts specific to this domain earn an entry.
- Where the same word survives in two contexts with different meanings, write it in both, and let the two entries contradict each other. That contradiction is the boundary doing its job.

## Model diagram

One `classDiagram` per aggregate cluster, three to seven classes. Past that it stops being read.

```mermaid
classDiagram
    class Invoice {
        <<Aggregate Root>>
        +InvoiceId id
        +CustomerId customer
        +Money total
        +issue() InvoiceIssued
    }
    class LineItem {
        <<Entity>>
        +LineItemId id
        +Money amount
    }
    class Money {
        <<Value Object>>
        +long minorUnits
        +Currency currency
    }
    class InvoiceIssued {
        <<Domain Event>>
        +InvoiceId invoice
        +Instant occurredAt
    }

    Invoice "1" *-- "1..*" LineItem : owns
    LineItem --> Money : amount
    Invoice ..> InvoiceIssued : emits

    note for Invoice "Invariant: total equals the sum of line amounts, and every line carries the invoice currency."
```

Stereotype every class, because an unlabelled box hides the one thing the reader needs:

| Stereotype | Use for |
| --- | --- |
| `<<Aggregate Root>>` | the only member anything outside the aggregate may hold |
| `<<Entity>>` | identity that outlives its attribute values |
| `<<Value Object>>` | defined wholly by its attributes, replaced rather than mutated |
| `<<Domain Event>>` | something that happened, named in the past tense |
| `<<Repository>>` | retrieval of aggregate roots |
| `<<Domain Service>>` | domain behaviour belonging to no single entity |

- Composition (`*--`) inside an aggregate; plain association (`-->`) across one, and across a boundary reference by id rather than by object, so the diagram shows the transaction boundary instead of hiding it.
- Give every aggregate root a `note for` stating its invariant. The invariant is why the boundary exists, and nothing else in the notation can say it.
- Show only the fields the invariant or the boundary depends on. A full field list turns the diagram into a worse version of the schema.

## Domain events

One table. Past-tense names, drawn from the glossary.

| Event | Emitted by | Carries | Consumed by | Then |
| --- | --- | --- | --- | --- |
| `OrderPlaced` | Ordering | order id, customer, lines, agreed currency | Billing | opens a draft invoice |
| `InvoiceIssued` | Billing | invoice id, total, currency, due date | Ledger | posts a receivable |

An event carries what its consumers need and nothing more. Every extra field is a piece of the producer's model the consumer can now depend on, which is how two contexts quietly become one.

Add a `sequenceDiagram` once three or more contexts take part, where the ordering is the point:

```mermaid
sequenceDiagram
    participant Ordering
    participant Billing
    participant Ledger
    Ordering->>Billing: OrderPlaced
    Billing->>Billing: draft invoice
    Billing--)Ledger: InvoiceIssued
    Ledger--)Billing: EntryPosted
```

Use `--)` for asynchronous delivery and `->>` for a synchronous call, since which one it is decides what the consumer can assume about time.

## Coverage

Close every session with this, so a reader can tell a decision from a gap from a guess.

```md
## Coverage

**Draws**: the target state, not the system as it runs today.
**Settled**: contexts, language, aggregates.
**Parked**: `integration`, at the user's call, pending the ledger vendor decision. The context map therefore carries no pattern on Billing to Ledger.
**Inferred**: `Money` as minor-unit integers, read from `invoices.amount_cents` at `db/schema.sql:41` and not confirmed by an expert.
```
