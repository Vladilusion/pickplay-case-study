# Layered architecture

This diagram presents logical boundaries inside a modular application; boxes are not independent microservices.

```mermaid
flowchart TB
    subgraph Client[Client]
        Browser[Browser]
        UI[Responsive HTML5 / CSS3]
        JS[JavaScript + asynchronous interactions]
        Browser --> UI
        UI <--> JS
    end

    subgraph Server[PHP application]
        Controller[Controllers / request adapters]
        Auth[Authentication + authorization]
        Prediction[Prediction service]
        Competition[Competition administration]
        Simulation[Simulation service]
        Scoring[Central scoring engine]
        Ranking[Ranking queries]
        Repository[Repositories / transaction boundary]
        Controller --> Auth
        Controller --> Prediction
        Controller --> Competition
        Controller --> Simulation
        Prediction --> Scoring
        Simulation --> Scoring
        Scoring --> Ranking
        Prediction --> Repository
        Competition --> Repository
        Simulation --> Repository
        Ranking --> Repository
    end

    JS <-->|HTTPS / JSON or HTML| Controller
    UI -->|form submission| Controller
    Repository -->|prepared SQL| Database[(MySQL)]
```

## Boundary notes

- The client gives immediate feedback; the PHP boundary repeats validation and owns authorization.
- Controllers coordinate use cases but do not calculate points.
- The scoring component is deterministic and shared by official and hypothetical calculations.
- Repository methods parameterize values and make transactions explicit.
- MySQL preserves relational constraints and supports scoped ranking aggregation.

See [System architecture](../docs/02-system-architecture.md).
