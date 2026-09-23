# Prediction-to-ranking data flow

```mermaid
flowchart LR
    A[Participant enters prediction] --> B[Client feedback]
    B --> C[Authenticated request]
    C --> D[Server normalization and validation]
    D --> E{Authorized and before close?}
    E -- No --> F[Safe rejection response]
    E -- Yes --> G[(Transactionally stored eligible prediction)]
    G --> H[Submission confirmation]
    I[Administrator records official result] --> J[Validate transition and result]
    J --> K[(Finalized official result)]
    G --> R{Both inputs available?}
    K --> R
    R -- Yes --> L[Central scoring engine]
    R -- No --> W[Wait without scoring]
    L --> M[Point awards / projection]
    M --> N[Scoped ranking aggregation]
    N --> O[General, matchday, tournament-group, or private-group view]
```

Client validation is advisory. Server validation, authorization, deadline enforcement, and persistence constraints establish the trust boundary. Persisting a prediction confirms only the submission; it does not independently trigger scoring. The scoring engine requires both an eligible stored prediction and a finalized official result. Official result changes should trigger idempotent scoring/recalculation tied to a source or rule version.
