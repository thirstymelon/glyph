# Versioning

Glyph follows [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

## Version format

```
MAJOR.MINOR.PATCH
```

- **MAJOR** — Incompatible API changes.
- **MINOR** — Backward-compatible new functionality.
- **PATCH** — Backward-compatible bug fixes.

## Pre-release identifiers

Pre-release versions may use the format `MAJOR.MINOR.PATCH-<pre-release>.<N>`.

Examples:

- `0.2.0-alpha.1`
- `1.0.0-rc.1`

## What constitutes a breaking change

- Removal or renaming of a public type, subprogram, or package.
- Change to the signature of a public subprogram.
- Change to the behaviour of a public subprogram that violates its documented contract.
- Removal of a previously public constant or configuration option.
- Change to the format of a publicly documented data structure.

## What does not constitute a breaking change

- Addition of new public types, subprograms, or packages.
- Addition of new parameters with default values to existing subprograms.
- Changes to private types or subprograms.
- Changes to implementation internals and algorithms.
- Performance improvements.
- Bug fixes that bring behaviour in line with documented contracts.

## Version lifecycle

### Major versions (`X.0.0`)

- Released approximately once per year.
- May contain breaking changes.
- Migration guide provided in release notes.

### Minor versions (`X.Y.0`)

- Released approximately every 2-3 months.
- New features, non-breaking improvements.
- Deprecation warnings for APIs scheduled for removal in the next major version.

### Patch versions (`X.Y.Z`)

- Released as needed.
- Bug fixes, security patches, documentation corrections.
- No new functionality.

## Deprecation process

1. An API is marked deprecated using `pragma Deprecated` with a message indicating the replacement.
2. The deprecated API remains available for the current major version cycle.
3. The deprecated API is removed in the next major version release.

## Pre-release development

During the 0.x development phase (before 1.0.0), minor versions may contain breaking changes. Patch versions should not contain breaking changes, but exceptions may be made during early development.

## Changelog

All notable changes are documented in [CHANGELOG.md](CHANGELOG.md) following the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.
