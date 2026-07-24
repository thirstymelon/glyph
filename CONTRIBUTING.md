# Contributing to Glyph

Thank you for your interest in contributing to Glyph. This document describes the development workflow, conventions, and expectations for contributors.

## Table of contents

- [Code of conduct](#code-of-conduct)
- [Getting help](#getting-help)
- [Getting started](#getting-started)
- [Development workflow](#development-workflow)
- [Branch naming](#branch-naming)
- [Commit messages](#commit-messages)
- [Coding standards](#coding-standards)
- [Documentation expectations](#documentation-expectations)
- [Testing expectations](#testing-expectations)
- [Versioning](#versioning)
- [Release process](#release-process)
- [Pull request process](#pull-request-process)
- [Issue reporting](#issue-reporting)
- [Feature requests](#feature-requests)
- [Review process](#review-process)

## Code of conduct

All contributors must adhere to the [Code of Conduct](CODE_OF_CONDUCT.md). Harassment, disrespectful behavior, and personal attacks will not be tolerated.

## Getting help

### GitHub Discussions

Use [GitHub Discussions](https://github.com/glyph-ada/glyph/discussions) for:

- Questions about using Glyph.
- Ideas for new features.
- Showcasing projects built with Glyph.
- General discussion.

### GitHub Issues

Use the [GitHub issue tracker](https://github.com/glyph-ada/glyph/issues) for:

- Bug reports (use the bug report template).
- Feature requests (use the feature request template).
- Confirmed issues that require code changes.

### Security vulnerabilities

Report security vulnerabilities privately to maintainers@glyph-ada.io. See [SECURITY.md](SECURITY.md) for the security policy.

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

Types: `feat/`, `fix/`, `docs/`, `refactor/`, `test/`, `perf/`, `ci/`, `chore/`

Examples:

- `feat/ssd1306-i2c-driver`
- `fix/framebuffer-off-by-one`
- `docs/architecture-diagrams`
- `test/canvas-clipping`

## Commit messages

Glyph uses [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.

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
- The description must not be capitalized or end with a period.
- A body should explain the motivation and context for the change.
- A footer should reference related issues using "Closes #123" or "Related to #456".

## Coding standards

Ada source code must follow the conventions defined in [CODING_STANDARD.md](CODING_STANDARD.md).

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

### Testing levels

**Unit tests** verify individual subprograms and packages in isolation. They run on the host PC and do not require hardware. Every public subprogram in the core packages should have at least one happy-path test.

**Integration tests** verify interactions between packages. They test that the Canvas correctly calls Framebuffer operations, that Drawing primitives produce correct pixel patterns, and that data flows correctly through the rendering pipeline.

**Hardware tests** run on target microcontrollers with actual displays attached. They validate that display drivers correctly communicate with the display controller and produce visible output.

**Simulation tests** use a simulation framebuffer that renders to a host-PC memory buffer instead of a real display, allowing end-to-end testing without hardware.

### Test organization

```
tests/
  unit/
    glyph-types_tests.ads
    glyph-types_tests.adb
    glyph-framebuffer-mono_tests.ads
    ...
  integration/
    glyph-rendering-pipeline_tests.ads
    ...
  benchmarks/
    framebuffer_benchmark.adb
    drawing_benchmark.adb
    ...
```

Test file names mirror source file names with a `_tests` suffix.

### Test framework

Glyph uses **AUnit** as the primary test framework. Each test should follow the Arrange-Act-Assert pattern:

```ada
procedure Test_Fill_Buffer (T : in out AUnit.Test_Cases.Test_Case'Class) is
   FB : Framebuffer (128, 64);  --  Arrange
begin
   Fill (FB, White);            --  Act
   Assert (FB.Get_Pixel (0, 0) = White, "Pixel should be white after fill");  --  Assert
   Assert (FB.Get_Pixel (127, 63) = White, "Last pixel should also be white");
end Test_Fill_Buffer;
```

### Test coverage

- Every public subprogram must have at least one happy-path test.
- Boundary conditions must be tested: minimum, maximum, and out-of-range values.
- Empty scenarios must be tested: zero-length line, zero-size rectangle.
- Side effects must be tested: verify the subprogram modifies intended state without modifying other state.

### Regression tests

When a bug is fixed, a regression test must be added to verify the bug no longer occurs and the fix does not break existing behaviour.

## Versioning

Glyph follows [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

```
MAJOR.MINOR.PATCH
```

- **MAJOR** — Incompatible API changes.
- **MINOR** — Backward-compatible new functionality.
- **PATCH** — Backward-compatible bug fixes.

Breaking changes include: removal or renaming of a public type, subprogram, or package; signature changes; behavioural changes that violate documented contracts. Non-breaking changes include: addition of new types or subprograms; addition of defaulted parameters; changes to private internals.

All notable changes are documented in [CHANGELOG.md](CHANGELOG.md) following the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

## Release process

### Preparation (1-2 weeks before release)

- Ensure all planned features are merged to `main`.
- Ensure all tests pass on both host PC and target hardware.
- Review and update documentation for any API changes.
- Update [CHANGELOG.md](CHANGELOG.md) and [ROADMAP.md](ROADMAP.md).
- Tag a release candidate (`vX.Y.Z-rc.1`) for community testing.

### Final release

- Create a signed Git tag: `git tag -s vX.Y.Z -m "vX.Y.Z"`.
- Push the tag: `git push origin vX.Y.Z`.
- Create a GitHub Release from the tag with a summary of changes.
- Publish the updated crate to Alire: `alr publish`.
- Update the version in `alire.toml` to the next development version (e.g., `0.2.0` to `0.3.0-dev`).
- Close the release milestone on GitHub.

## Pull request process

1. Open a pull request against the `main` branch.
2. Use the pull request template. Fill in all sections.
3. Ensure the title follows conventional commit format.
4. Ensure all CI checks pass.
5. Request review from at least one maintainer.
6. Address all review comments.
7. Squash commits if requested by a maintainer.

### Pull request checklist

Before submitting, confirm:

- [ ] Code follows the coding standard.
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

**Before reporting**, please search existing issues and verify you are using a supported version.

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
