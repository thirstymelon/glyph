# ✦ Glyph Architecture

**Version:** 2.0

**Status:** Active

---

# ✦ Overview

Glyph is a portable embedded graphics framework written in Ada.

The framework is designed around three fundamental ideas:

- Graphics algorithms should be hardware independent.
- Display controller implementations belong inside Glyph.
- Platform-specific hardware access belongs outside Glyph.

The architecture intentionally avoids dynamic memory allocation, runtime configuration where unnecessary, and dependencies on BSPs, HALs, SDKs, or RTOSes.

---

# ✦ Core Philosophy

Glyph follows one simple rule:

> **Every package owns one responsibility and only one responsibility.**

Responsibilities are never duplicated.

---

# ✦ Design Principles

## ✦ Hardware Independence

Glyph never depends directly on:

- BSPs
- HALs
- SDKs
- RTOSes

Graphics code should be reusable on any embedded platform.

---

## ✦ Static Memory

Glyph performs no dynamic memory allocation.

Memory is either:

- Static
- Stack allocated

This guarantees deterministic behaviour.

---

## ✦ Compile-Time First

Configuration should be resolved at compile time whenever practical.

Runtime configuration is avoided unless it provides a clear architectural benefit.

---

## ✦ Layered Design

Each layer communicates only with the layer immediately below it.

No package should bypass intermediate layers.

---

## ✦ Stable Public APIs

Applications should continue compiling as Glyph gains:

- New controllers
- New drawing primitives
- New widgets
- New pixel formats

---

# ✦ Layered Architecture

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

The application communicates only with instantiated controller packages.

Controllers own display-specific behaviour.

Canvas owns drawing.

Framebuffer owns pixel storage.

---

# ✦ Package Responsibilities

## ✦ Glyph

Root package of the framework.

Currently provides only framework metadata.

---

## ✦ Glyph.Types

Defines common types shared throughout the framework.

Examples:

- Coordinate
- Dimension
- Rotation

---

## ✦ Glyph.Pixel_Formats

Defines supported framebuffer formats.

Initially:

- Monochrome_1bpp

Additional formats will be added without changing the graphics API.

---

## ✦ Glyph.Framebuffer

Responsible only for pixel storage.

Responsibilities include:

- Pixel storage
- Pixel access
- Clearing memory

The framebuffer contains no drawing algorithms.

---

## ✦ Glyph.Canvas

Provides drawing operations.

Responsibilities include:

- Lines
- Rectangles
- Circles
- Text
- Image rendering

Canvas manipulates a framebuffer.

Canvas never communicates directly with hardware.

---

## ✦ Glyph.Controllers

Contains display controller implementations.

Examples:

- SSD1306
- SH1106
- ST7789
- ILI9341

Each controller owns:

- Initialization sequences
- Command generation
- Framebuffer conversion
- Display refresh logic

Controllers do **not** own graphics algorithms.

---

# ✦ Ownership

| Component | Owner |
|-----------|-------|
| Drawing algorithms | Canvas |
| Pixel storage | Framebuffer |
| Display protocol | Controller |
| Hardware access | Application / BSP |

---

# ✦ Coordinate System

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

Drawing operations clip to the drawable area rather than raising exceptions.

---

# ✦ Multiple Displays

Glyph is designed to support multiple independent display instances.

Each display instance owns its own:

- Controller
- Canvas
- Framebuffer

No rendering state is shared.

---

# ✦ Architecture Rules

Every package added to Glyph must satisfy the following:

- One clear responsibility
- No duplicated ownership
- Static memory only
- Compile-time configuration where practical
- Stable public interfaces
- Hardware independence
- Layered architecture

---

# ✦ Current Status

Completed:

- Overall architecture
- Package hierarchy
- Fundamental types
- Pixel format definitions

Currently in progress:

1. Framebuffer
2. Canvas
3. SSD1306 controller

Future milestones:

1. Drawing primitives
2. Font rendering
3. Images
4. Widgets
5. Additional display controllers
6. Color display support
