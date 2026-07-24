# Display drivers

**Placeholder** — This document will describe the display driver architecture and how to implement new drivers.

## Planned content

- Driver interface specification (`Glyph.Drivers`).
- Required subprograms: `Init`, `Update`, `Set_Contrast`, `Sleep`, `Wake`.
- Optional subprograms: `Set_Orientation`, `Set_Scroll`, `Set_Inversion`.
- Driver lifecycle: registration, initialization, operation, shutdown.
- Communication patterns: full buffer update, partial update, command-only.
- Timing considerations for display initialization sequences.
- Display capability reporting (resolution, color depth, supported features).
- How to implement a new display driver (step-by-step guide).
- Driver implementation examples:
  - SSD1306 (I2C, monochrome, page addressing).
  - ST7735 (SPI, RGB565, window addressing).
  - ILI9341 (SPI/parallel, RGB565, window addressing).
- Testing a display driver without hardware (simulation mode).
- Performance optimization techniques for each interface type.
