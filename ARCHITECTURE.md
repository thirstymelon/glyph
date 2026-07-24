# Architecture

## Overview

Glyph is a layered embedded graphics framework. Each layer provides an abstraction boundary that encapsulates implementation details behind a stable interface. This separation ensures that application code, rendering logic, and hardware drivers can evolve independently.

The architecture follows three principles:

1. **Information hiding** — Each layer exposes only what the layer above requires.
2. **Deterministic execution** — All rendering paths use bounded memory and time.
3. **Portability** — Hardware dependencies are confined to the lowest layers.

---

## Layered architecture

```
+-------------------------------------------------------------------+
|                        APPLICATION                                 |
|  User-defined Ada program using the Glyph API.                    |
|  Never interacts with display drivers or hardware directly.       |
+-------------------------------------------------------------------+
|                         GLYPH API                                  |
|  Public interface to all graphics functionality.                  |
|  Entry point for all application drawing operations.              |
+-------------------------------------------------------------------+
|                          CANVAS                                    |
|  Coordinate system, viewport clipping, transformation stack.      |
|  Provides a logical drawing surface independent of pixel layout.  |
+-------------------------------------------------------------------+
|                        FRAMEBUFFER                                 |
|  Raw pixel storage with configurable color depth.                 |
|  Implements pixel read/write, blit, fill, and scroll operations.  |
+-------------------------------------------------------------------+
|                      DISPLAY DRIVER                                |
|  Controller-specific command sequences and data transfer.         |
|  Implements Glyph.Driver interface for a specific display IC.     |
+-------------------------------------------------------------------+
|                  HARDWARE ABSTRACTION LAYER (HAL)                  |
|  Low-level I/O: I2C, SPI, parallel bus, GPIO, timers.             |
|  Abstracted behind tagged types for platform portability.         |
+-------------------------------------------------------------------+
|                    MICROCONTROLLER / HARDWARE                       |
|  Physical MCU, peripherals, and wiring.                           |
+-------------------------------------------------------------------+
```

## Layer responsibilities

### Application layer

The application is user-provided Ada code that links against Glyph. It creates a Canvas or Framebuffer, issues drawing commands, and optionally manages a scene or widget tree. The application must not call display driver procedures directly.

Responsibilities:

- Initialize the library and configure the display.
- Create or obtain a Canvas for drawing.
- Issue drawing commands (lines, text, shapes, images).
- Manage frame timing and animation updates.
- Handle input events (if applicable).

### Glyph API layer

The public API surface of the library. This layer provides subprograms for initializing the library, configuring displays, creating render contexts, and issuing drawing commands.

Responsibilities:

- Expose a stable, documented public interface.
- Forward calls to the appropriate internal subsystem.
- Validate parameters and enforce preconditions.
- Shield application code from internal implementation details.

Packages:

- `Glyph` — Top-level package with initialization and configuration.
- `Glyph.Types` — Common type definitions (coordinates, colors, rectangles).
- `Glyph.Colors` — Color format definitions and conversions.
- `Glyph.Drawing` — Drawing primitives (lines, rectangles, circles, polygons).

### Canvas layer

The Canvas provides a logical drawing surface. It manages viewport clipping, coordinate transformations, and render state (current color, line width, fill mode). The Canvas operates on a Framebuffer but decouples drawing logic from pixel storage details.

Responsibilities:

- Maintain viewport and clipping region.
- Apply coordinate transformations (translation, scaling, rotation).
- Clip drawing operations to the visible region.
- Composite multiple drawing operations onto the framebuffer.
- Manage render state (stroke color, fill color, line width, font).

Packages:

- `Glyph.Canvas` — Logical drawing surface.
- `Glyph.Canvas.Clipping` — Clipping region management.
- `Glyph.Canvas.Transforms` — Coordinate transformations.

### Framebuffer layer

The Framebuffer is an in-memory pixel buffer. It stores pixel data in a hardware-independent format and provides low-level pixel manipulation operations. The framebuffer knows nothing about display controllers, I2C, or SPI.

Responsibilities:

- Store pixel data in a flat 2D array.
- Provide pixel read and write operations.
- Support block operations: fill, copy, blit, scroll.
- Manage color format conversion (monochrome, RGB565, RGB888).
- Provide direct memory access for efficient driver transfer.

Packages:

- `Glyph.Framebuffer` — Generic framebuffer operations.
- `Glyph.Framebuffer.Mono` — Monochrome framebuffer.
- `Glyph.Framebuffer.RGB565` — 16-bit color framebuffer.
- `Glyph.Framebuffer.RGB888` — 24-bit color framebuffer.

### Display driver layer

A display driver translates framebuffer contents into the command and data sequences required by a specific display controller. Each driver implements a common interface defined by the framework.

Responsibilities:

- Implement the `Glyph.Drivers` interface.
- Initialize the display controller (hardware reset, configuration sequence).
- Transfer framebuffer data to the display controller.
- Manage display-specific commands (contrast, orientation, sleep, scroll).
- Report display capabilities (resolution, color depth, supported operations).

Packages:

- `Glyph.Drivers` — Driver interface specification.
- `Glyph.Drivers.SSD1306` — SSD1306 controller driver.
- `Glyph.Drivers.SH1106` — SH1106 controller driver.
- `Glyph.Drivers.ST7735` — ST7735 controller driver.

### Hardware abstraction layer (HAL)

The HAL abstracts microcontroller peripherals behind platform-independent interfaces. This layer encapsulates I2C, SPI, GPIO, and timer operations through tagged types that specific board packages implement.

Responsibilities:

- Define abstract interfaces for I2C, SPI, parallel bus, GPIO, and timers.
- Provide platform-independent type definitions for bus transactions.
- Enable compile-time selection of board-specific implementations.
- Isolate board-specific register manipulation and pin configuration.

Packages:

- `Glyph.HAL` — Hardware abstraction interface definitions.
- `Glyph.HAL.I2C` — I2C bus interface.
- `Glyph.HAL.SPI` — SPI bus interface.
- `Glyph.HAL.GPIO` — General-purpose I/O interface.
- `Glyph.HAL.Timers` — Timer and delay interface.

---

## Data flow

A typical frame rendering follows this data flow:

```
Application calls Glyph.Drawing.Draw_Rectangle
        |
        v
Glyph.Drawing validates parameters, forwards to Canvas
        |
        v
Canvas applies clipping, transforms coordinates
        |
        v
Canvas calls Framebuffer pixel operations
        |
        v
Framebuffer updates raw pixel array
        |
        v
Application calls Glyph.Display.Update
        |
        v
Glyph.Display calls the active Display Driver
        |
        v
Display Driver translates framebuffer to controller commands
        |
        v
Display Driver sends commands/data via HAL
        |
        v
HAL transmits on I2C/SPI bus to display controller
```

---

## Framebuffer model

The framebuffer is the central data structure in Glyph. It is a statically allocated 2D array of pixels. The color depth is determined at compile time through generic formal parameters.

```
       +----+----+----+----+----+
       |P0,0|P1,0|P2,0|P3,0|...|  row 0
       +----+----+----+----+----+
       |P0,1|P1,1|P2,1|P3,1|...|  row 1
       +----+----+----+----+----+
       |P0,2|P1,2|P2,2|P3,2|...|  row 2
       +----+----+----+----+----+
       |... |... |... |... |... |  ...
       +----+----+----+----+----+
```

Pixel storage formats:

- **Monochrome (1 bpp)**: One bit per pixel, 8 pixels per byte. Used for OLED displays like SSD1306 and SH1106.
- **Indexed (2/4/8 bpp)**: Palette-based color with configurable color table.
- **RGB565 (16 bpp)**: 5 bits red, 6 bits green, 5 bits blue. Common on TFT displays.
- **RGB888 (24 bpp)**: 8 bits per channel. Full color, higher memory requirement.

---

## Package organization

```
Glyph                              — Top-level: initialization, configuration
Glyph.Types                        — Common types (Coordinate, Rectangle, Color)
Glyph.Colors                       — Color definitions and format conversion
Glyph.Drawing                      — Drawing primitives (lines, shapes, text, images)
Glyph.Canvas                       — Logical drawing surface
Glyph.Canvas.Clipping              — Viewport and clipping
Glyph.Canvas.Transforms            — Coordinate transformations
Glyph.Framebuffer                  — Generic framebuffer operations
Glyph.Framebuffer.Mono             — Monochrome framebuffer
Glyph.Framebuffer.RGB565           — 16-bit color framebuffer
Glyph.Framebuffer.RGB888           — 24-bit color framebuffer
Glyph.Fonts                        — Font data and glyph metrics
Glyph.Images                       — Image loading and rendering
Glyph.Widgets                      — Widget system (buttons, labels, etc.)
Glyph.Animation                    — Animation framework
Glyph.Display                      — Display management and update coordination
Glyph.Drivers                      — Display driver interface
Glyph.Drivers.SSD1306              — SSD1306 driver
Glyph.Drivers.SH1106               — SH1106 driver
Glyph.Drivers.ST7735               — ST7735 driver
Glyph.HAL                          — Hardware abstraction interface
Glyph.HAL.I2C                      — I2C bus abstraction
Glyph.HAL.SPI                      — SPI bus abstraction
Glyph.HAL.GPIO                     — GPIO abstraction
Glyph.HAL.Timers                   — Timer abstraction
Glyph.Config                       — Build-time configuration
```

---

## Dependency rules

- Packages in higher layers may depend on packages in the same layer or lower layers.
- Packages must never depend on packages in a higher layer.
- Display drivers must not depend on specific MCU HAL implementations.
- The HAL must not depend on any display driver.
- Application code must not import display driver or HAL packages directly.

```
Application
    |
    v
Glyph (top-level)
    |
    v
Canvas -> Framebuffer
    |
    v
Drivers
    |
    v
HAL
    |
    v
Board-Specific Implementation
```

---

## Thread safety

Glyph is designed for single-threaded embedded systems. No internal locking is provided. If used in a multi-threaded context (with an RTOS), the application is responsible for serializing access to the Glyph API.

---

## Error handling

Glyph uses Ada's exception mechanism sparingly. Most errors are prevented at compile time through strong typing and constrained subtypes. Runtime errors are handled through:

- **Preconditions and postconditions** — Contract-based programming using Ada aspects.
- **Subtype constraints** — Bounded integers and arrays prevent out-of-range access.
- **Status codes** — Functions return result codes where failure is expected (e.g., I2C transmission errors).

---

## Memory ownership

All memory in Glyph is statically allocated. No heap allocation occurs after library initialization.

- Framebuffers are allocated at compile time as fixed-size arrays.
- Driver state is stored in record types within the driver package.
- The HAL manages bus handles as tagged types without dynamic dispatch (where possible).
- Font data is stored in ROM (constant arrays).

---

## Future extensibility

### Adding a new display driver

1. Create a new child package under `Glyph.Drivers` (e.g., `Glyph.Drivers.ILI9341`).
2. Implement the `Glyph.Drivers` interface subprograms.
3. Register the driver in the display configuration framework.

### Adding a new board/HAL backend

1. Create a board-specific package implementing the HAL interfaces.
2. Provide I2C, SPI, GPIO, and timer implementations for the target MCU.
3. Add the board as a configuration option in the build system.

### Adding a new framebuffer format

1. Create a new child package under `Glyph.Framebuffer`.
2. Implement the framebuffer interface subprograms for the new pixel format.
3. Update the format selection logic if applicable.
