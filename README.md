# ✦ Glyph

Glyph is a lightweight, portable graphics framework for bare-metal and embedded systems, written in **Ada 2022**.

Glyph is completely independent of any BSP, HAL, SDK, or RTOS, making it portable across embedded platforms.

Development currently targets the **Vicharak Shrike-Lite (RP2040)** with an **SSD1306 128×64 OLED** over **I²C**, while the architecture is designed to support additional display controllers, transports, memory layouts, and pixel formats as the framework evolves.

---

# ✦ AI Disclosure

Glyph is designed, implemented, and maintained by me as a personal learning project. AI tools are used to assist with architecture discussions, documentation, brainstorming, and code reviews, while all design decisions, implementation, testing, and final review remain my responsibility.

---

# ✦ About the Project

Glyph is both an open-source graphics framework and a personal learning project.

This is my first embedded graphics framework and my first experience implementing display drivers, rendering algorithms, and graphics abstractions from scratch. Rather than assembling existing libraries, I'm intentionally building every layer myself to gain a deeper understanding of:

- Embedded graphics
- Display controller protocols
- Ada framework design
- Bare-metal software architecture

While I'm not looking for code contributions that implement features on my behalf, I greatly appreciate:

- Architecture reviews
- Ada best practices
- Design discussions
- Documentation improvements
- Bug reports
- Constructive feedback

The goal is to learn by building while creating a useful graphics framework for the Ada embedded community.

---

# ✦ Design Principles

Glyph is built around a small set of core principles:

- **Ada 2022** throughout the entire codebase
- **Hardware-independent graphics core**
- **Zero dynamic memory allocation**
- **Deterministic execution**
- **Strong type safety**
- **Layered architecture**
- **Reusable graphics algorithms**
- **Portable across embedded platforms**

For a detailed explanation of the framework architecture, see **[ARCHITECTURE.md](ARCHITECTURE.md)**.

---

# ✦ Current Features

Glyph currently provides:

- Pixel drawing
- Line drawing
- Rectangle drawing
- Filled rectangle drawing
- Liang–Barsky line clipping
- Bresenham integer line rasterization
- Rectangle rasterization algorithms
- Static framebuffer
- Display memory layout abstraction
- SSD1306 display controller
- High-level display abstraction
- Hardware-independent transport interface

---

# ✦ Current Status

## Completed

- ☑ Core project structure
- ☑ Alire integration
- ☑ Strong scalar and geometric types (`Point`, `Line`, `Rect`, etc.)
- ☑ Liang–Barsky line clipping
- ☑ Bresenham line rasterization
- ☑ Rectangle primitive
- ☑ Filled rectangle primitive
- ☑ Generic graphics algorithm framework
- ☑ Static framebuffer implementation
- ☑ Memory layout abstraction
- ☑ SSD1306 page layout
- ☑ SSD1306 display controller
- ☑ Transport abstraction
- ☑ High-level display abstraction
- ☑ RP2040 reference application
- ☑ Verified on physical RP2040 + SSD1306 hardware

## Planned

### Graphics

- ☐ Circle
- ☐ Filled Circle
- ☐ Ellipse
- ☐ Filled Ellipse
- ☐ Triangle
- ☐ Filled Triangle

### Rendering

- ☐ Partial display updates
- ☐ Dirty rectangle tracking
- ☐ Region clipping
- ☐ Optimized framebuffer flushing

### Text & Images

- ☐ Bitmap fonts
- ☐ UTF-8 text rendering
- ☐ Image rendering

### Hardware

- ☐ SPI transport
- ☐ Additional display controllers
- ☐ Additional framebuffer layouts
- ☐ Additional pixel formats

### UI

- ☐ Lightweight embedded UI widgets

---

# ✦ RP2040 Example

A complete reference application is included in **`rp2040_example/`**.

The example demonstrates:

- RP2040 initialization
- Pico_BSP transport implementation
- SSD1306 initialization
- Drawing primitives
- Rendering to the display

It also illustrates the intended separation between Glyph and platform-specific code by implementing the transport layer as application glue.

---

# ✦ Project Structure

```text
glyph/
├── rp2040_example/
├── src/
│   ├── algorithms/
│   │   ├── bresenham/
│   │   ├── liang_barsky/
│   │   └── rectangle/
│   ├── canvas/
│   │   └── rectangle/
│   ├── controllers/
│   ├── displays/
│   ├── framebuffer/
│   ├── layouts/
│   ├── pixel_formats/
│   ├── transport/
│   ├── glyph.ads
│   └── glyph-types.ads
├── config/
├── ARCHITECTURE.md
├── README.md
├── alire.toml
└── glyph.gpr
```

---

# ✦ Goals

Glyph aims to become a reusable graphics framework for embedded Ada systems by providing:

- Clean and strongly typed APIs
- Hardware-independent graphics primitives
- Efficient rendering algorithms
- Portable display abstractions
- Static memory usage
- Deterministic execution

---

# ✦ Non-Goals

Glyph is **not** intended to provide:

- Desktop GUI frameworks
- GPU acceleration
- Dynamic memory allocation
- Operating system integration
- Window management
- Scene graphs

The primary focus remains small embedded systems and microcontrollers.

---

# ✦ License

Glyph is licensed under the **Apache License 2.0**.
