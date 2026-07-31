# ✦ Glyph

Glyph is a lightweight, portable embedded graphics framework written in Ada 2022 for bare-metal and embedded systems.

The framework is designed around deterministic memory usage, static allocation (zero dynamic memory allocation), and a clean layered architecture that strictly separates graphics algorithms from display controller protocols and platform-specific hardware.

Glyph is built as a reusable graphics library rather than a board-specific display driver. Its goal is to provide a clean, high-performance foundation for embedded graphics while remaining completely independent of any BSP, HAL, SDK, or RTOS.

The initial hardware target is the **SSD1306 128x64 OLED display via I2C** on the **RP2040 (Vicharak Shrike-Lite)**, with the architecture built to expand to additional controllers (e.g. ST7789, ILI9341), transport interfaces (SPI, I2C), and color formats in future releases.

---

# ✦ A Note from the Author

> Glyph is my first embedded graphics framework and my first experience writing display drivers from scratch. I'm building this project while learning Ada, with the goal of gaining a deep understanding of graphics programming, embedded systems, and framework design through hands-on implementation.
>
> I'm intentionally implementing every part of the framework myself, so I'm **not looking for direct feature implementations or pull requests that write the code for me**. The learning journey is the primary objective of this project.
>
> I genuinely welcome architectural discussions, Ada best practices, design reviews, documentation improvements, bug reports, and constructive feedback. If you think something can be designed better, I'd love to hear your ideas.

---

## ✦ Design Goals

- **Written in Ada 2022** (`-gnat2022`)
- **100% Hardware Independent Core** (Zero BSP / SDK / RTOS dependencies)
- **Zero Dynamic Memory Allocation** (Static memory and stack allocation only)
- **Zero-Overhead Abstractions** (Compile-time generics and typed records)
- **Strong Range Typing & Safety** (Coordinates, dimensions, and color states)
- **Deterministic & Portable** for bare-metal embedded microcontrollers

---

## ✦ Current Status

Glyph has completed its initial architectural foundation and **First Vertical Slice Proof of Work**, verified on physical hardware (Vicharak Shrike-Lite RP2040 + SSD1306 I2C OLED).

### Completed ✅
- [x] Core project structure & Alire setup
- [x] Strong scalar range types ([`Glyph.Types`](file:///Users/lokesh/Desktop/glyph/src/glyph-types.ads))
- [x] Abstract Hardware Transport interface ([`Glyph.Transports`](file:///Users/lokesh/Desktop/glyph/src/transport/glyph-transports.ads))
- [x] Static 2D Framebuffer with SSD1306 Vertical Page layout ([`Glyph.Framebuffer`](file:///Users/lokesh/Desktop/glyph/src/framebuffer/glyph-framebuffer.ads))
- [x] Canvas API & viewport clipping ([`Glyph.Canvas`](file:///Users/lokesh/Desktop/glyph/src/canvas/glyph-canvas.ads))
- [x] SSD1306 Display Controller & Flush pipeline ([`Glyph.Controllers.SSD1306`](file:///Users/lokesh/Desktop/glyph/src/controllers/glyph-controllers-ssd1306.ads))
- [x] High-level Display composite unit ([`Glyph.Displays.SSD1306_128x64_I2C`](file:///Users/lokesh/Desktop/glyph/src/displays/glyph-displays-ssd1306_128x64_i2c.ads))
- [x] **First Vertical Slice:** Single pixel rendered & verified on hardware

### Planned ⏳
- [ ] Drawing Primitives (Bresenham Lines, Rectangles, Circles)
- [ ] Bitmap Font Rendering (5x7 & 8x8 character fonts)
- [ ] Image rendering
- [ ] Lightweight UI Widgets
- [ ] SPI transport & Color display support (ST7789, ILI9341)

---

## ✦ Architecture Overview

```text
               +-------------------+
               |    Application    |
               +---------+---------+
                         |
           +-------------+-------------+
           | (Draws onto)              | (Triggers Flush)
           ▼                           ▼
    +--------------+            +--------------+
    |    Canvas    |            |  Controller  |
    +------+-------+            +------+-------+
           |                           |
           | (Mutates pixels)          | (Reads buffer)
           ▼                           |
    +--------------+                   |
    | Framebuffer  |<------------------+
    +--------------+                   | (Transmits bytes)
                                       ▼
                               +---------------+
                               |   Transport   |
                               +---------------+
```

For full architectural specifications, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## ✦ Code Example (Firmware Integration)

```ada
with Pico_BSP.I2C;
with Glyph.Transports;
with Glyph.Displays.SSD1306_128x64_I2C;
with Glyph.Types; use Glyph.Types;

procedure Main is

   -- 1. Implement Transport interface using platform I2C peripheral
   type Pico_I2C_Transport is new Glyph.Transports.Transport with record
      -- Address 0x3C
   end record;

   -- 2. Instantiate Display Composite
   I2C_Bus : aliased Pico_I2C_Transport;
   OLED    : Glyph.Displays.SSD1306_128x64_I2C.Device (Bus => I2C_Bus'Access);

begin
   OLED.Initialize;

   -- Drawing via Canvas
   OLED.Canvas.Clear;
   OLED.Canvas.Draw_Pixel (X => 10, Y => 10, Color => On);

   -- Flush payload to hardware
   OLED.Render;
end Main;
```

---

## ✦ Project Structure

```text
glyph/
├── config/
├── src/
│   ├── canvas/          -- Drawing algorithms & clipping bounds
│   ├── controllers/     -- Display IC protocol drivers (SSD1306)
│   ├── displays/        -- High-level composite device units
│   ├── framebuffer/     -- Static pixel storage & page layout
│   ├── pixel_formats/   -- Color format definitions
│   ├── transport/       -- Abstract I2C / SPI hardware interface
│   ├── glyph.ads
│   └── glyph-types.ads  -- Strong scalar range types
├── ARCHITECTURE.md
├── README.md
├── alire.toml
└── glyph.gpr
```

---

## ✦ License

Licensed under the Apache License 2.0.
