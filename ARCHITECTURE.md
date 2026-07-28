# Glyph Architecture

**Version:** 1.0 (Architecture Freeze)
**Status:** Active Design Document

---

# Overview

Glyph is a lightweight, portable graphics framework for Ada designed specifically for embedded systems.

Its primary goals are:

- Hardware independence
- Predictable memory usage
- Static allocation only
- Clean package boundaries
- Long-term maintainability
- Stable public APIs

Every design decision in Glyph should follow the architecture described in this document.

If a future implementation conflicts with these principles, the implementation should be reconsidered rather than modifying the architecture.

---

# Core Philosophy

Glyph follows one fundamental rule:

> **Every package has one primary responsibility.**

A package may expose multiple operations, but every operation must support the same responsibility.

Packages should never perform work that belongs to another layer.

---

# Design Principles

## 1. Single Responsibility

Each package exists for one reason only.

Examples:

- Canvas coordinates graphics rendering.
- Framebuffer stores pixels.
- Display represents a display device.
- Controllers implement controller-specific behavior.
- Transport transfers bytes.
- BSP/HAL accesses hardware peripherals.

---

## 2. Composition Over Inheritance

Glyph prefers composition whenever possible.

Instead of creating complex inheritance hierarchies, objects own or reference other objects.

Example:

```text
Canvas
├── owns Framebuffer
└── references Display
```

rather than

```text
Canvas
    ▲
Framebuffer
```

---

## 3. Make Invalid States Impossible

Glyph should prevent invalid object states whenever practical.

Examples:

- A framebuffer cannot exist with inconsistent dimensions.
- Display descriptors are immutable.
- Internal implementation details remain inaccessible to applications.

---

## 4. Immutable Configuration

Static configuration never changes at runtime.

Display descriptors are immutable constants.

Display objects may contain runtime state but never modify descriptor information.

---

## 5. Public API Stability

Public APIs should remain stable as Glyph evolves.

Adding support for:

- new displays
- new controllers
- new transports
- new pixel formats

should not require applications to change existing code.

---

## 6. No Dynamic Memory Allocation

Glyph never allocates memory dynamically.

- No heap allocation
- No garbage collection
- No ownership ambiguity

Memory is either:

- statically allocated
- stack allocated

This guarantees deterministic memory usage and predictable behavior.

---

## 7. Hardware Independence

Graphics code must remain completely independent of hardware.

Drawing algorithms must never know:

- I²C
- SPI
- DMA
- GPIO

Likewise, hardware drivers must never know graphics algorithms.

---

# Layered Architecture

Glyph follows a strict layered architecture.

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

Each layer communicates only with adjacent layers.

No layer may bypass another layer.

---

# Package Responsibilities

## Glyph.Canvas

### Responsibility

Coordinates graphics rendering.

### Owns

- One framebuffer

### References

- One display

### Performs

- Drawing operations
- Clipping
- Rendering coordination
- Flush requests

### Never Performs

- Hardware communication
- Pixel storage
- Display controller logic
- Transport operations

---

## Glyph.Framebuffer *(Private)*

### Responsibility

Stores pixels.

### Performs

- Pixel storage
- Pixel retrieval
- Memory clearing

### Never Performs

- Drawing algorithms
- Display communication
- Transport operations

The framebuffer is an internal implementation detail and is never exposed publicly.

---

## Glyph.Display

### Responsibility

Represents a physical display.

### Performs

- Display initialization
- Display state management
- Display capability queries
- Flush requests

### Never Performs

- Drawing algorithms
- Pixel storage
- Controller algorithms
- Transport operations

Applications interact with displays only through this package.

Glyph exposes exactly **one** public display type.

---

## Glyph.Displays

### Responsibility

Defines immutable display descriptors.

Each supported display is represented by one predefined descriptor.

Examples:

- SSD1306_128_64
- SSD1306_128_32
- SH1106_128_64
- ILI9341_320_240

Descriptors are:

- immutable
- predefined
- compile-time constants

They are the single source of truth describing supported displays.

---

## Glyph.Controllers *(Private)*

### Responsibility

Implements controller-specific algorithms.

Examples:

- SSD1306 initialization
- SSD1306 framebuffer conversion
- SH1106 page mapping
- ST7789 command generation

Controllers never define display properties.

Controllers are private implementation details.

Applications never access controllers directly.

---

## Glyph.Transport *(Private)*

### Responsibility

Transfers bytes between Glyph and hardware.

Examples:

- I²C
- SPI
- Parallel

Transport never performs graphics operations.

---

## BSP / HAL

### Responsibility

Provides direct hardware access.

Examples:

- GPIO
- I²C peripheral
- SPI peripheral
- DMA

This layer knows nothing about displays or graphics.

---

# Display Descriptors

Every supported display is represented by one immutable descriptor.

A descriptor contains immutable properties describing a supported display.

Examples include:

- Width
- Height
- Pixel Format
- Controller Type
- Transport Type
- Controller-specific initialization data
- Default hardware characteristics
- Static capabilities

Descriptors contain only immutable data.

Descriptors never contain executable logic.

---

# Controllers

Controllers implement behavior.

Controllers may:

- Initialize hardware
- Encode controller commands
- Convert framebuffer layouts
- Flush pixel data
- Power displays on and off

Controllers never define display properties.

Those belong exclusively to display descriptors.

---

# Display Lifecycle

Typical application flow:

```text
Create Display

↓

Initialize Display

↓

Attach Canvas

↓

Draw

↓

Flush

↓

Repeat
```

Example:

```ada
OLED : Display;

OLED.Initialize (SSD1306_128_64);

Canvas.Attach (OLED);

Canvas.Clear;
Canvas.Draw_Line (...);
Canvas.Draw_Text (...);
Canvas.Flush;
```

---

# Canvas Ownership

Each canvas owns:

- Exactly one framebuffer

Each canvas references:

- Exactly one display

A canvas cannot be attached to multiple displays.

Applications requiring multiple displays should create multiple canvases.

Example:

```ada
OLED : Display;
LCD  : Display;

Canvas1.Attach (OLED);
Canvas2.Attach (LCD);
```

---

# Framebuffer Ownership

Applications never access framebuffers directly.

Framebuffers exist solely to support canvas rendering.

This allows Glyph to freely change framebuffer implementation without breaking application code.

---

# Rotation

Display rotation belongs to the display layer.

The framebuffer always stores graphics in its natural orientation.

Rotation is applied only while presenting pixels to the physical display.

---

# Coordinates

Glyph uses the conventional graphics coordinate system.

```text
(0,0)
 ┌──────────────────► X
 │
 │
 │
 ▼
 Y
```

Origin:

- Top-left corner

Positive X:

- Right

Positive Y:

- Down

Coordinates outside the visible area are valid.

Drawing operations perform clipping rather than raising exceptions.

---

# Color Model

Glyph initially targets monochrome displays.

The public graphics API is designed so future color support can be added without changing drawing function names.

The API evolves through new color types rather than new drawing functions.

---

# Multiple Displays

Glyph supports multiple independent displays.

Each display has:

- Its own display object
- Its own canvas
- Its own framebuffer

Displays never share framebuffers.

---

# Public vs Private

If an application never needs to call a package, it should remain private.

Examples of private implementation packages:

- Glyph.Framebuffer
- Glyph.Controllers
- Glyph.Transport

Keeping these packages private allows Glyph to evolve internally without breaking applications.

---

# Architecture Rules

Every new package added to Glyph must satisfy the following checklist:

- Has exactly one primary responsibility.
- Does not duplicate information owned elsewhere.
- Keeps immutable data separate from executable logic.
- Does not expose internal implementation details.
- Does not allocate memory dynamically.
- Does not bypass architecture layers.
- Can evolve without breaking existing applications.

If a package violates any of these rules, its design should be reconsidered before implementation.

---

# Architecture Freeze

This document defines the architectural foundation of Glyph.

Future features should extend this architecture rather than replace it.

Changes to this document should be rare and only made when they simplify the architecture without violating its core principles.
