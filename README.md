# Glyph

Glyph is a lightweight embedded graphics framework for Ada.

It provides a hardware-independent graphics API for drawing on embedded displays while keeping display drivers and hardware-specific code separate from rendering logic.

The initial development target is the SSD1306 OLED on the RP2040 (Vicharak Shrike-Lite), with support for additional display controllers and microcontrollers planned in future releases.

## Features

- Ada 2022
- Layered architecture
- Hardware-independent graphics API
- Framebuffer-based rendering
- Display driver abstraction
- Designed for bare-metal embedded systems

## Status

Glyph is currently under active development.

The project is in its early stages, with the core architecture and APIs being implemented.

## Project Structure

```text
glyph/
├── config/
├── src/
├── tests/
├── alire.toml
├── glyph.gpr
└── README.md
```

## License

Licensed under the Apache License 2.0.
