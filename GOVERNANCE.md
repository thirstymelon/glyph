# Governance

This document describes the governance model for the Glyph project.

---

## Project structure

Glyph is a community-driven open-source project. The project is managed by a group of maintainers who oversee development, review contributions, and make decisions about the project's direction.

---

## Roles

### Maintainers

Maintainers are responsible for:

- Reviewing and merging pull requests.
- Triaging and responding to issues.
- Setting the project roadmap and priorities.
- Managing releases.
- Enforcing the code of conduct.
- Onboarding new contributors and maintainers.

Maintainers are listed in [MAINTAINERS.md](MAINTAINERS.md).

### Contributors

Contributors are individuals who submit pull requests, file bug reports, or participate in discussions. Anyone can be a contributor. Contributors who make sustained, high-quality contributions may be invited to become maintainers.

### Users

Users are individuals or organizations using Glyph in their projects. User feedback is valued and influences the project roadmap.

---

## Decision making

Decisions are made through consensus among maintainers. The process:

1. A maintainer or contributor proposes a change (via pull request, issue, or discussion).
2. Maintainers review and discuss the proposal.
3. Consensus is reached through discussion.
4. If consensus cannot be reached, the decision is put to a vote among maintainers.
5. A simple majority vote passes the decision. The project lead (if one exists) has tie-breaking authority.

### Types of decisions

- **Minor changes** (bug fixes, documentation updates, test additions): Approved by any maintainer after review.
- **Major changes** (new features, API changes, architectural changes): Require consensus among maintainers.
- **Governance changes**: Require a unanimous vote of all maintainers.

---

## Release process

See [RELEASE_PROCESS.md](RELEASE_PROCESS.md) for the detailed release process.

Key points:

- Releases are managed by maintainers.
- Versioning follows Semantic Versioning 2.0.0 (see [VERSIONING.md](VERSIONING.md)).
- Release candidates are published for community testing before final releases.

---

## Versioning

Glyph follows Semantic Versioning 2.0.0 as described in [VERSIONING.md](VERSIONING.md).

---

## Community contributions

All contributions are welcome. By contributing, you agree to:

1. License your contributions under the Apache License, Version 2.0.
2. Follow the [Code of Conduct](CODE_OF_CONDUCT.md).
3. Adhere to the [Coding Standard](CODING_STANDARD.md) and [Style Guide](STYLE_GUIDE.md).

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

---

## Long-term goals

1. Establish Glyph as the standard embedded graphics library in the Ada ecosystem.
2. Support a broad range of display controllers and microcontroller platforms.
3. Maintain backward compatibility within major versions.
4. Build a sustainable community of contributors and users.
5. Publish as a first-class Alire crate with professional CI/CD.
6. Provide comprehensive documentation, tutorials, and examples.

---

## Amendments

This governance document may be amended by following the decision-making process for governance changes (unanimous vote of all maintainers).
