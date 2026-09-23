# Prediction-to-ranking data flow

```mermaid
flowchart LR
    A[Participant enters prediction] --> B[Client feedback]
    B --> C[Authenticated request]
    C --> D[Server normalization and validation]
    D --> E{Authorized and before close?}
    E -- No --> F[Safe rejection response]
    E -- Yes --> G[(Transactional persistence)]
    G --> H[Confirmation]
    I[Administrator records official result] --> J[Validate transition and result]
    J --> K[(Official result persistence)]
    K --> L[Central scoring engine]
    G --> L
    L --> M[Point awards / projection]
    M --> N[Scoped ranking aggregation]
    N --> O[General, matchday, or group view]
```

Client validation is advisory. Server validation, authorization, deadline enforcement, and persistence constraints establish the trust boundary. Official result changes should trigger idempotent scoring/recalculation tied to a source or rule version.
