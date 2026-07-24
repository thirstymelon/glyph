# Contributing to Glyph

Thank you for your interest in contributing to Glyph. This document describes the development workflow, conventions, and expectations for contributors.

## Table of contents

- [Code of conduct](#code-of-conduct)
- [Getting started](#getting-started)
- [Development workflow](#development-workflow)
- [Branch naming](#branch-naming)
- [Commit messages](#commit-messages)
- [Coding standards](#coding-standards)
- [Documentation expectations](#documentation-expectations)
- [Testing expectations](#testing-expectations)
- [Pull request process](#pull-request-process)
- [Issue reporting](#issue-reporting)
- [Feature requests](#feature-requests)
- [Review process](#review-process)
- [Community](#community)

## Code of conduct

All contributors must adhere to the [Code of Conduct](CODE_OF_CONDUCT.md). Harassment, disrespectful behavior, and personal attacks will not be tolerated.

## Getting started

1. Fork the repository.
2. Clone your fork:
   ```sh
   git clone https://github.com/your-username/glyph.git
   ```
3. Install prerequisites:
   - GNAT Ada compiler (FSF GNAT 12+ or GNAT Community 2021+)
   - Alire package manager (v2.0+)
4. Build the project:
   ```sh
   cd glyph
   alr build
   ```
5. Run the test suite:
   ```sh
   alr test
   ```

## Development workflow

1. Create a feature branch from `main`.
2. Make your changes following the coding standards.
3. Write or update tests.
4. Run the full test suite locally.
5. Commit with a descriptive message (see below).
6. Push your branch and open a pull request against `main`.

## Branch naming

Branches should follow this naming convention:

```
<type>/<short-description>
```

Types:

- `feat/` — New feature
- `fix/` — Bug fix
- `docs/` — Documentation changes
- `refactor/` — Code refactoring with no functional change
- `test/` — Test additions or changes
- `perf/` — Performance improvements
- `ci/` — CI pipeline changes
- `chore/` — Maintenance tasks

Examples:

- `feat/ssd1306-i2c-driver`
- `fix/framebuffer-off-by-one`
- `docs/architecture-diagrams`
- `test/canvas-clipping`

## Commit messages

Glyph uses [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.

Format:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `perf`, `ci`, `chore`

Scope examples: `framebuffer`, `canvas`, `driver-ssd1306`, `text`, `build`, `docs`

Examples:

```
feat(framebuffer): add 16-bit RGB565 pixel format support

fix(driver-ssd1306): correct I2C command byte ordering

docs(architecture): add framebuffer memory model diagram
```

- The description must use imperative present tense ("add", "fix", "update").
- The description must not be capitalized.
- The description must not end with a period.
- A body should explain the motivation and context for the change.
- A footer should reference related issues using "Closes #123" or "Related to #456".

## Coding standards

Ada source code must follow the conventions defined in [CODING_STANDARD.md](CODING_STANDARD.md) and [STYLE_GUIDE.md](STYLE_GUIDE.md).

Key requirements:

- 3-space indentation, no tabs.
- Descriptive, unambiguous names for packages, types, and subprograms.
- Inline documentation (comments) for all public subprograms and types.
- No heap allocation after initialization.
- No floating-point arithmetic in rendering paths.
- No unbounded recursion.
- All subprograms must have preconditions and postconditions where applicable.

### Pre-commit hooks

Install pre-commit hooks to automate style checks:

```sh
pip install pre-commit
pre-commit install
pre-commit install --hook-type commit-msg
```

## Documentation expectations

- Every public API subprogram must have a comment block describing its purpose, parameters, return value, and exceptions.
- Changes to the public API must be reflected in the relevant documentation files.
- New features should include a tutorial or example if applicable.
- Documentation is written in Markdown and stored in `docs/`.
- Diagrams should be maintained in `design/` and referenced from documentation.

## Testing expectations

- All new code must have accompanying tests.
- Bug fixes must include a regression test.
- Test files reside in `tests/` following the same package hierarchy as `src/`.
- All tests must pass before a pull request can be merged.
- Tests should cover:
  - Normal operation (happy path)
  - Edge cases (boundary values, empty buffers, etc.)
  - Error conditions (invalid parameters, communication failures)

See [TESTING.md](TESTING.md) for the full testing strategy.

## Pull request process

1. Open a pull request against the `main` branch.
2. Use the pull request template. Fill in all sections.
3. Ensure the title follows conventional commit format.
4. Ensure all CI checks pass.
5. Ensure test coverage meets project standards.
6. Request review from at least one maintainer.
7. Address all review comments.
8. Squash commits if requested by a maintainer.

### Pull request checklist

Before submitting, confirm:

- [ ] Code follows the coding standard and style guide.
- [ ] All public APIs are documented with comments.
- [ ] Tests cover the new functionality.
- [ ] All existing tests pass.
- [ ] Documentation is updated (if applicable).
- [ ] The branch is up to date with `main`.
- [ ] The commit messages follow conventional commit format.
- [ ] No debug code, commented-out code, or print statements remain.

## Issue reporting

Report bugs or request features through the [GitHub issue tracker](https://github.com/glyph-ada/glyph/issues).

### Bug reports

Include:

- A clear, descriptive title.
- Steps to reproduce the issue.
- Expected behavior and actual behavior.
- Environment details (board, compiler version, display).
- Logs or error messages if available.
- A minimal code example if possible.

### Feature requests

Include:

- A clear, descriptive title.
- The problem the feature would solve.
- A sketch of the proposed API or behavior.
- Any relevant context or prior art.

## Review process

1. A maintainer reviews the pull request within 5 business days.
2. Review feedback may request changes, ask questions, or approve.
3. All conversations must be resolved before merging.
4. At least one maintainer approval is required.
5. The reviewer will merge the pull request after final approval.

## Community

- GitHub Discussions: For questions, ideas, and community support.
- Issue Tracker: For confirmed bugs and accepted feature requests.
- Maintainers are reachable via maintainers@glyph-ada.io for sensitive matters.
