# Supported displays

This document lists the display controllers that Glyph targets or plans to support.

---

## Display driver interface

All display drivers implement the interface defined in `Glyph.Drivers`. Each driver is a separate child package.

---

## Planned display support

| Controller | Resolution | Interface | Colour depth | Status |
|------------|------------|-----------|--------------|--------|
| SSD1306 | 128x64, 128x32 | I2C, SPI | 1 bpp (mono) | v0.2 |
| SH1106 | 132x64, 128x64 | I2C, SPI | 1 bpp (mono) | v0.8 |
| SSD1327 | 128x128 | I2C, SPI | 4 bpp (grayscale) | Future |
| ST7735 | 160x80, 128x128 | SPI | 16 bpp (RGB565) | v0.8 |
| ST7789 | 240x240, 320x240 | SPI | 16 bpp (RGB565) | v1.1 |
| ILI9341 | 320x240 | SPI, parallel | 16 bpp (RGB565) | v1.1 |
| ILI9488 | 480x320 | SPI, parallel | 16 bpp (RGB565) | v2.0 |
| GC9A01 | 240x240 | SPI | 16 bpp (RGB565) | v1.1 |
| E-paper (various) | Various | SPI | 1 bpp (mono) | v2.0 |

---

## Display characteristics

### SSD1306

| Property | Value |
|----------|-------|
| Resolution | 128 x 64 (also 128 x 32) |
| Colour depth | Monochrome (1 bpp) |
| Interface | I2C (up to 400 kHz), SPI (up to 10 MHz) |
| Controller memory | 128 x 64 bits (1 KB) |
| Features | On-chip display RAM, charge pump, contrast control, horizontal/vertical scroll, segment and row remapping |

### SH1106

| Property | Value |
|----------|-------|
| Resolution | 132 x 64 (128 x 64 visible) |
| Colour depth | Monochrome (1 bpp) |
| Interface | I2C, SPI, parallel |
| Controller memory | 132 x 64 bits (1.06 KB) |
| Features | Similar to SSD1306 but with additional column pixels; uses page addressing mode |

### ST7735

| Property | Value |
|----------|-------|
| Resolution | 160 x 80 (also 132 x 162, 128 x 128) |
| Colour depth | RGB565 (16 bpp), also 12 bpp and 8 bpp |
| Interface | SPI (up to 15 MHz) |
| Controller memory | 160 x 80 x 16 bits (25.6 KB) |
| Features | Window-based addressing, hardware scrolling, partial display mode, gamma correction |

### ST7789

| Property | Value |
|----------|-------|
| Resolution | 240 x 240, 240 x 320 |
| Colour depth | RGB565 (16 bpp), also 18 bpp |
| Interface | SPI (up to 62.5 MHz) |
| Controller memory | 240 x 320 x 16 bits (153.6 KB) |
| Features | Window-based addressing, hardware scrolling, partial mode, colour inversion |

### ILI9341

| Property | Value |
|----------|-------|
| Resolution | 240 x 320 |
| Colour depth | RGB565 (16 bpp), also 18 bpp and 24 bpp |
| Interface | SPI (up to 70 MHz), 8/9/16/18-bit parallel |
| Controller memory | 240 x 320 x 18 bits (172.8 KB) |
| Features | Window-based addressing, hardware scrolling, gamma correction, power control |

---

## Adding a new display driver

To add support for a new display controller:

1. Read the controller datasheet.
2. Create a new child package under `Glyph.Drivers` (e.g., `Glyph.Drivers.SSD1327`).
3. Implement the required interface subprograms:
   - `Init` — Initialize the display controller.
   - `Update` — Transfer framebuffer contents to the display.
   - `Set_Contrast` — Adjust display contrast (if supported).
   - `Set_Orientation` — Rotate or flip the display (if supported).
   - `Sleep` / `Wake` — Power management (if supported).
4. Test with real hardware.
5. Register the driver in the display configuration.
6. Update this document.

See the driver development guide in `docs/architecture/display-drivers.md` for details.
