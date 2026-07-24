# Frequently asked questions

## General

**What is Glyph?**

Glyph is an embedded graphics framework for Ada. It provides a layered architecture for rendering graphics on microcontroller-driven displays. It includes framebuffer management, drawing primitives, text rendering, image support, widget system, animation, and a unified display driver interface.

**Is Glyph an SSD1306 driver?**

No. Glyph is a complete graphics framework. The SSD1306 driver is one of many possible display backends. Application code written for Glyph can target any supported display without modification.

**Why Ada?**

Ada provides strong typing, contract-based programming, deterministic execution, and excellent support for embedded systems. These properties make it well-suited for building reliable graphics libraries for mission-critical and resource-constrained applications.

**What version of Ada does Glyph require?**

Ada 2022. The library makes use of Ada 2022 features including aspect specifications, contract-based programming, and enhanced generics.

## Technical

**Does Glyph use dynamic memory allocation?**

No. All memory is statically allocated at compile time. Framebuffers, driver state, font data, and widget trees use static storage only. There is no heap allocation after library initialization.

**Does Glyph use floating-point arithmetic?**

No. All rendering algorithms use integer arithmetic. This ensures deterministic execution on MCUs without hardware floating-point support.

**What display resolutions are supported?**

The library is designed for displays up to 1024 x 1024 pixels. The framebuffer size is configured at compile time through generic parameters.

**Can I use Glyph with multiple displays simultaneously?**

Yes. The display abstraction layer supports multiple display drivers. Each display has its own framebuffer and driver instance. This is planned for v0.8.

**Does Glyph require an operating system or RTOS?**

No. Glyph is designed for bare-metal embedded systems. It can also be used with an RTOS; the application is responsible for serializing access to the Glyph API in multi-threaded contexts.

**Can I test Glyph code without hardware?**

Yes. Core packages (types, colors, framebuffer, canvas, drawing primitives) can be tested on a host PC. A simulation display driver is planned for end-to-end testing without hardware.

## Development

**When will the first release be available?**

Version 0.1.0 (project skeleton) is available now. Version 0.2.0 (framebuffer and SSD1306 driver) is the next milestone.

**How can I contribute?**

See [CONTRIBUTING.md](CONTRIBUTING.md) for the contribution guide. We welcome contributions of all kinds: code, documentation, testing, and feedback.

**What is the license?**

Apache License, Version 2.0. See [LICENSE.md](LICENSE.md) for the full text.

**How is the project governed?**

See [GOVERNANCE.md](GOVERNANCE.md) for the governance model and [MAINTAINERS.md](MAINTAINERS.md) for the current maintainers.

## Hardware

**What hardware is currently supported?**

The initial target is the Vicharak Shrike-Lite board with an SSD1306 128x64 I2C OLED display. Support for additional boards and displays is planned in future releases.

**What microcontrollers does Glyph support?**

Initially RP2040. Support for STM32, ESP32, AVR, and RISC-V is planned.

**How do I add support for a new display?**

Create a new display driver package implementing the `Glyph.Drivers` interface. See [ARCHITECTURE.md](ARCHITECTURE.md) and the driver development guide in `docs/` for details.

## Support

**Where can I ask questions?**

GitHub Discussions is the primary channel for questions and community support. See [SUPPORT.md](SUPPORT.md) for all support options.

**How do I report a bug?**

Open an issue on GitHub using the bug report template. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on effective bug reports.

**How do I report a security vulnerability?**

Report security vulnerabilities privately to maintainers@glyph-ada.io. See [SECURITY.md](SECURITY.md) for the security policy.
