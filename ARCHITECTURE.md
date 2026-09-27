# ✦ Glyph Architecture

## Overview

Glyph is a 2D graphics framework for bare-metal embedded systems.

The framework follows a strict layered architecture that separates graphics algorithms, drawing operations, framebuffer management, display memory layouts, display controllers, and transport communication.

Each layer has a single responsibility and communicates only with the layer directly beneath it. **Pico_BSP is directly integrated into Glyph**, allowing applications to pass the hardware bus directly to display initialization without writing separate transport glue code.

Glyph is **not** a desktop GUI framework; its focus is deterministic, zero-allocation 2D rendering for resource-constrained microcontrollers.

---

# ✦ Design Objectives

The architecture is guided by the following principles:

- Zero dynamic memory allocation
- Deterministic execution
- Strong type safety
- Static composition through Ada generics
- Clear package responsibilities
- Reusable graphics algorithms
- Direct BSP integration for seamless hardware startup
- Minimal coupling between layers

---

# ✦ System Architecture

```text
                              Application
                                    │
                                    ▼
                           +----------------+
                           |    Display     |
                           +-------+--------+
                                   │
                 +-----------------+-----------------+
                 │                                   │
                 ▼                                   ▼
          +--------------+                  +---------------+
          |    Canvas    |                  |  Controller   |
          +------+-------+                  +-------+-------+
                 │                                  │
                 ▼                                  │
          +--------------+                          │
          |  Algorithms  |                          │
          +------+-------+                          │
                 │                                  │
                 ▼                                  ▼
          +--------------+                  +---------------+
          | Framebuffer  |                  |   Transport   |
          +------+-------+                  +-------+-------+
                 │                                  │
                 ▼                                  ▼
          +--------------+                   Display Hardware
          |    Stream    |
          +--------------+
```

---

# ✦ Rendering Pipeline

Every drawing primitive follows the same rendering pipeline.

```text
Paint_Primitive(...)
        │
        ▼
Canvas
        │
        ▼
Graphics Algorithm
        │
        ▼
Plot() / Fill_Row()
        │
        ▼
Packed Framebuffer
        │
        ▼
RAM Stream Formatter
        │
        ▼
Controller Flush
        │
        ▼
Transport
        │
        ▼
Display
```

Each stage performs exactly one task and remains independent from the others.

---

# ✦ Example Rendering Pipelines

## Line

```text
Paint_Line()
      │
      ▼
Cohen–Sutherland
(Line Clipping)
      │
      ▼
Bresenham / Fast Orthogonal
(Line Rasterization)
      │
      ▼
Plot()
```

---

## Rectangle

```text
Paint_Rectangle() / Paint_Filled_Rectangle()
       │
       ▼
AABB Bounding Box Clipping
       │
       ▼
Horizontal / Vertical Span Rasterization
       │
       ▼
Plot() / Fill_Row()
```

---

## Circle, Arc & Sector

```text
Paint_Circle() / Paint_Filled_Circle() / Paint_Arc() / Paint_Half_Circle()
       │
       ▼
Midpoint Circle Step & Cross-Product Sector Inclusion
       │
       ▼
Symmetric Octant Plotting / Horizontal Scanline Span Fill
       │
       ▼
Plot() / Fill_Row()
```

---

## Triangle

```text
Paint_Triangle() / Paint_Filled_Triangle()
       │
       ▼
Vertex Y-Sorting & Edge DDA Interpolation
       │
       ▼
3-Edge Line Rasterization / Horizontal Scanline Span Fill
       │
       ▼
Plot() / Fill_Row()
```

---

# ✦ Package Organization

```text
Glyph
│
├── Types (Points, Lines, Rectangles, Circles, Triangles, Angles, Hemispheres)
├── Colors (Monochrome, Grayscale, RGB888)
├── Algorithms
│   ├── Clipping (Cohen–Sutherland Line Clipping)
│   ├── Lines (Bresenham & Fast Orthogonal)
│   ├── Rectangle (AABB Scanline Rasterizer)
│   ├── Circle (Midpoint Rasterizer, Arc & Sector Includer)
│   └── Triangle (3-Edge Lines & Scanline Span Filler)
├── Canvas
│   ├── Generic_Mono (Parameterized Monochrome Framebuffer)
│   └── C128x64_Mono (Pre-instantiated 128×64)
├── Controllers
│   └── SSD1306 (Configurable Address OLED Controller)
├── Transport
│   ├── I2C (HAL.I2C Master Transmit Bridge)
│   └── Pico (Backward Compatibility Alias)
└── Display
    ├── Generic_Display (Generic Static Composition Engine)
    └── Glyph.Display (High-Level User Facade)
```

---

# ✦ Package Responsibilities

## Glyph.Types & Glyph.Colors

Defines the fundamental geometric and color types used throughout the framework.

Examples include:

- Coordinates
- Dimensions
- Points
- Lines
- Rectangles
- Circles
- Triangles
- Angles
- Hemispheres (`Top`, `Bottom`, `Left`, `Right`)
- Pixel colors (`Monochrome`, `Grayscale`, `RGB888`)

These packages form the foundation of Glyph and have no dependencies on other Glyph packages.

---

## Glyph.Algorithms

Contains reusable, pure graphics algorithms.

Algorithms are completely independent of:

- Canvas
- Framebuffer memory layouts
- Controllers
- Displays
- Transport hardware

Current algorithms include:

- **Cohen–Sutherland Line Clipping:** Instant $O(1)$ bitwise trivial-accept checking with integer outcodes (`INSIDE`, `LEFT`, `RIGHT`, `BOTTOM`, `TOP`).
- **Bresenham Line Rasterization:** Pure integer decision variable calculation with dedicated fast-paths for $0^\circ$ horizontal and $90^\circ$ vertical lines.
- **Rectangle Rasterization:** Axis-Aligned Bounding Box (AABB) intersection clipping with row-by-row span filling.
- **Circle, Arc & Sector Rasterization:** Exact midpoint integer decision step for 8-way symmetric outlines and non-overlapping horizontal scanline fills, with $O(1)$ cross-product vector inclusion testing for arbitrary angular sweeps and pie wedges.
- **Triangle Rasterization:** 3-edge line rasterization for outlines and scanline edge interpolation for filled triangles.

Future algorithms may include:

- Midpoint Ellipse
- Rounded Rectangle
- Polygon filling
- Bézier curves

---

## Glyph.Canvas

Canvas exposes the public drawing API and manages pixel memory.

It coordinates graphics algorithms with framebuffer operations while keeping drawing logic clean and minimal.

Canvas is responsible for:

- Public drawing primitives (`Paint_Pixel`, `Paint_Line`, `Paint_Rectangle`, `Paint_Filled_Rectangle`, `Paint_Circle`, `Paint_Filled_Circle`, `Paint_Arc`, `Paint_Half_Circle`, `Paint_Filled_Half_Circle`, `Paint_Triangle`, `Paint_Filled_Triangle`)
- Viewport boundary clipping management
- Algorithm instantiation
- Pixel plotting callback generation
- Generic stream layout formatting (`Fill_Page_Stream`)

Current implementations:

- `Glyph.Canvas.Generic_Mono (Width, Height)`: Generic 1-bit packed monochrome framebuffer for arbitrary dimensions.
- `Glyph.Canvas.C128x64_Mono`: Pre-instantiated 1-bit packed 128×64 framebuffer (1,024 bytes).

Future primitives:

- `Paint_Ellipse`, `Paint_Filled_Ellipse`
- `Paint_Rounded_Rectangle`

---

## Glyph.Controllers

Controller packages understand the protocol and command set of specific display controllers.

Responsibilities include:

- Display power sequencing and initialization
- Charge pump and DC-DC converter configuration
- Addressing mode and window boundary configuration
- Framebuffer flushing to hardware bus

Controllers never implement graphics algorithms or store user framebuffers.

Current controller:

- `Glyph.Controllers.SSD1306` (with configurable I2C slave address)

---

## Glyph.Transport

Defines the hardware communication interface.

Glyph includes integrated transport implementations that connect directly to hardware peripherals via Ada `HAL` interfaces (such as `HAL.I2C`), eliminating the need for user-written transport glue code.

Current transport:

- `Glyph.Transport.I2C` (cross-platform `HAL.I2C` transport bridge)
- `Glyph.Transport.Pico` (compatibility alias)

---

## Glyph.Display

A Display composes:

- Canvas
- Controller
- Bus Transport

into a single object that applications instantiate and control.

`Glyph.Display.Generic_Display` provides static compile-time generic composition for any canvas, controller, and bus combination with zero heap overhead, while `Glyph.Display` provides a convenient ready-to-use facade.

---

# ✦ Dependency Rules

Glyph follows a strict one-way dependency model.

```text
                 Types / Colors
                 ▲     ▲     ▲
                 │     │     │
         Algorithms    │     │
                 ▲     │     │
                 │     │     │
               Canvas  │     │
                 ▲     │     │
                 │     │     │
              Display  │     │
                 │     │     │
                 ▼     │     │
            Controllers│     │
                 ▲     │     │
                 │     │     │
                 └──Transport┘
```

No lower layer may depend on a higher layer.

---

# ✦ Architectural Constraints

The following rules apply throughout the framework.

## Static Memory

Glyph never performs dynamic memory allocation.

All memory is allocated statically or on the stack through Ada language features and generics.

---

## Single Responsibility

Every package has one clearly defined responsibility.

Examples:

- Algorithms never know about controllers.
- Controllers never know about drawing primitives.
- Canvas never knows about transport hardware.
- Transport never knows about graphics algorithms.

---

## Composition over Coupling

Complex functionality is built by composing small, reusable packages instead of tightly coupling responsibilities.

This improves:

- Portability
- Maintainability
- Testability
- Extensibility

---

# ✦ Supported Platform

Current reference platform:

- Vicharak Shrike-Lite / RP2040
- SSD1306 128×64 OLED
- I²C transport (integrated directly with `Pico_BSP`)

A complete reference application is available in **`example/`**.

---

# ✦ Future Architecture

The current architecture provides a foundation for future capabilities.

## Graphics

- Ellipses (`Paint_Ellipse`, `Paint_Filled_Ellipse`)
- Rounded rectangles (`Paint_Rounded_Rectangle`)
- Polygon rasterization

## Rendering

- Banded / chunked rendering for large RGB displays
- Direct streaming mode
- Partial display updates
- Dirty rectangle tracking
- Region clipping
- Optimized framebuffer flushing

## Text & Images

- Bitmap fonts
- UTF-8 rendering
- Image rendering

## Hardware

- Additional display controllers (SH1106, ST7789, ILI9341, IL0373 E-Ink)
- SPI transport
- Multiple framebuffer layouts
- Multiple pixel formats (RGB565, Grayscale)

These additions will build upon the existing architecture without changing Glyph's core layering principles.
