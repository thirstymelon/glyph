# ✦ Glyph Architecture

## Overview

Glyph is a portable graphics framework for bare-metal embedded systems.

The framework follows a strict layered architecture that separates graphics algorithms, drawing operations, framebuffer management, display memory layouts, display controllers, and hardware communication.

Each layer has a single responsibility and communicates only with the layer directly beneath it.

This separation keeps the graphics core completely independent of any BSP, HAL, SDK, RTOS, or specific microcontroller.

---

# ✦ Design Objectives

The architecture is guided by the following principles:

- Hardware-independent graphics core
- Zero dynamic memory allocation
- Deterministic execution
- Strong type safety
- Static composition through Ada generics
- Clear package responsibilities
- Reusable graphics algorithms
- Portable across embedded platforms
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
           | Framebuffer  |<-------------------------+
           +------+-------+                          │
                  │                                  ▼
                  ▼                           +---------------+
           +--------------+                   |  Transport    |
           |    Layout    |                   +---------------+
           +--------------+                          │
                                                    ▼
                                             Display Hardware
```

---

# ✦ Rendering Pipeline

Every drawing primitive follows the same rendering pipeline.

```text
Glow_Primitive(...)
        │
        ▼
Canvas
        │
        ▼
Graphics Algorithm
        │
        ▼
Put_Pixel()
        │
        ▼
Glow_Pixel()
        │
        ▼
Framebuffer
        │
        ▼
Layout
        │
        ▼
Controller
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
Glow_Line()
      │
      ▼
Liang–Barsky
(Line Clipping)
      │
      ▼
Bresenham
(Line Rasterization)
      │
      ▼
Put_Pixel()
```

---

## Rectangle

```text
Glow_Rectangle()
       │
       ▼
Rectangle Algorithm
       │
       ▼
Horizontal / Vertical Rasterization
       │
       ▼
Put_Pixel()
```

Future primitives such as circles, ellipses, and triangles will follow the same design philosophy by delegating rendering to reusable algorithm packages.

---

# ✦ Package Organization

```text
Glyph
│
├── Types
├── Algorithms
│   ├── Bresenham
│   ├── Liang_Barsky
│   └── Rectangle
├── Pixel_Formats
├── Layouts
├── Framebuffer
├── Canvas
├── Controllers
├── Displays
└── Transports
```

---

# ✦ Package Responsibilities

## Glyph.Types

Defines the fundamental types used throughout the framework.

Examples include:

- Coordinates
- Dimensions
- Points
- Lines
- Rectangles
- Pixel colors
- Helper scalar types

This package forms the foundation of Glyph and has no dependencies on other Glyph packages.

---

## Glyph.Algorithms

Contains reusable graphics algorithms.

Algorithms are completely independent of:

- Canvas
- Framebuffer
- Layouts
- Controllers
- Displays
- Transport hardware

Current algorithms include:

- Liang–Barsky line clipping
- Bresenham line rasterization
- Rectangle rasterization

Future algorithms may include:

- Midpoint Circle
- Midpoint Ellipse
- Triangle rasterization
- Polygon filling
- Bézier curves

---

## Glyph.Canvas

Canvas exposes the public drawing API.

It coordinates graphics algorithms with framebuffer operations while keeping drawing logic minimal.

Canvas is responsible for:

- Public drawing primitives
- Clipping management
- Algorithm instantiation
- Pixel plotting callback generation

Current primitives:

- Glow_Pixel
- Glow_Line
- Glow_Rectangle
- Glow_Filled_Rectangle

Future primitives:

- Glow_Circle
- Glow_Filled_Circle
- Glow_Ellipse
- Glow_Filled_Ellipse
- Glow_Triangle
- Glow_Filled_Triangle

---

## Glyph.Framebuffer

Provides statically allocated pixel storage.

Responsibilities include:

- Pixel storage
- Pixel updates
- Buffer clearing
- Delegating coordinate mapping to Layout packages

The framebuffer has no knowledge of controllers or hardware communication.

---

## Glyph.Layouts

Layouts describe how pixels are arranged in framebuffer memory.

A layout converts logical `(X, Y)` coordinates into memory locations without any knowledge of display controllers or transport hardware.

Current implementation:

- SSD1306 page layout

Future layouts:

- Linear monochrome
- RGB565
- RGB888
- Grayscale

---

## Glyph.Controllers

Controller packages understand the protocol of a specific display controller.

Responsibilities include:

- Display initialization
- Command encoding
- Display configuration
- Framebuffer flushing

Controllers never implement graphics algorithms.

---

## Glyph.Transports

Defines the hardware communication interface.

Applications provide transport implementations that bridge Glyph to platform-specific peripherals such as:

- I²C
- SPI

Glyph never communicates directly with hardware peripherals.

---

## Glyph.Displays

A Display composes:

- Canvas
- Framebuffer
- Controller

into a single object that applications instantiate.

This provides a simple high-level interface while preserving separation between layers.

---

# ✦ Dependency Rules

Glyph follows a strict one-way dependency model.

```text
                 Types
              ▲    ▲    ▲
              │    │    │
      Algorithms  Layouts
              ▲      ▲
              │      │
              └──┬───┘
                 │
           Framebuffer
                 ▲
                 │
              Canvas
                 ▲
                 │
             Displays

Controllers depend on:

• Framebuffer
• Transport
```

No lower layer may depend on a higher layer.

---

# ✦ Architectural Constraints

The following rules apply throughout the framework.

## Hardware Independence

The graphics core must never depend on:

- BSPs
- HALs
- SDKs
- RTOS services
- Microcontroller registers

---

## Static Memory

Glyph never performs dynamic memory allocation.

All memory is allocated statically or on the stack through Ada language features and generics.

---

## Single Responsibility

Every package has one clearly defined responsibility.

Examples:

- Algorithms never know about controllers.
- Controllers never know about drawing primitives.
- Layouts never know about transport hardware.
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

- RP2040
- SSD1306 128×64 OLED
- I²C transport

A complete reference implementation is available in **`rp2040_example/`**.

---

# ✦ Future Architecture

The current architecture provides a foundation for future capabilities.

## Graphics

- Circle primitives
- Filled circles
- Ellipses
- Filled ellipses
- Triangles
- Filled triangles

## Rendering

- Partial display updates
- Dirty rectangle tracking
- Region clipping
- Optimized framebuffer flushing

## Text & Images

- Bitmap fonts
- UTF-8 rendering
- Image rendering

## Hardware

- Additional display controllers
- SPI transport
- Multiple framebuffer layouts
- Multiple pixel formats

These additions will build upon the existing architecture without changing Glyph's core layering principles.
