# Glyph — Embedded Graphics Framework for Ada

[![Alire](https://img.shields.io/badge/alire-0.1.0-blueviolet)](https://alire.ada.dev)
[![Ada 2022](https://img.shields.io/badge/Ada-2022-blue)](https://www.adaic.org)
[![License](https://img.shields.io/badge/license-Apache--2.0-green)](LICENSE.md)
[![CI](https://img.shields.io/github/actions/workflow/status/glyph-ada/glyph/ci.yml?label=CI)](https://github.com/glyph-ada/glyph/actions)
[![Documentation](https://img.shields.io/badge/docs-latest-lightgrey)](docs/)
[![GitHub](https://img.shields.io/github/v/release/glyph-ada/glyph)](https://github.com/glyph-ada/glyph/releases)

---

## Vision

Glyph aims to become the standard embedded graphics framework in the Ada ecosystem — a portable, deterministic, and maintainable library for rendering graphics on microcontroller-driven displays.

## Mission

Provide a hardware-independent layered graphics architecture that separates application logic from display hardware, enabling Ada developers to build graphical user interfaces for embedded systems with zero dynamic allocation after initialization.

## Goals

- Provide a clean, layered graphics architecture for embedded Ada applications.
- Support multiple display controllers through a unified driver interface.
- Enable zero-dynamic-allocation operation after initialization.
- Implement integer-only rendering algorithms for deterministic performance.
- Deliver a complete rendering pipeline: primitives, text, images, widgets, and animation.
- Achieve hardware portability across RP2040, STM32, ESP32, AVR, and RISC-V platforms.
- Maintain professional documentation, tests, and CI throughout development.
- Publish as a first-class Alire crate with semantic versioning.

## Non-goals

- Glyph is **not** an SSD1306 driver. The SSD1306 is one possible backend.
- Glyph is **not** a general-purpose GUI toolkit for desktop systems.
- Glyph does **not** use dynamic memory allocation after startup.
- Glyph does **not** depend on an operating system or RTOS.
- Glyph does **not** use floating-point arithmetic in its rendering path.
- Glyph does **not** target displays larger than 1024x1024 pixels in its initial design.

## Current status

**Version 0.1.0** — Project skeleton and documentation. No implementation code yet.

The repository structure, build system, and documentation are in place. Development of the core framebuffer and first display driver are the next milestones.

---

## Features

### Current (v0.1.0)

- Repository structure and project conventions.
- Comprehensive documentation (architecture, design, API guidelines, coding standard).
- Alire project manifest with dependency configuration.
- CI workflow templates.
- Issue and pull request templates.

### Planned

- **Framebuffer**: In-memory pixel buffer with configurable depth and format.
- **Drawing primitives**: Points, lines, rectangles, circles, polygons, and complex shapes.
- **Text rendering**: Bitmap fonts, glyph caching, and variable-width text layout.
- **Image rendering**: Monochrome and indexed-color bitmap blitting.
- **Widget system**: Buttons, labels, progress bars, sliders, and containers.
- **Animation**: Sprite animation, frame sequencing, and hardware-timed updates.
- **Display abstraction**: Unified driver API supporting multiple display controllers.
- **Hardware abstraction layer**: I2C, SPI, and parallel interface abstraction.
- **Desktop simulation**: Run and debug Glyph applications on a host PC.

---

## Architecture overview

Glyph is organized as a layered architecture. Each layer communicates only with the layer directly below it.

```
+----------------------------------------------------------+
|                     Application                           |
+----------------------------------------------------------+
|                      Glyph API                            |
|   (High-level drawing, widgets, text, animation)         |
+----------------------------------------------------------+
|                      Canvas                               |
|   (Coordinate transforms, clipping, composition)         |
+----------------------------------------------------------+
|                      Framebuffer                          |
|   (Pixel buffer, pixel ops, blitting)                    |
+----------------------------------------------------------+
|                      Display Driver                       |
|   (Controller-specific protocol: SSD1306, ST7735, etc.)  |
+----------------------------------------------------------+
|                   Hardware Abstraction                    |
|   (I2C, SPI, parallel, GPIO, timers)                     |
+----------------------------------------------------------+
|                   Microcontroller                         |
|   (RP2040, STM32, ESP32, AVR, RISC-V)                   |
+----------------------------------------------------------+
```

Key architectural rules:

- Applications never call display drivers directly.
- Display drivers never call I2C or SPI directly.
- Each layer defines a public interface consumed by the layer above.
- All layers use static allocation only.
- The framebuffer is a plain 2D pixel array with no external dependencies.

---

## Supported hardware

### Initial target

| Component | Model |
|-----------|-------|
| Board     | Vicharak Shrike-Lite |
| MCU       | RP2040 |
| Display   | SSD1306 128x64 OLED |
| Interface | I2C |

### Planned board support

- Raspberry Pi Pico / Pico 2
- Adafruit Feather RP2040
- SparkFun Pro Micro RP2040
- Seeed XIAO RP2040
- Waveshare RP2040
- Custom RP2040 boards
- STM32 family
- ESP32 family
- AVR (Arduino)
- RISC-V (ESP32-C3, etc.)

### Planned display support

- SSD1306 (128x64, 128x32, I2C/SPI)
- SH1106 (132x64, I2C/SPI)
- SSD1327 (128x128, I2C/SPI)
- ST7735 (160x80, SPI)
- ST7789 (240x240, 320x240, SPI)
- ILI9341 (320x240, SPI/parallel)
- ILI9488 (480x320, SPI/parallel)
- GC9A01 (240x240, SPI)
- E-paper displays (various resolutions)

---

## Installation

### Prerequisites

- GNAT Ada compiler (GNAT Community 2021 or later, or FSF GNAT 12+)
- Alire package manager (v2.0 or later)
- A supported board or simulation environment

### Via Alire

```sh
# Placeholder — will publish to Alire after v0.2
alr get glyph
```

### Manual build

```sh
git clone https://github.com/glyph-ada/glyph.git
cd glyph
alr build
```

---

## Quick start

```ada
-- Placeholder — basic example will be added in v0.2
with Glyph;

procedure Demo is
begin
   null;
end Demo;
```

---

## Project structure

```
glyph/
├── .github/              GitHub workflows, issue templates, PR templates
├── docs/                 Documentation (architecture, guides, tutorials, API)
├── examples/             Complete example applications
├── src/                  Library source code (Ada packages)
├── tests/                Unit tests, integration tests, benchmarks
├── fonts/                Bitmap font data files
├── tools/                Build and development utilities
├── scripts/              Automation scripts
├── assets/               Graphics assets and test data
├── design/               Design documents and diagrams
├── alire.toml            Alire project manifest
├── LICENSE.md            Apache 2.0 license
├── README.md             This file
├── CHANGELOG.md          Version history
├── CONTRIBUTING.md       Contribution guide
├── ARCHITECTURE.md       Detailed architecture documentation
├── DESIGN.md             Design decisions and rationale
├── ROADMAP.md            Development roadmap
├── CODING_STANDARD.md    Ada coding conventions
└── ...                   Additional documentation files
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Layered architecture, module responsibilities, dependency rules |
| [DESIGN.md](DESIGN.md) | Design philosophy, engineering principles, trade-offs |
| [CODING_STANDARD.md](CODING_STANDARD.md) | Ada coding conventions and formatting rules |
| [API_GUIDELINES.md](API_GUIDELINES.md) | Public API design principles and conventions |
| [TESTING.md](TESTING.md) | Testing strategy, unit tests, hardware tests |
| [ROADMAP.md](ROADMAP.md) | Milestones and development plan |
| [STYLE_GUIDE.md](STYLE_GUIDE.md) | Code style reference |
| [SECURITY.md](SECURITY.md) | Security policies and vulnerability reporting |
| [VERSIONING.md](VERSIONING.md) | Version numbering and release policy |
| [docs/](docs/) | In-depth guides, tutorials, and API reference |

---

## Roadmap summary

| Version | Focus |
|---------|-------|
| v0.1    | Project skeleton, documentation, CI |
| v0.2    | Framebuffer, SSD1306 driver, pixel operations |
| v0.3    | Drawing primitives (lines, rectangles, circles) |
| v0.4    | Fonts and text rendering |
| v0.5    | Image rendering and bitmap support |
| v0.6    | Widget system |
| v0.7    | Animation framework |
| v0.8    | Display abstraction layer |
| v0.9    | Performance optimization and hardening |
| v1.0    | Stable release with documentation complete |

See [ROADMAP.md](ROADMAP.md) for the full plan through v2.0.

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on:

- Development workflow and branch naming
- Commit message format (Conventional Commits)
- Coding standards and style
- Testing expectations
- Pull request process

All contributors must adhere to the [Code of Conduct](CODE_OF_CONDUCT.md).

## Code style

Ada source code follows the conventions defined in [CODING_STANDARD.md](CODING_STANDARD.md) and [STYLE_GUIDE.md](STYLE_GUIDE.md). Key points:

- 3-space indentation, no tabs.
- Descriptive package, type, and subprogram names.
- Pre-commit hooks enforce formatting and linting.
- Inline documentation via Ada comments and GNAT-style annotations.

## License

Glyph is distributed under the Apache License, Version 2.0.

See [LICENSE.md](LICENSE.md) for the full license text.

## Acknowledgements

This project is built on the Ada programming language and the Alire package ecosystem. We thank the Ada community for its continued support of embedded systems development.

## Community

- GitHub Discussions: [glyph-ada/glyph/discussions](https://github.com/glyph-ada/glyph/discussions)
- Issue Tracker: [glyph-ada/glyph/issues](https://github.com/glyph-ada/glyph/issues)
- [SUPPORT.md](SUPPORT.md) — Support resources and contact information
- Chat: Coming soon

## Future vision

Glyph aspires to be the foundational graphics layer for Ada-based embedded devices — from sensor dashboards and data loggers to interactive control panels and wearable displays. By providing a clean, hardware-independent API backed by deterministic rendering, Glyph enables Ada developers to build reliable graphical interfaces for mission-critical embedded systems.
