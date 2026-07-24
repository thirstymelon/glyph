# Design

## Project objectives

Glyph aims to become the standard embedded graphics framework in the Ada ecosystem. It provides a hardware-independent layered graphics architecture for microcontroller-driven displays. The framework prioritizes determinism, portability, and maintainability over feature breadth.

## Engineering principles

### 1. Zero dynamic allocation after initialization

All memory required for framebuffers, driver state, font data, and widget trees is allocated at compile time. No heap allocation occurs after library initialization. This guarantees:

- Bounded memory usage regardless of rendering workload.
- No allocation failures at runtime.
- Deterministic execution time for all operations.
- Suitability for safety-critical and real-time systems.

**Implementation strategy**: Use generic formal parameters for framebuffer dimensions. Store display driver state in static records. Embed font data in ROM constants. Provide a fixed-size widget pool for the widget system.

### 2. Integer-only rendering

All rendering algorithms use integer arithmetic exclusively. There is no floating-point computation in any drawing path. This ensures:

- Deterministic execution on MCUs without FPU hardware.
- Identical rendering results across different MCU architectures.
- Reduced code size and faster execution.
- Elimination of floating-point precision edge cases.

**Implementation strategy**: Implement Bresenham-based line and circle algorithms. Use fixed-point arithmetic for coordinate transforms where fractional values are required. Avoid trigonometric functions in base rendering.

### 3. Information hiding

Each layer exposes a minimal, stable interface. Implementation details are encapsulated within layer boundaries. Application code must not depend on internal types or subprograms.

**Implementation strategy**: Use private types for internal data structures. Mark internal subprograms as not visible to library users. Provide child packages only where the parent package is conceptually incomplete without them.

### 4. Minimal public surface

The public API is restricted to the minimum number of types and subprograms required to use the library. Internal types, helper subprograms, and implementation details are hidden.

**Rationale**: A small API surface is easier to document, learn, test, and maintain. It also reduces the risk of backward-compatibility constraints limiting future improvements.

### 5. Portability by construction

Hardware dependencies are confined to the HAL layer and display drivers. The core rendering pipeline (Canvas, Framebuffer, drawing primitives) contains no platform-specific code.

**Implementation strategy**: Define HAL interfaces as tagged types that specific board packages implement. Use generic packages parameterized by pixel format and dimensions. Provide a simulation backend for host-PC testing.

### 6. Compile-time configuration

Where possible, configuration choices are made at compile time through generic parameters and configuration packages. Runtime configuration is limited to parameters that must change during operation (e.g., display orientation, contrast).

**Rationale**: Compile-time configuration eliminates runtime branches, reduces code size, and allows the compiler to optimize more aggressively.

### 7. Contract-based programming

Ada's contract features (preconditions, postconditions, type invariants) are used to document and enforce subprogram contracts at runtime (in debug builds) and compile time (where possible).

**Rationale**: Contracts document assumptions explicitly, catch bugs early, and serve as executable documentation.

### 8. Testability

Every package is designed to be testable in isolation. The framebuffer, canvas, and drawing primitives can be tested on a host PC without hardware. Display drivers and HAL implementations require hardware-in-the-loop or simulated hardware.

**Implementation strategy**: Separate rendering logic from I/O. Provide a null-display driver for testing. Use simulation framebuffers that can be inspected programmatically.

---

## API design principles

### Consistency

Related operations must have consistent naming, parameter ordering, and behaviour across the entire library. If `Draw_Line` takes `(Buffer, X1, Y1, X2, Y2)` then `Draw_Rectangle` should take `(Buffer, X, Y, Width, Height)` following the same parameter style.

### Minimal public surface

Expose only what users need. Everything else is private.

```ada
--  Good: Minimal public surface.
package Glyph.Framebuffer is
   procedure Clear (FB : in out Framebuffer);
   procedure Draw_Pixel (FB : in out Framebuffer; X, Y : Coordinate; C : Pixel);
private
   --  Implementation details hidden.
end Glyph.Framebuffer;

--  Bad: Internal helpers exposed.
package Glyph.Framebuffer is
   procedure Clear (FB : in out Framebuffer);
   procedure Draw_Pixel (FB : in out Framebuffer; X, Y : Coordinate; C : Pixel);
   function Internal_Compute_Index (FB : Framebuffer; X, Y : Coordinate) return Natural; --  Should be private.
end Glyph.Framebuffer;
```

### Information hiding

Users must not depend on internal types, constants, or subprograms. The private part of a package specification must be considered internal and subject to change without notice.

### Backward compatibility

Public APIs must maintain backward compatibility within a major version. Changes that break backward compatibility must be reserved for major version bumps (v1.x to v2.x).

### Fail early, fail loud

Validate all parameters at the API boundary. Use preconditions, subtype constraints, and explicit checks to catch invalid inputs as early as possible.

```ada
procedure Draw_Pixel
  (FB : in out Framebuffer;
   X, Y : Coordinate;
   C : Pixel)
   with Pre => X < FB.Width and then Y < FB.Height;
```

### Predictable defaults

Where a subprogram has common usage patterns, provide sensible defaults through default parameter values.

```ada
procedure Draw_Rectangle
  (FB     : in out Framebuffer;
   X, Y   : Coordinate;
   W, H   : Positive;
   C      : Pixel;
   Filled : Boolean := False);
```

---

## API design conventions

### Parameter ordering

Follow a consistent left-to-right ordering:

1. The primary object being operated on (e.g., `Buffer`).
2. Positional parameters (coordinates, dimensions).
3. Styling parameters (colour, line width).
4. Behavioural flags (booleans, enumeration options).
5. Default parameters at the end.

```ada
procedure Draw_Line
  (Buffer     : in out Framebuffer;
   X1, Y1     : Coordinate;  -- Start position
   X2, Y2     : Coordinate;  -- End position
   Color      : Pixel;       -- Style
   Line_Width : Width := 1); -- Optional style
```

### Subprogram length

Subprograms should do one thing. If a subprogram is longer than 30 lines, consider splitting it.

### Function vs procedure

- Use a function when the operation computes a value without side effects on parameters.
- Use a procedure when the operation primarily modifies state.

```ada
function Get_Pixel (FB : Framebuffer; X, Y : Coordinate) return Pixel;
procedure Draw_Pixel (FB : in out Framebuffer; X, Y : Coordinate; C : Pixel);
```

### Overloading

Overloading should be used sparingly and only when the parameter types make the intended subprogram unambiguous. Prefer distinct names when overloading might confuse users.

```ada
--  Acceptable: same operation, different input types.
procedure Draw_Pixel (FB : in out Framebuffer; X, Y : Coordinate; C : Mono_Pixel);
procedure Draw_Pixel (FB : in out Framebuffer; X, Y : Coordinate; C : RGB565_Pixel);

--  Prefer distinct names when operations differ.
--  Good:
procedure Draw_Line (FB : in out Framebuffer; X1, Y1, X2, Y2 : Coordinate; C : Pixel);
procedure Draw_Horizontal_Line (FB : in out Framebuffer; X, Y, Length : Coordinate; C : Pixel);

--  Bad: Confusing overloading.
procedure Draw_Line (FB : in out Framebuffer; X1, Y1, X2, Y2 : Coordinate; C : Pixel);
procedure Draw_Line (FB : in out Framebuffer; X, Y, Length : Coordinate; C : Pixel; Horizontal : Boolean);
```

### Subprogram documentation

Every public subprogram must be documented:

```ada
--  Draw a line between two points.
--  FB     - The framebuffer to draw on.
--  X1, Y1 - Starting pixel coordinates.
--  X2, Y2 - Ending pixel coordinates.
--  Color  - The pixel colour value.
--  Raises Constraint_Error if any coordinate is out of bounds.
procedure Draw_Line
  (FB    : in out Framebuffer;
   X1, Y1 : Coordinate;
   X2, Y2 : Coordinate;
   Color  : Pixel);
```

### Deprecation policy

1. Mark deprecated subprograms with `pragma Deprecated`.
2. Document the replacement in a comment.
3. Maintain backward compatibility for one major version cycle.
4. Remove deprecated subprograms at the next major version release.

```ada
pragma Deprecated (Draw_Dashed_Line, "Use Draw_Line with Line_Style => Dashed");
procedure Draw_Dashed_Line (FB : in out Framebuffer; X1, Y1, X2, Y2 : Coordinate; C : Pixel);
```

---

## Package hierarchy design

```
Glyph                                 (top-level, public API)
├── Glyph.Types                       (common types, no dependencies)
├── Glyph.Colors                      (color definitions, uses Types)
├── Glyph.Config                      (compile-time configuration)
├── Glyph.Drawing                     (primitives, uses Canvas + Framebuffer)
├── Glyph.Canvas                      (logical surface, uses Framebuffer)
│   ├── Glyph.Canvas.Clipping        (clipping, uses Canvas)
│   └── Glyph.Canvas.Transforms      (transforms, uses Canvas)
├── Glyph.Framebuffer                (pixel storage, no display dependencies)
│   ├── Glyph.Framebuffer.Mono       (1 bpp)
│   ├── Glyph.Framebuffer.RGB565     (16 bpp)
│   └── Glyph.Framebuffer.RGB888     (24 bpp)
├── Glyph.Fonts                       (font data, uses Framebuffer)
├── Glyph.Images                      (images, uses Framebuffer)
├── Glyph.Widgets                     (widgets, uses Canvas + Framebuffer)
├── Glyph.Animation                   (animation, uses Canvas)
├── Glyph.Display                     (display management, uses Drivers)
├── Glyph.Drivers                     (driver interface)
│   ├── Glyph.Drivers.SSD1306        (SSD1306, uses HAL)
│   ├── Glyph.Drivers.SH1106         (SH1106, uses HAL)
│   └── Glyph.Drivers.ST7735         (ST7735, uses HAL)
└── Glyph.HAL                         (hardware abstraction interface)
    ├── Glyph.HAL.I2C                 (I2C abstraction)
    ├── Glyph.HAL.SPI                 (SPI abstraction)
    ├── Glyph.HAL.GPIO                (GPIO abstraction)
    └── Glyph.HAL.Timers              (timer abstraction)
```

## Embedded constraints

| Constraint | Target |
|------------|--------|
| RAM usage | < 32 KB for typical use cases |
| Flash usage | < 64 KB for base library |
| Stack usage | Bounded, measurable at build time |
| CPU | No FPU required |
| Clock speed | Down to 48 MHz |
| Display resolution | Up to 1024 x 1024 |

## Design trade-offs

### Static vs. dynamic framebuffer allocation

**Decision**: Static allocation.

**Rationale**: Deterministic memory usage is critical for embedded systems. The cost is that framebuffer size must be known at compile time, which prevents runtime display hot-plugging. This is acceptable for embedded applications where the display hardware is fixed.

### Monochrome vs. color framebuffer as default

**Decision**: Generic framebuffer parameterized by pixel type.

**Rationale**: A single framebuffer implementation with a generic pixel type allows the same library to support both monochrome OLED displays and full-color TFTs without code duplication.

### Interface inheritance vs. generic packages for display drivers

**Decision**: Tagged type interface for display drivers; generic packages for framebuffers.

**Rationale**: Display drivers benefit from polymorphic dispatch (e.g., iterating over a list of drivers). Framebuffers benefit from compile-time specialization with no dispatch overhead.

## Future design considerations

- Partial framebuffer updates (dirty rectangle tracking) to reduce I2C/SPI traffic.
- Double-buffering with page flipping for tear-free animation.
- Configurable color depth per framebuffer region.
- Hardware acceleration interface (DMA, hardware SPI).
- RTOS integration hooks for thread-safe frame updates.
