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

This is my first embedded graphics framework and my first experience implementing display drivers and rendering algorithms from scratch. Rather than assembling existing libraries, I'm intentionally building every layer myself to gain a deeper understanding of:

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
- **Hardware-independent core** with no BSP, HAL, SDK, or RTOS dependencies
- **Zero dynamic memory allocation** using static memory only
- **Deterministic execution** suitable for bare-metal systems
- **Strong typing** for graphics primitives and geometry
- **Layered architecture** with clear separation of responsibilities
- **Reusable graphics algorithms** independent of display hardware
- **Portable by design** across microcontrollers and display controllers

---

# ✦ Current Status

Glyph has established its core graphics architecture, including clipping, rasterization, framebuffer management, display composition, memory layout abstraction, and hardware verification on a physical RP2040-based target.

## Completed

- ✅ Core project structure and Alire integration
- ✅ Strong scalar and geometric types (`Point`, `Line`, `Rect`, etc.)
- ✅ Liang–Barsky line clipping algorithm
- ✅ Bresenham integer line rasterization algorithm
- ✅ Abstract transport interface
- ✅ Memory layout abstraction
- ✅ SSD1306 page layout implementation
- ✅ Static framebuffer implementation
- ✅ Canvas drawing API
- ✅ SSD1306 display controller
- ✅ High-level display abstraction
- ✅ RP2040 reference application
- ✅ Physical hardware verification on RP2040 + SSD1306

## Planned

- ⏳ Rectangle, circle, and ellipse primitives
- ⏳ Bitmap font rendering
- ⏳ Image rendering
- ⏳ Lightweight UI widgets
- ⏳ SPI transport support
- ⏳ Additional display controllers
- ⏳ Additional framebuffer layouts
- ⏳ Additional pixel formats

---

# ✦ Architecture

```text
               +-------------------+
               |    Application    |
               +---------+---------+
                         |
           +-------------+-------------+
           |                           |
           ▼                           ▼
    +--------------+            +--------------+
    |    Canvas    |            |  Controller  |
    +------+-------+            +------+-------+
           |                           |
           ▼                           |
    +--------------+                   |
    | Framebuffer  |<------------------+
    +------+-------+                   |
           |                           |
           ▼                           ▼
      +-----------+              +---------------+
      |  Layout   |              |   Transport   |
      +-----------+              +---------------+
```

The architecture intentionally separates:

- **Algorithms** — clipping and rasterization
- **Canvas** — drawing primitives
- **Framebuffer** — pixel storage
- **Layouts** — pixel memory mapping
- **Controllers** — display protocols
- **Transport** — hardware communication

For a detailed architectural overview, see **ARCHITECTURE.md**.

---

# ✦ RP2040 Example

A complete reference application is included in the repository under **`rp2040_example/`**.

The example targets a **Vicharak Shrike-Lite (RP2040)** driving a **128×64 SSD1306 OLED** over **I²C**, and demonstrates:

- RP2040 initialization
- Pico_BSP transport implementation
- Display initialization
- Drawing primitives
- Rendering to the display

The example also illustrates the intended separation between Glyph and platform-specific code by implementing the transport layer as application glue.

---

# ✦ Project Structure

```text
glyph/
├── rp2040_example/     -- RP2040 reference application
├── src/
│   ├── algorithms/     -- Graphics algorithms
│   ├── canvas/         -- Drawing API
│   ├── controllers/    -- Display controllers
│   ├── displays/       -- Display composites
│   ├── framebuffer/    -- Framebuffer implementation
│   ├── layouts/        -- Framebuffer memory layouts
│   ├── pixel_formats/  -- Pixel format definitions
│   ├── transport/      -- Hardware transport abstraction
│   ├── glyph.ads
│   └── glyph-types.ads
├── config/
├── ARCHITECTURE.md
├── README.md
├── alire.toml
└── glyph.gpr
```

---

# ✦ License

Glyph is licensed under the **Apache License 2.0**.
