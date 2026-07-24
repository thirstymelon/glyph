# Glyph — Embedded Graphics Framework for Ada

[![Alire](https://img.shields.io/badge/alire-0.1.0-blueviolet)](https://alire.ada.dev)
[![Ada 2022](https://img.shields.io/badge/Ada-2022-blue)](https://www.adaic.org)
[![License](https://img.shields.io/badge/license-Apache--2.0-green)](LICENSE)
[![CI](https://img.shields.io/github/actions/workflow/status/glyph-ada/glyph/ci.yml?label=CI)](https://github.com/glyph-ada/glyph/actions)
[![Documentation](https://img.shields.io/badge/docs-latest-lightgrey)](docs/)

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
- Glyph does **not** target displays larger than 1024x1024 in its initial design.

## Current status

**Version 0.1.0** — Project skeleton and documentation. No implementation code yet.

---

## Architecture overview

Glyph is organized as a layered architecture. Each layer communicates only with the layer directly below it.

```
+----------------------------------------------------------+
|                     Application                           |
+----------------------------------------------------------+
|                      Glyph API                            |
+----------------------------------------------------------+
|                      Canvas                               |
+----------------------------------------------------------+
|                      Framebuffer                          |
+----------------------------------------------------------+
|                      Display Driver                       |
+----------------------------------------------------------+
|                   Hardware Abstraction                    |
+----------------------------------------------------------+
|                   Microcontroller                         |
+----------------------------------------------------------+
```

Key architectural rules:

- Applications never call display drivers directly.
- Display drivers never call I2C or SPI directly.
- Each layer defines a public interface consumed by the layer above.
- All layers use static allocation only.

---

## Supported hardware

### Initial target

| Component | Model | Interface |
|-----------|-------|-----------|
| Board | Vicharak Shrike-Lite | — |
| MCU | RP2040 | — |
| Display | SSD1306 128x64 OLED | I2C |

### Planned board support

- Raspberry Pi Pico / Pico 2
- Adafruit Feather RP2040, SparkFun Pro Micro RP2040
- Seeed XIAO RP2040, Waveshare RP2040
- Custom RP2040 boards
- STM32 family (F103, F407, H743, G0 series)
- ESP32 family (ESP32, ESP32-S3, ESP32-C3)
- AVR (Arduino Uno, Mega, Nano)
- RISC-V (ESP32-C3, SiFive HiFive1)

### Planned display support

| Controller | Resolution | Interface | Colour depth | Status |
|------------|------------|-----------|--------------|--------|
| SSD1306 | 128x64, 128x32 | I2C, SPI | 1 bpp | v0.2 |
| SH1106 | 132x64 | I2C, SPI | 1 bpp | v0.8 |
| SSD1327 | 128x128 | I2C, SPI | 4 bpp | Future |
| ST7735 | 160x80 | SPI | 16 bpp | v0.8 |
| ST7789 | 240x240, 320x240 | SPI | 16 bpp | v1.1 |
| ILI9341 | 320x240 | SPI, parallel | 16 bpp | v1.1 |
| ILI9488 | 480x320 | SPI, parallel | 16 bpp | v2.0 |
| GC9A01 | 240x240 | SPI | 16 bpp | v1.1 |
| E-paper | Various | SPI | 1 bpp | v2.0 |

---

## Project structure

```
glyph/
├── .github/              GitHub workflows and templates
├── docs/                 Architecture, guides, tutorials, images
├── examples/             Example applications (01-hello-world, etc.)
├── src/                  Library source code (Ada packages)
├── tests/                Unit, integration, and benchmark tests
├── fonts/                Bitmap font data files
├── tools/                Developer utilities
├── assets/               Graphics assets and test data
├── design/               Design documents and diagrams
├── alire.toml            Alire project manifest
├── README.md             This file
├── LICENSE               Apache 2.0 license
├── CHANGELOG.md          Version history
├── CONTRIBUTING.md       Contribution guide
├── ARCHITECTURE.md       Detailed architecture documentation
├── DESIGN.md             Design decisions and API guidelines
├── ROADMAP.md            Development roadmap
├── CODING_STANDARD.md    Ada coding conventions
├── GOVERNANCE.md         Project governance and maintainers
├── SECURITY.md           Security policies
└── ...                   Additional documentation (see docs/)
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Layered architecture, module responsibilities, dependency rules |
| [DESIGN.md](DESIGN.md) | Design philosophy, engineering principles, API design guidelines |
| [CODING_STANDARD.md](CODING_STANDARD.md) | Ada coding conventions and formatting rules |
| [ROADMAP.md](ROADMAP.md) | Milestones and development plan |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Development workflow, testing, and release process |
| [SECURITY.md](SECURITY.md) | Security policies and vulnerability reporting |
| [GOVERNANCE.md](GOVERNANCE.md) | Project governance and maintainers |
| [docs/](docs/) | In-depth guides, tutorials, and architecture details |

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

## FAQ

**Is Glyph an SSD1306 driver?**

No. Glyph is a complete graphics framework. The SSD1306 driver is one of many possible display backends. Application code written for Glyph can target any supported display without modification.

**What version of Ada does Glyph require?**

Ada 2022. The library uses aspect specifications, contract-based programming, and enhanced generics.

**Does Glyph use dynamic memory allocation?**

No. All memory is statically allocated at compile time. There is no heap allocation after library initialization.

**Does Glyph use floating-point arithmetic?**

No. All rendering algorithms use integer arithmetic, ensuring deterministic execution on MCUs without FPU hardware.

**Does Glyph require an operating system or RTOS?**

No. Glyph is designed for bare-metal embedded systems. In multi-threaded contexts (with an RTOS), the application is responsible for serializing access to the Glyph API.

**Can I test Glyph code without hardware?**

Yes. Core packages can be tested on a host PC. A simulation display driver is planned for end-to-end testing without hardware.

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on:

- Development workflow and branch naming
- Commit message format (Conventional Commits)
- Coding standards and style
- Testing expectations
- Pull request process

All contributors must adhere to the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

Glyph is distributed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full license text.

## Acknowledgements

This project is built on the Ada programming language and the Alire package ecosystem. We thank the Ada community for its continued support of embedded systems development.

## Community

- GitHub Discussions: [glyph-ada/glyph/discussions](https://github.com/glyph-ada/glyph/discussions)
- Issue Tracker: [glyph-ada/glyph/issues](https://github.com/glyph-ada/glyph/issues)
- Maintainers: maintainers@glyph-ada.io

## Future vision

Glyph aspires to be the foundational graphics layer for Ada-based embedded devices — from sensor dashboards and data loggers to interactive control panels and wearable displays. By providing a clean, hardware-independent API backed by deterministic rendering, Glyph enables Ada developers to build reliable graphical interfaces for mission-critical embedded systems.
