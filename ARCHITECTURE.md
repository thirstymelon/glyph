# ✦ Glyph Architecture

## Overview

Glyph is a portable embedded graphics framework designed for bare-metal systems.

The framework is built around a strict layered architecture that separates graphics algorithms, drawing operations, framebuffer management, display memory layouts, display controllers, and hardware communication. Each layer has a single responsibility and communicates only with the layer directly beneath it.

This separation allows the graphics core to remain completely independent of any BSP, HAL, SDK, RTOS, or specific microcontroller.

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
- Display memory layouts isolated from framebuffer logic
- Portable across embedded platforms

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

# ✦ Internal Graphics Pipeline

Every drawing operation follows the same rendering pipeline.

```text
Glow_Line(...)
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
Glow_Pixel(...)
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

# ✦ Package Organization

```text
Glyph
│
├── Types
├── Algorithms
│   ├── Bresenham
│   └── Liang_Barsky
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

Defines the fundamental data types used throughout the framework.

Examples include:

- Coordinates
- Dimensions
- Points
- Lines
- Rectangles
- Pixel colors
- Scalar helper types

This package forms the foundation of the entire framework and has no dependencies on other Glyph packages.

---

## Glyph.Algorithms

Contains reusable graphics algorithms.

Algorithms are completely independent of hardware, display controllers, framebuffer implementations, and memory layouts.

Current algorithms include:

- Liang–Barsky line clipping
- Bresenham line rasterization

Future algorithms may include:

- Circle rasterization
- Ellipse rasterization
- Polygon filling
- Bézier curves

---

## Glyph.Layouts

Layout packages describe how pixels are arranged in framebuffer memory.

A layout converts a logical `(X, Y)` pixel coordinate into the corresponding memory location without knowing anything about display controllers or transport hardware.

Current implementation:

- SSD1306 page-oriented layout

Future layouts may include:

- Linear monochrome
- RGB565
- RGB888
- Grayscale formats

---

## Glyph.Framebuffer

Provides statically allocated pixel storage.

The framebuffer owns the display memory representation while remaining unaware of display controllers, transport hardware, or layout-specific coordinate mapping.

Responsibilities include:

- Pixel storage
- Pixel updates
- Buffer clearing
- Delegating coordinate mapping to a layout package

---

## Glyph.Canvas

Provides the public graphics API.

The Canvas coordinates graphics algorithms and framebuffer operations to expose a simple drawing interface.

Current public primitives include:

- `Glow_Pixel`
- `Glow_Line`

Future primitives will be implemented on top of these core operations.

---

## Glyph.Controllers

Implements display controller protocols.

Controller packages understand how to communicate with a specific display controller but have no knowledge of the underlying hardware peripheral.

Responsibilities include:

- Display initialization
- Command encoding
- Framebuffer flushing
- Display configuration

---

## Glyph.Transports

Defines the hardware communication interface.

Transport implementations are supplied by the application and bridge Glyph to platform-specific peripherals such as I²C or SPI.

Glyph itself never communicates directly with hardware peripherals.

---

## Glyph.Displays

Provides ready-to-use display compositions.

A Display combines:

- Framebuffer
- Canvas
- Controller

into a single object that applications can instantiate with minimal configuration.

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
- Framebuffer
- Transport
```

No lower layer may depend on a higher layer.

---

# ✦ Architectural Constraints

The following constraints apply to every package in Glyph.

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

- Graphics algorithms never know about display controllers.
- Layouts never know about framebuffer storage.
- Framebuffers never know about display memory layouts.
- Controllers never know about drawing algorithms.
- Transport implementations never know about graphics primitives.

---

## Composition over Coupling

Complex functionality is built by composing independent packages rather than tightly coupling responsibilities.

This approach improves portability, maintainability, and testability.

---

# ✦ Supported Platform

Current development target:

- RP2040 (Vicharak Shrike-Lite)
- SSD1306 128×64 OLED
- I²C transport

A complete reference implementation is available in the **`rp2040_example/`** project included in this repository.

---

# ✦ Future Architecture

The current architecture provides a foundation for future capabilities, including:

- Additional drawing primitives
- Bitmap and vector fonts
- Image rendering
- Multiple framebuffer layouts
- Multiple pixel formats
- Additional display controllers
- Hardware acceleration where available
- Lightweight embedded UI widgets

These additions will build upon the existing architecture without changing the core layering principles.
