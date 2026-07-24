# Framebuffer architecture

**Placeholder** — This document will describe the internal architecture of the Glyph framebuffer system.

## Planned content

- Framebuffer data model and pixel formats.
- Memory layout (row-major, column-major).
- Supported pixel formats: monochrome (1 bpp), indexed (2/4/8 bpp), RGB565 (16 bpp), RGB888 (24 bpp).
- Generic package design for format-parametric framebuffers.
- Pixel read/write operations and bounds checking.
- Block operations: fill, clear, copy, scroll.
- Blitting between framebuffers of different formats.
- Partial framebuffer updates (dirty rectangle tracking).
- Double-buffering support.
- Performance characteristics of each operation.
- Memory usage formulas for each pixel format.
- Integration with the Canvas and Display Driver layers.
