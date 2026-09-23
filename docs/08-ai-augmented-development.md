# AI-augmented development

## Working position

José Escalante has used an AI-augmented development workflow since 2024. Generative AI broadens exploration and accelerates drafts; it does not replace engineering accountability. The developer remains responsible for requirements, architecture, correctness, licensing, privacy, security, testing, deployment, and the final commit.

No productivity percentages or unsupported delivery claims are made here.

## Where AI can assist

| Activity | Useful assistance | Required human control |
|---|---|---|
| Requirement decomposition | Identify actors, invariants, edge cases, and acceptance-test candidates | Confirm intent with stakeholders; reject invented requirements |
| Code generation | Draft small functions, adapters, fixtures, or migrations | Understand every line; adapt conventions; compile/lint/test |
| Refactoring | Suggest extractions and dependency boundaries | Preserve behavior with characterization tests and review diffs |
| SQL optimization | Offer query shapes and index hypotheses | Inspect plans on representative sanitized data; measure trade-offs |
| Debugging | Generate hypotheses and minimal reproductions | Verify evidence; avoid exposing logs or data; test the fix |
| UX iteration | Explore content, responsive states, accessibility cases | Validate with users/tools and existing design constraints |
| Documentation | Draft structure, examples, and decision summaries | Fact-check claims, links, terminology, and current behavior |
| Test generation | Enumerate equivalence classes, boundaries, races, and failures | Ensure meaningful assertions and maintain independent oracles |
| Code review | Flag risk patterns, missing checks, or complexity | Treat output as untrusted suggestions; complete accountable review |
| Architecture exploration | Compare options and trade-offs | Decide from actual constraints; record rationale and revisit triggers |

## A traceable workflow

1. **Frame:** state the problem, non-goals, security boundary, constraints, and acceptance criteria without confidential context.
2. **Explore:** request alternatives and explicit trade-offs rather than a single authoritative answer.
3. **Constrain:** choose a small change and supply only sanitized interfaces or synthetic data.
4. **Implement:** edit on a branch; separate generated drafts from adopted code in review reasoning.
5. **Validate:** run deterministic tests, type/static checks, linters, query plans, and targeted security review.
6. **Inspect:** read the full diff, challenge assumptions, remove unsupported claims, and confirm licenses/provenance where relevant.
7. **Record:** use source control, commit messages, issues/ADRs, and reproducible commands to preserve why the result was accepted.
8. **Review:** obtain normal peer approval for material changes; AI output does not waive review.

Prompts and tool/model versions can be recorded when useful for reproducibility, but never at the cost of retaining secrets or personal data. Stable test cases and decisions are generally more durable evidence than raw conversational transcripts.

## Validation by change type

- **Scoring:** table-driven unit tests for precedence, points, multiplier, and invalid values.
- **Rankings/SQL:** fixtures for zero-point users, ties, scope boundaries, and `EXPLAIN ANALYZE` review.
- **Temporal writes:** controlled-clock tests at before/equal/after close plus concurrent requests.
- **Frontend:** keyboard and screen-reader paths, mobile layouts, malformed inputs, and server rejection.
- **Security changes:** threat model, authorization matrix, misuse cases, secret scan, and dependency/static analysis.

## Guardrails

Never send production credentials, customer/user data, private source, database dumps, incident details, or contractual material to an unapproved model. Assume generated code can be insecure, subtly incorrect, outdated, or incompatible. Prefer primary documentation for APIs; pin dependencies intentionally; and verify generated citations. Any automation should be repeatable from a clean checkout and reviewed through the same pull-request process as human-written changes.

## What responsible augmentation demonstrates

The relevant skill is not prompt volume. It is the ability to define a bounded engineering problem, evaluate alternatives, detect incorrect output, integrate a maintainable solution, and produce auditable evidence that the result meets its contract.
