# Roadmap

This document outlines the development roadmap for Glyph through version 2.0. Milestones are ordered by dependency: later milestones build on earlier ones.

## Version 0.1.0 — Project skeleton

**Status**: Current

**Deliverables**:

- Repository structure and directory layout.
- Alire project manifest (`alire.toml`).
- Complete documentation suite.
- GitHub Actions CI workflow templates.
- Issue and pull request templates.
- Apache 2.0 license.
- `.gitignore`, `.editorconfig`, `.gitattributes`.
- Pre-commit configuration.

---

## Version 0.2.0 — Framebuffer and first driver

**Status**: Next

**Deliverables**:

- `Glyph.Types` package with coordinate, rectangle, color, and size types.
- `Glyph.Colors` package with color format definitions.
- `Glyph.Config` package for compile-time configuration.
- Monochrome framebuffer (`Glyph.Framebuffer.Mono`).
- Pixel read/write operations with bounds checking.
- Block operations: fill, clear, copy, scroll.
- SSD1306 display driver (`Glyph.Drivers.SSD1306`).
- I2C hardware abstraction (`Glyph.HAL.I2C`).
- I2C bit-banging implementation for RP2040.
- Display initialization and configuration sequence.
- Full framebuffer transfer to display.
- Unit tests for framebuffer operations.

---

## Version 0.3.0 — Drawing primitives

**Deliverables**:

- `Glyph.Drawing` package with primitive drawing operations.
- Point and pixel manipulation.
- Line drawing (Bresenham algorithm).
- Rectangle drawing (outline and filled).
- Circle drawing (Bresenham algorithm).
- Polygon drawing.
- Line styles (solid, dotted, dashed).
- Shape fill styles (solid, pattern).
- Viewport and clipping support.
- Unit tests for all primitives.

---

## Version 0.4.0 — Fonts and text rendering

**Deliverables**:

- `Glyph.Fonts` package with font data structures.
- Monospace bitmap font format definition.
- Built-in fonts (5x7, 8x13, 10x20).
- Glyph metrics and character spacing.
- Text drawing operations (single character, string).
- Text alignment (left, center, right).
- Text wrapping and line breaking.
- Custom font loading from ROM data.
- Font tools for converting BDF/PCF fonts to Glyph format.
- Unit tests for text rendering.

---

## Version 0.5.0 — Image and bitmap rendering

**Deliverables**:

- `Glyph.Images` package for image data structures.
- Monochrome bitmap blitting (1 bpp).
- Indexed-color bitmap blitting (2/4/8 bpp).
- RGB565 bitmap blitting.
- Image transparency support.
- Image rotation (0, 90, 180, 270 degrees).
- Image scaling (nearest-neighbour).
- Image transformation compositing.
- Unit tests for image operations.

---

## Version 0.6.0 — Widget system

**Deliverables**:

- `Glyph.Widgets` package with widget base types.
- Widget lifecycle (create, show, hide, destroy).
- Widget layout model (absolute and relative positioning).
- Button widget.
- Label widget.
- Progress bar widget.
- Slider widget.
- Checkbox widget.
- Container widget (horizontal and vertical layout).
- Widget event handling (click, release, enter, leave).
- Input abstraction (button, touch).
- Unit tests for widget behaviour.

---

## Version 0.7.0 — Animation framework

**Deliverables**:

- `Glyph.Animation` package with animation types.
- Frame-based animation (sequence of pre-rendered frames).
- Sprite animation with configurable frame timing.
- Tweening (interpolation between numeric values).
- Parallel and sequential animation composition.
- Callback-based animation events (start, end, loop).
- Hardware-timed frame updates using HAL timers.
- Animation state management (play, pause, stop, reset).
- Unit tests for animation sequencing.

---

## Version 0.8.0 — Display abstraction

**Deliverables**:

- `Glyph.Display` package for multiple display management.
- Display driver interface (`Glyph.Drivers`).
- SH1106 display driver.
- ST7735 display driver (SPI).
- Runtime driver selection (if supported by target hardware).
- Display capability query (resolution, color depth, operations).
- Display rotation and mirroring.
- Partial display update (dirty rectangle tracking).
- Multiple display support (e.g., OLED + TFT simultaneously).
- Integration tests with real hardware.

---

## Version 0.9.0 — Optimization and hardening

**Deliverables**:

- Performance profiling on target hardware.
- Rendering pipeline optimization (reduce I2C/SPI transfers).
- DMA transfer support (where available).
- Double-buffering support for tear-free rendering.
- Memory usage audit and reduction.
- Worst-case execution time (WCET) analysis.
- Contract hardening (strengthen preconditions and postconditions).
- Edge case audits (off-screen rendering, empty buffers, overflow).
- Code size optimization for constrained targets.
- Benchmark suite for rendering performance.

---

## Version 1.0.0 — Stable release

**Deliverables**:

- API stabilization (no breaking changes without major version bump).
- Complete API documentation with examples.
- Developer guide for porting to new hardware.
- Tutorial series (3+ tutorials covering basic to advanced usage).
- Published Alire crate with CI publishing workflow.
- Test coverage >= 80% for core packages.
- Hardware-in-the-loop test results published.
- Release process documented and automated.
- Community contribution guidelines finalized.
- Changelog complete through all milestones.

---

## Version 1.1.0 — RGB565 framebuffer

**Deliverables**:

- `Glyph.Framebuffer.RGB565` for 16-bit color support.
- ILI9341 display driver (SPI and parallel).
- GC9A01 display driver (SPI).
- Color format conversion utilities.
- 16-bit color image support.

---

## Version 1.2.0 — Additional fonts and text features

**Deliverables**:

- Proportional font support.
- UTF-8 text rendering (ASCII subset).
- Right-to-left text support.
- Text background rendering (opaque and transparent).
- Additional built-in fonts (variable-width, larger sizes).

---

## Version 2.0.0 — Mature framework

**Deliverables**:

- RGB888 framebuffer support.
- ILI9488 display driver.
- E-paper display driver support.
- STM32 HAL backend.
- ESP32 HAL backend.
- AVR HAL backend.
- RISC-V HAL backend.
- Desktop simulation environment.
- Widget theme system (custom colours, borders, backgrounds).
- Touchscreen input abstraction.
- Canvas coordinate transforms (scaling and rotation).
- Performance benchmark dashboard.
- Comprehensive example gallery.
- Multiple language API bindings (optional).
