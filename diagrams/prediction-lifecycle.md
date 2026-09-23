# Prediction lifecycle

```mermaid
stateDiagram-v2
    [*] --> Open: match published
    Open --> Submitted: valid prediction saved
    Submitted --> Updated: valid edit saved
    Updated --> Updated: subsequent valid edit
    Submitted --> Locked: closing time reached
    Updated --> Locked: closing time reached
    Open --> Locked: closing time reached without prediction
    Locked --> ResultRecorded: official result validated
    ResultRecorded --> Scored: centralized rules applied
    Scored --> RankingUpdated: scoped standings recalculated
    RankingUpdated --> [*]
```

The authoritative server rule accepts a write only while `now < closes_at`; equality is locked. Status transitions and times should be checked together so a stale browser cannot reopen a prediction. Administrative corrections require an explicit, audited workflow and idempotent recalculation rather than moving silently backward through this lifecycle.
