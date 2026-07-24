# Project structure

This document describes the layout of the Glyph repository and the purpose of each directory and file.

---

## Top-level layout

```
glyph/
├── .github/              GitHub configuration (workflows, templates)
├── docs/                 Documentation
├── examples/             Example applications
├── src/                  Library source code
├── tests/                Test suites
├── fonts/                Bitmap font data
├── tools/                Development tools and utilities
├── scripts/              Automation scripts
├── assets/               Graphics assets and test data
├── design/               Design documents, diagrams, wireframes
├── alire.toml            Alire project manifest
├── .gitignore            Git ignore rules
├── .editorconfig         Editor configuration
├── .gitattributes        Git attribute rules
├── .pre-commit-config.yaml  Pre-commit hook configuration
├── LICENSE.md            Apache 2.0 license
├── README.md             Project overview
├── CHANGELOG.md          Version history
├── CONTRIBUTING.md       Contribution guide
├── CODE_OF_CONDUCT.md    Community standards
├── ARCHITECTURE.md       Architecture documentation
├── DESIGN.md             Design document
├── ROADMAP.md            Development roadmap
├── CODING_STANDARD.md    Ada coding conventions
├── STYLE_GUIDE.md        Code style reference
├── API_GUIDELINES.md     API design principles
├── TESTING.md            Testing strategy
├── SECURITY.md           Security policy
├── VERSIONING.md         Version numbering policy
├── RELEASE_PROCESS.md    Release workflow
├── PROJECT_STRUCTURE.md  This file
├── SUPPORTED_HARDWARE.md Supported hardware list
├── SUPPORTED_DISPLAYS.md Supported display list
├── FAQ.md                Frequently asked questions
├── GOVERNANCE.md         Project governance model
├── MAINTAINERS.md        Current maintainers list
└── SUPPORT.md            Support resources
```

---

## Directory details

### `.github/`

GitHub-specific configuration files.

```
.github/
├── workflows/
│   ├── ci.yml               Continuous integration
│   ├── release.yml          Release automation
│   └── hw_tests.yml         Hardware test runner
├── ISSUE_TEMPLATE/
│   ├── bug_report.yml       Bug report template
│   └── feature_request.yml  Feature request template
├── DISCUSSION_TEMPLATE/
│   └── q_and_a.yml          Q&A discussion template
└── PULL_REQUEST_TEMPLATE.md  Pull request template
```

### `docs/`

Project documentation organized by topic.

```
docs/
├── architecture/      Detailed module architecture documents
│   ├── introduction.md
│   ├── framebuffer.md
│   └── display-drivers.md
├── guides/            How-to guides
│   ├── porting-guide.md
│   └── performance-guide.md
├── tutorials/         Step-by-step tutorials
│   ├── getting-started.md
│   └── widget-tutorial.md
├── images/            Documentation images and diagrams
│   └── glyph-banner-light.png (placeholder)
└── api/               API reference (generated or manual)
    └── index.md
```

### `src/`

Ada source code for the Glyph library. Organized by package hierarchy.

```
src/
├── glyph.ads
├── glyph.adb
├── glyph-types.ads
├── glyph-types.adb
├── glyph-colors.ads
├── glyph-colors.adb
├── glyph-config.ads
├── glyph-canvas.ads
├── glyph-canvas.adb
├── glyph-canvas-clipping.ads
├── glyph-canvas-clipping.adb
├── glyph-framebuffer.ads
├── glyph-framebuffer.adb
├── glyph-framebuffer-mono.ads
├── glyph-framebuffer-mono.adb
├── glyph-display.ads
├── glyph-display.adb
├── glyph-drivers.ads
├── glyph-drivers-ssd1306.ads
├── glyph-drivers-ssd1306.adb
├── glyph-hal.ads
├── glyph-hal-i2c.ads
└── glyph-hal-i2c.adb
```

### `examples/`

Complete, runnable example applications.

```
examples/
├── hello-world/          Minimal Glyph example
│   └── README.md
├── graphics-demo/        Feature demonstration
│   └── README.md
└── sensor-dashboard/     Complex application example
    └── README.md
```

### `tests/`

Test suites organized by level.

```
tests/
├── unit/                 Unit tests (AUnit)
│   ├── glyph-types_tests.ads
│   └── glyph-types_tests.adb
├── integration/          Integration tests
│   └── glyph-rendering_tests.adb
└── benchmarks/           Performance benchmarks
    └── framebuffer_benchmark.adb
```

### `fonts/`

Bitmap font data files in Glyph's internal format.

```
fonts/
├── 5x7.bf               Small system font
├── 8x13.bf              Medium system font
└── 10x20.bf             Large system font
```

### `tools/`

Developer utilities for working with the library.

```
tools/
├── font-converter/       Converts BDF/PCF fonts to Glyph format
├── image-converter/      Converts images to Glyph bitmap data
└── simulator/            Host-PC Glyph simulation environment
```

### `scripts/`

Automation scripts for build, test, and release tasks.

```
scripts/
├── build.sh              Build script for multiple targets
├── test.sh               Run test suite
├── docs-serve.sh         Serve documentation locally
└── release.sh            Automated release script
```

### `assets/`

Source assets used in the project.

```
assets/
├── fonts/                Font source files (BDF, PCF)
├── images/               Image source files (PNG, BMP)
└── test-patterns/        Reference test patterns
```

### `design/`

Design documents and diagrams.

```
design/
├── architecture/         Architecture diagrams
├── wireframes/           UI wireframes for widget system
└── mockups/              Application mockups
```

---

## File naming conventions

See [CODING_STANDARD.md](CODING_STANDARD.md) for Ada file naming rules.

For Markdown documentation:

- All lowercase.
- Words separated by hyphens.
- `.md` extension.
- Descriptive: `porting-guide.md`, not `guide-1.md`.
