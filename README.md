# ✦ Glyph

Glyph is a lightweight, portable graphics framework for bare-metal and embedded systems, written in **Ada 2022**.

Development currently targets the **Vicharak Shrike-Lite (RP2040)** with an **SSD1306 128×64 OLED** over **I²C**. **Pico_BSP is directly integrated into Glyph**, so users no longer need to write custom transport glue code—simply initialize your hardware bus and pass it directly to `OLED.Init`.

The architecture is built on **Generic Static Composition**, allowing support for any display controller, transport bus, memory layout, resolution, and pixel format with zero heap allocation.

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
- **Zero dynamic memory allocation**
- **Deterministic execution**
- **Strong type safety**
- **Layered architecture**
- **Reusable graphics algorithms**
- **Direct BSP integration for ease of use**
- **Extensible display and controller abstractions**

For a detailed explanation of the framework architecture, see **[ARCHITECTURE.md](ARCHITECTURE.md)**.

---

# ✦ Current Features

Glyph currently provides:

- Pixel drawing (`Paint_Pixel`)
- Line drawing (`Paint_Line`)
- Rectangle outline drawing (`Paint_Rectangle`)
- Filled rectangle drawing (`Paint_Filled_Rectangle`)
- Circle outline & sector drawing (`Paint_Circle`)
- Filled circle & filled sector drawing (`Paint_Filled_Circle`)
- Arc curve drawing (`Paint_Arc`)
- Half-circle drawing (`Paint_Half_Circle`, `Paint_Filled_Half_Circle`)
- Triangle outline drawing (`Paint_Triangle`)
- Filled triangle drawing (`Paint_Filled_Triangle`)
- Simple flat integer drawing APIs (`Paint_Circle (100, 20, 12)`, etc.)
- Cohen–Sutherland line clipping with integer outcodes
- Bresenham integer line rasterization with fast orthogonal bypass
- Axis-Aligned Bounding Box (AABB) rectangle rasterization
- Midpoint circle rasterization & scanline filled circle rasterization
- $O(1)$ cross-product vector inclusion testing for arbitrary angular sectors
- Scanline filled triangle rasterization
- Parameterized generic monochrome framebuffers (`Glyph.Canvas.Generic_Mono`)
- Generic display composition engine (`Glyph.Display.Generic_Display`)
- Universal HAL.I2C transport bridge (`Glyph.Transport.I2C`)
- SSD1306 OLED display controller with configurable I2C address
- High-level display abstraction (`OLED.Init`, `OLED.Render`)

---

# ✦ Current Status

## Completed

- ☑ Core project structure
- ☑ Alire integration
- ☑ Strong scalar and geometric types (`Point`, `Line`, `Rectangle`, `Circle`, `Triangle`, `Size`, `Coordinate`, `Angle`, `Hemisphere`)
- ☑ Simple flat integer drawing APIs
- ☑ Cohen–Sutherland line clipping
- ☑ Bresenham line rasterization
- ☑ Fast orthogonal horizontal and vertical line bypass
- ☑ Rectangle primitive
- ☑ Filled rectangle primitive
- ☑ Circle primitive
- ☑ Filled circle primitive
- ☑ Arc primitive
- ☑ Sector & pie wedge primitive
- ☑ Half-circle primitive
- ☑ Triangle primitive
- ☑ Filled triangle primitive
- ☑ Generic graphics algorithm framework
- ☑ Parameterized static monochrome framebuffer (`Generic_Mono`)
- ☑ Generic static display composition engine (`Generic_Display`)
- ☑ SSD1306 display RAM stream layout & controller protocol
- ☑ Universal HAL.I2C transport bridge
- ☑ High-level display abstraction
- ☑ RP2040 reference application with hardware timer (`RP.Device.Timer`)
- ☑ Verified on physical RP2040 (Vicharak Shrike-Lite) + SSD1306 hardware

## Planned

### Graphics

- ☐ Ellipse
- ☐ Filled Ellipse
- ☐ Rounded Rectangle
- ☐ Polygon filling
- ☐ Bézier curves

### Rendering

- ☐ Banded / chunked rendering for large RGB displays
- ☐ Direct streaming mode
- ☐ Partial display updates
- ☐ Dirty rectangle tracking
- ☐ Region clipping
- ☐ Optimized framebuffer flushing

### Text & Images

- ☐ Bitmap fonts
- ☐ UTF-8 text rendering
- ☐ Image / bitmap rendering

### Hardware

- ☐ SPI transport
- ☐ Additional display controllers (SH1106, ST7789, ILI9341, IL0373 E-Ink)
- ☐ Additional framebuffer layouts (RGB565, Grayscale)
- ☐ Additional pixel formats

### UI

- ☐ Lightweight embedded UI widgets

---

# ✦ Reference Example

A complete reference application is included in **`example/`**.

The example demonstrates:

- RP2040 clock & GPIO initialization
- I²C configuration (GP8 SDA, GP9 SCL on I2C0)
- Hardware timer initialization (`RP.Device.Timer.Enable`)
- Passing the hardware I2C port directly to `OLED.Init` without custom glue code
- Drawing primitives (`Paint_Rectangle`, `Paint_Line`, `Paint_Filled_Rectangle`, `Paint_Pixel`, `Paint_Circle`, `Paint_Filled_Circle`, `Paint_Arc`, `Paint_Half_Circle`, `Paint_Filled_Half_Circle`, `Paint_Triangle`, `Paint_Filled_Triangle`)
- Real-time animated cyber dashboard rendering to the display

---

# ✦ Project Structure

```text
glyph/
├── example/
│   ├── config/
│   ├── src/
│   │   └── example.adb
│   ├── alire.toml
│   └── example.gpr
├── src/
│   ├── algorithms/
│   │   ├── glyph-algorithms.ads
│   │   ├── glyph-algorithms-clipping.ads / .adb
│   │   ├── glyph-algorithms-lines.ads / .adb
│   │   ├── glyph-algorithms-rectangle.ads / .adb
│   │   ├── glyph-algorithms-circle.ads / .adb
│   │   └── glyph-algorithms-triangle.ads / .adb
│   ├── canvas/
│   │   ├── glyph-canvas.ads
│   │   ├── generic_mono/
│   │   │   ├── glyph-canvas-generic_mono.ads
│   │   │   └── glyph-canvas-generic_mono.adb
│   │   └── c128x64_mono/
│   │       └── glyph-canvas-c128x64_mono.ads
│   ├── controllers/
│   │   ├── glyph-controllers.ads
│   │   ├── glyph-controllers-ssd1306.ads
│   │   └── glyph-controllers-ssd1306.adb
│   ├── display/
│   │   ├── glyph-display.ads
│   │   ├── glyph-display.adb
│   │   └── generic/
│   │       ├── glyph-display-generic_display.ads
│   │       └── glyph-display-generic_display.adb
│   ├── transport/
│   │   ├── glyph-transport.ads
│   │   ├── i2c/
│   │   │   ├── glyph-transport-i2c.ads
│   │   │   └── glyph-transport-i2c.adb
│   │   └── pico/
│   │       ├── glyph-transport-pico.ads
│   │       └── glyph-transport-pico.adb
│   ├── glyph.ads
│   ├── glyph-types.ads
│   └── glyph-colors.ads
├── ARCHITECTURE.md
├── README.md
├── alire.toml
├── glyph.gpr
└── LICENSE
```

---

# ✦ Goals

Glyph aims to provide:

- Clean and strongly typed Ada 2022 APIs
- Embedded 2D graphics primitives
- Efficient rendering algorithms
- Direct, hassle-free board and driver integration
- Static memory usage with zero heap allocation
- Deterministic execution on bare-metal microcontrollers

---

# ✦ Non-Goals

Glyph is **not** a desktop GUI framework and is **not** intended to provide:

- Desktop window management or OS GUI widgets
- GPU acceleration
- Dynamic memory allocation
- Heavy runtime scene graphs
- Operating system event loops

The sole focus is bare-metal embedded systems and microcontrollers.

---

# ✦ License

Glyph is licensed under the **Apache License 2.0**.
