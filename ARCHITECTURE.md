# ✦ Glyph Architecture

**Version:** 1.1

**Status:** Active

---

## ✦ Overview

Glyph is a portable graphics framework for Ada designed specifically for bare-metal and embedded systems.

Its architecture emphasizes:

- Hardware independence
- Static memory allocation
- Deterministic behavior
- Stable public APIs
- Strict package responsibilities
- Long-term maintainability

Every implementation should follow the architecture described in this document.

---

## ✦ Core Philosophy

Glyph follows one fundamental rule:

> **Every package has one primary responsibility.**

Packages collaborate through clearly defined interfaces while remaining independent from one another.

---

## ✦ Design Principles

### ✦ Single Responsibility

Every package exists for exactly one reason.

Examples:

- Canvas coordinates rendering.
- Framebuffer stores pixels.
- Display represents a display device.
- Display_Profiles define immutable display descriptors.
- Controllers implement controller-specific behavior.
- Transport transfers bytes.
- BSP/HAL communicates with hardware.

---

### ✦ Composition Over Inheritance

Glyph favors composition instead of inheritance.

```text
Canvas
├── owns Framebuffer
└── references Display
```

Objects collaborate instead of forming deep inheritance hierarchies.

---

### ✦ Immutable Configuration

Static configuration never changes at runtime.

Display descriptors are immutable compile-time constants.

Display objects contain runtime state while referencing immutable descriptors.

---

### ✦ Stable Public API

Applications should continue compiling as Glyph gains:

- New display controllers
- New transport layers
- New pixel formats
- New displays

---

### ✦ Static Memory Only

Glyph never performs dynamic memory allocation.

Memory is either:

- Statically allocated
- Stack allocated

This guarantees deterministic behavior for embedded systems.

---

### ✦ Hardware Independence

Graphics algorithms never depend on hardware.

Drawing code has no knowledge of:

- GPIO
- SPI
- I²C
- DMA

Likewise, transport layers know nothing about graphics algorithms.

---

## ✦ Layered Architecture

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

Each layer communicates only with the layer directly below it.

---

## ✦ Package Responsibilities

### ✦ Glyph

The root package of the framework.

Responsible for:

- Framework initialization
- Framework shutdown

---

### ✦ Glyph.Types

Defines fundamental types shared throughout Glyph.

Examples:

- Coordinate
- Dimension
- Rotation
- Pixel_Index

---

### ✦ Glyph.Pixel_Formats

Defines framebuffer pixel formats.

Initially:

- `Monochrome_1bpp`

Additional formats can be introduced without changing the public graphics API.

---

### ✦ Glyph.Canvas

Coordinates rendering.

Each canvas:

- Owns exactly one framebuffer
- References exactly one display

Canvas never communicates directly with hardware.

---

### ✦ Glyph.Framebuffer *(Private)*

Responsible only for storing pixel data.

Provides:

- Pixel storage
- Pixel retrieval
- Memory clearing

The framebuffer is never exposed publicly.

---

### ✦ Glyph.Display

Represents a physical display.

Responsible for:

- Display initialization
- Runtime state
- Display capability queries
- Flush requests
- Power management

Applications interact only with this package.

---

### ✦ Glyph.Display_Profiles

Defines immutable display descriptors.

Examples:

- SSD1306_128_64
- SSD1306_128_32

Each descriptor defines:

- Width
- Height
- Pixel format
- Controller type
- Transport type

Descriptors are the single source of truth describing supported displays.

---

### ✦ Glyph.Controllers *(Private)*

Implements controller-specific behavior.

Examples:

- SSD1306 initialization
- Framebuffer conversion
- Command generation
- Flush implementation

Controllers never define display properties.

---

### ✦ Glyph.Transport *(Private)*

Responsible only for transferring bytes.

Examples:

- I²C
- SPI

Transport layers never contain graphics logic.

---

### ✦ BSP / HAL

Provides direct hardware access.

Examples:

- GPIO
- SPI peripheral
- I²C peripheral
- DMA

This layer knows nothing about graphics.

---

## ✦ Object Relationships

```text
Canvas
├── owns Framebuffer
└── references Display

Display
└── references immutable Display Descriptor
```

---

## ✦ Display Lifecycle

```text
Create Display

↓

Initialize Display

↓

Create Canvas

↓

Draw

↓

Flush

↓

Repeat
```

---

## ✦ Coordinate System

```text
(0,0)
 ┌────────────────► X
 │
 │
 ▼
 Y
```

- Origin: Top-left
- Positive X: Right
- Positive Y: Down

Drawing operations perform clipping rather than raising exceptions when coordinates fall outside the visible area.

---

## ✦ Color Model

Glyph initially targets monochrome displays.

Future color support will extend the existing API through additional pixel formats and color types instead of introducing separate drawing APIs.

---

## ✦ Multiple Displays

Glyph supports multiple independent displays.

Each display has:

- Its own display object
- Its own canvas
- Its own framebuffer

Displays never share rendering state.

---

## ✦ Architecture Rules

Every package added to Glyph must satisfy the following:

- One primary responsibility
- No duplicated ownership of information
- Immutable configuration separated from runtime state
- No dynamic memory allocation
- No layer bypassing
- Stable public interfaces
- Internal implementation remains private

---

## ✦ Current Implementation Status

### Completed

- Core package structure
- Public API
- Display abstraction
- Display descriptors
- Canvas lifecycle
- Internal package layout

### Next Milestones

1. Framebuffer implementation
2. Drawing primitives
3. Controller implementations
4. Transport implementations
5. SSD1306 support
6. Font rendering
7. Additional display support
