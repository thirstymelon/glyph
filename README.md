# ✦ Glyph

Glyph is a lightweight embedded graphics framework written in Ada for bare-metal and embedded systems.

The framework is designed around deterministic memory usage, static allocation, and a layered architecture that cleanly separates graphics algorithms from display controller implementations and platform-specific hardware.

Glyph is being built as a reusable graphics library rather than a board-specific display driver. Its goal is to provide a clean, portable foundation for embedded graphics while remaining independent of any BSP, HAL, SDK, or RTOS.

The initial development target is the SSD1306 OLED display on the RP2040 (Vicharak Shrike-Lite), but the architecture is intended to support additional display controllers, transport mechanisms, and microcontrollers in future releases.

# ✦ A Note from the Author

> Glyph is my first embedded graphics framework and my first experience writing display drivers from scratch. I'm building this project while learning Ada, with the goal of gaining a deep understanding of graphics programming, embedded systems, and framework design through hands-on implementation.
>
> I'm intentionally implementing every part of the framework myself, so I'm **not looking for direct feature implementations or pull requests that write the code for me**. The learning journey is the primary objective of this project.
>
> I genuinely welcome architectural discussions, Ada best practices, design reviews, documentation improvements, bug reports, and constructive feedback. If you think something can be designed better, I'd love to hear your ideas.

## ✦ Design Goals

- Written in Ada 2022
- Portable graphics framework
- Hardware independent
- Static memory allocation only
- Compile-time configuration where practical
- Layered architecture
- Deterministic behaviour
- Stable public APIs
- Designed for bare-metal embedded systems

## ✦ Current Status

Glyph is in the architectural foundation stage.

The public package structure has been established and the framework is currently being built from the lowest layers upward.

### Completed

- Core project structure
- Fundamental types
- Pixel format definitions
- Initial package hierarchy
- Overall architecture

### In Progress

- Framebuffer implementation
- Canvas API

### Planned

- Drawing primitives
- SSD1306 controller
- Fonts
- Images
- Widgets
- Additional display controllers
- Color display support

## ✦ Architecture

```text
Application
      │
      ▼
+---------------+
|  Controller   |
+-------+-------+
        │
        ▼
+---------------+
|    Canvas     |
+-------+-------+
        │
        ▼
+---------------+
| Framebuffer   |
+---------------+
```

The graphics framework owns:

- Drawing algorithms
- Framebuffers
- Display controller implementations

Platform-specific hardware access is intentionally kept outside of Glyph.

## ✦ Project Structure

```text
glyph/
├── config/
├── src/
│   ├── canvas/
│   ├── controllers/
│   ├── framebuffer/
│   ├── pixel_formats/
│   ├── glyph.ads
│   └── glyph-types.ads
├── ARCHITECTURE.md
├── README.md
├── alire.toml
└── glyph.gpr
```

## ✦ Roadmap

- ✅ Core project structure
- ✅ Architecture
- ✅ Package hierarchy
- ⏳ Framebuffer
- ⏳ Canvas
- ⏳ Drawing primitives
- ⏳ SSD1306 controller
- ⏳ Font rendering
- ⏳ Image rendering
- ⏳ Widgets
- ⏳ Additional display controllers
- ⏳ Color display support

## ✦ License

Licensed under the Apache License 2.0.
