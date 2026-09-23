# Security policy

## Scope

This repository contains portfolio documentation and illustrative examples, not production infrastructure or the production PickPlay codebase. The examples describe desired controls but should not be interpreted as verification of a deployed security posture.

## Reporting a concern

For an issue limited to these public examples (for example, unsafe sample code), contact the repository owner privately through an appropriate GitHub channel before opening a public issue. Include the affected file, impact, reproduction steps, and a suggested mitigation when possible.

Production security issues must **not** be publicly disclosed in this repository. Do not include exploit details, real endpoints, user information, credentials, logs, or production configuration in an issue or pull request. Contact the system owner through a private, verified channel instead.

## Sensitive material

No production credentials belong in this repository. Contributors must not commit secrets, tokens, environment files, personal data, database dumps, private keys, or proprietary production source. If sensitive material is committed, stop distribution, notify the owner privately, rotate the affected secret at its source, and remove it from Git history; deleting only the latest file is insufficient.

## Safe review

Review samples as educational artifacts. Validate server-side authorization, input handling, temporal rules, dependency health, and deployment configuration in the actual system before relying on them. Avoid testing against systems or data without explicit authorization.
