# Release process

This document describes the steps required to create a Glyph release.

---

## Release frequency

- **Major releases**: Approximately once per year.
- **Minor releases**: Approximately every 2-3 months.
- **Patch releases**: As needed for bug fixes and security issues.

---

## Release checklist

### Preparation (1-2 weeks before release)

- [ ] Ensure all planned features are merged to `main`.
- [ ] Ensure all tests pass on both host PC and target hardware.
- [ ] Review and update documentation for any API changes.
- [ ] Update [CHANGELOG.md](CHANGELOG.md) with all notable changes.
- [ ] Update [ROADMAP.md](ROADMAP.md) to reflect current status (mark completed milestones).
- [ ] Verify that all deprecated APIs have been identified for the release notes.
- [ ] Run performance benchmarks and compare against previous release.
- [ ] Tag a release candidate (`vX.Y.Z-rc.1`) and open a release candidate branch.

### Release candidate (1 week)

- [ ] Announce release candidate on GitHub Discussions.
- [ ] Solicit testing from the community.
- [ ] Fix any bugs identified during RC testing.
- [ ] Repeat RC cycle if breaking changes or significant bugs are found.

### Final release

- [ ] Ensure `main` branch is up to date and all checks pass.
- [ ] Create a signed Git tag: `git tag -s vX.Y.Z -m "vX.Y.Z"`.
- [ ] Push the tag: `git push origin vX.Y.Z`.
- [ ] Create a GitHub Release from the tag.
  - Title: `vX.Y.Z`
  - Description: Summary of changes (can be adapted from CHANGELOG).
  - Attach any release artifacts (Alire crate archive, checksums).
- [ ] Publish the updated crate to Alire: `alr publish`.
- [ ] Update the version in `alire.toml` to the next development version.
- [ ] Close the release milestone on GitHub.
- [ ] Post release announcement on GitHub Discussions.

### Post-release

- [ ] Verify the published crate installs correctly: `alr get glyph`.
- [ ] Update the project website (if applicable).
- [ ] Monitor for bug reports and regressions.
- [ ] Update any downstream examples or tutorials.

---

## Automated release workflow

The release workflow (`.github/workflows/release.yml`) automates:

1. Building the library for multiple targets.
2. Running the full test suite.
3. Generating checksums.
4. Creating the GitHub Release.
5. Publishing to the Alire index.

---

## Branch management

- Releases are cut from the `main` branch.
- Hotfixes for a previous major version are developed on a `release/X.Y.x` branch.
- Patch releases for a previous major version follow the same process on the release branch.

---

## Version bumping

After a release, the version in `alire.toml` is bumped to the next development version with a `-dev` suffix.

Example:

- Current release: `0.2.0`
- Next development version: `0.3.0-dev`

---

## Alire publishing

Publishing to Alire requires:

1. An Alire index maintainer account.
2. The crate manifest (`alire.toml`) to be complete and correct.
3. The crate archive to be uploaded.

```sh
alr publish
```

Follow the Alire publishing guide for detailed instructions.
