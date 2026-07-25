# Glyph

Glyph is a lightweight embedded graphics framework written in Ada for bare-metal and embedded systems.

It provides a hardware-independent graphics API for drawing on embedded displays while keeping rendering logic, display drivers, and hardware-specific code cleanly separated.

The initial development target is the SSD1306 OLED display on the RP2040 (Vicharak Shrike-Lite). The architecture is designed to support additional display controllers, transport interfaces, and microcontrollers in future releases.

## Features

- Written in Ada 2022
- Layered and modular architecture
- Hardware-independent graphics API
- Framebuffer-based rendering
- Display driver abstraction
- Designed for bare-metal embedded systems

## Status

Glyph is under active development.

The project is currently focused on establishing the core architecture, graphics framework, and display abstractions before implementing rendering primitives and display drivers.

## Project Structure

```text
glyph/
├── config/
│   ├── glyph_config.ads
│   ├── glyph_config.gpr
│   └── glyph_config.h
├── src/
│   ├── canvas/
│   │   ├── glyph-canvas.ads
│   │   └── glyph-canvas.adb
│   ├── display/
│   │   └── glyph-display.ads
│   ├── pixel_formats/
│   │   └── glyph-pixel_formats.ads
│   ├── glyph.ads
│   ├── glyph.adb
│   └── glyph-types.ads
├── tests/
├── tools/
├── .gitignore
├── alire.toml
├── glyph.gpr
└── README.md
```

## License

Licensed under the Apache License 2.0.
