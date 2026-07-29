# ✦ Glyph

Glyph is a lightweight embedded graphics framework written in Ada for bare-metal and embedded systems.

Glyph provides a hardware-independent graphics API for embedded displays while keeping rendering logic, display management, controller implementations, transport layers, and hardware access cleanly separated.

The framework is designed around deterministic memory usage, static allocation, and a stable public API suitable for resource-constrained embedded systems.

The initial development target is the SSD1306 OLED display running on the RP2040 (Vicharak Shrike-Lite). The architecture is designed to support additional display controllers, transport interfaces, and microcontrollers in future releases.

# ✦ A Note from the Author
>
> Glyph is my first embedded graphics framework and my first experience writing display drivers from scratch. I'm building this project while learning Ada, with the goal of gaining a deep understanding of graphics programming, embedded systems, and framework design through hands-on implementation.
>
> I'm intentionally implementing every part of the framework myself, so I'm **not looking for direct code contributions or pull requests that implement features for me**. The learning process is the primary goal of this project.
>
> That said, I genuinely welcome feedback on the architecture, design decisions, implementation approach, Ada best practices, documentation, and overall project direction. If you have suggestions, ideas, or see a better way to solve a problem, I'd love to hear them. Thoughtful guidance and discussions are always appreciated.

## ✦ Features

- Written in Ada 2022
- Hardware-independent graphics API
- Layered and modular architecture
- Framebuffer-based rendering
- Immutable display descriptors
- Static memory allocation only
- Stable public API
- Designed for bare-metal embedded systems
- Extensible architecture for future display controllers and pixel formats

## ✦ Current Status

Glyph is under active development.

The architectural foundation of the framework has been completed. The current focus is implementing the rendering engine and display drivers on top of the established architecture.

### Completed

- Core project structure
- Public API
- Display abstraction
- Immutable display descriptors
- Canvas lifecycle
- Internal architecture layers

### In Progress

- Framebuffer implementation

### Planned

- Drawing primitives
- Font rendering
- SSD1306 controller
- I²C transport
- Additional display controllers
- Color display support

## ✦ Architecture

```text
Application
      │
      ▼
+-------------+
|   Canvas    |
+------+------+
       │
       ▼
+-------------+
| Framebuffer |   (Private)
+------+------+
       │
       ▼
+-------------+
|   Display   |
+------+------+
       │
       ▼
+-------------+
| Controllers |   (Private)
+------+------+
       │
       ▼
+-------------+
| Transport   |   (Private)
+------+------+
       │
       ▼
+-------------+
|   BSP/HAL   |
+-------------+
```

## ✦ Project Structure

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
│   ├── controllers/
│   │   ├── glyph-controllers.ads
│   │   └── glyph-controllers.adb
│   ├── display/
│   │   ├── glyph-display.ads
│   │   ├── glyph-display.adb
│   │   ├── glyph-display_profiles.ads
│   │   └── glyph-display_profiles.adb
│   ├── framebuffer/
│   │   ├── glyph-framebuffer.ads
│   │   └── glyph-framebuffer.adb
│   ├── pixel_formats/
│   │   └── glyph-pixel_formats.ads
│   ├── transport/
│   │   ├── glyph-transport.ads
│   │   └── glyph-transport.adb
│   ├── glyph.ads
│   ├── glyph.adb
│   └── glyph-types.ads
├── tests/
├── tools/
├── .gitignore
├── ARCHITECTURE.md
├── alire.toml
├── glyph.gpr
└── README.md
```

## ✦ Roadmap

- ✅ Core architecture
- ✅ Public API
- ✅ Display abstraction
- ✅ Display descriptors
- ⏳ Framebuffer
- ⏳ Drawing primitives
- ⏳ Font rendering
- ⏳ SSD1306 controller
- ⏳ I²C transport
- ⏳ Additional display support
- ⏳ Color display support

## ✦ License

Licensed under the Apache License 2.0.
