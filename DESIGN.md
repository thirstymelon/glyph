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

## Naming conventions

See [CODING_STANDARD.md](CODING_STANDARD.md) and [STYLE_GUIDE.md](STYLE_GUIDE.md) for detailed naming rules. Key conventions:

| Element | Convention | Example |
|---------|------------|---------|
| Package | Hierarchical, capitalized | `Glyph.Framebuffer.Mono` |
| Type | Descriptive, PascalCase | `Pixel_Format`, `Display_Driver` |
| Subprogram | Verb phrases, snake_case | `Draw_Line`, `Fill_Rectangle` |
| Constant | UPPER_SNAKE_CASE | `MAX_DISPLAY_WIDTH` |
| Generic parameter | Descriptive, leading `T_` for types | `T_Pixel_Type`, `Width`, `Height` |

---

## Embedded constraints

Glyph is designed for MCU-class devices with limited resources:

| Constraint | Target |
|------------|--------|
| RAM usage | < 32 KB for typical use cases |
| Flash usage | < 64 KB for base library |
| Stack usage | Bounded, measurable at build time |
| CPU | No FPU required |
| Clock speed | Down to 48 MHz |
| Display resolution | Up to 1024 x 1024 |

---

## Design trade-offs

### Static vs. dynamic framebuffer allocation

**Decision**: Static allocation.

**Rationale**: Deterministic memory usage is critical for embedded systems. The cost is that framebuffer size must be known at compile time, which prevents runtime display hot-plugging. This is acceptable for embedded applications where the display hardware is fixed.

### Monochrome vs. color framebuffer as default

**Decision**: Generic framebuffer parameterized by pixel type.

**Rationale**: A single framebuffer implementation with a generic pixel type allows the same library to support both monochrome OLED displays and full-color TFTs without code duplication.

### Interface inheritance vs. generic packages for display drivers

**Decision**: Tagged type interface (Ada's object-oriented features) for display drivers; generic packages for framebuffers.

**Rationale**: Display drivers benefit from polymorphic dispatch (e.g., iterating over a list of drivers). Framebuffers benefit from compile-time specialization with no dispatch overhead. Using the right mechanism for each layer maximizes both flexibility and performance.

---

## Future design considerations

- Support for partial framebuffer updates (dirty rectangle tracking) to reduce I2C/SPI traffic.
- Support for double-buffering with page flipping for tear-free animation.
- Configurable color depth per framebuffer region.
- Hardware acceleration interface (DMA, hardware SPI).
- RTOS integration hooks for thread-safe frame updates.
